/*

# Initialize database

## NOTES

- The file uses [`DBI::sqlInterpolate()`](https://dbi.r-dbi.org/reference/sqlInterpolate.html)-compatible named placeholders à la `?pw_r_anon` to refer to
  sensitive information.

- Since Neon offers a *managed* PostgreSQL server, we don't have full permissions when accessing it via `psql`, **regardless of the chosen role**. Certain
  privileges (TODO: what exactly?) do not behave as with a classic PostgreSQL installation.

  Furthermore, the columns `created_by` and `updated_by` are only automatically updated by NocoDB when the corresponding table was created from NocoDB –
  `created_at/by` und `updated_at/by` columns from self-created tables are handled differently internally (they are also not editable via NocoDB's UI). Since
  information (user names) only available to NocoDB is necessary to fill `created/updated_by`, we can't update them adequately via a PostgreSQL trigger function
  alone. Instead, tables for which we want these columns included in, just have to be initially created from NocoDB.

  In sum, we assume that

  1. the user `rdb_admin` has alread been created from the Neon console, CLI or API.

  2. the database (`rdb`) was freshly created from the Neon console, CLI or API with owner set to `rdb_admin`.

  3. the SQL statements below are run from Neon console's *SQL Editor* on database `rdb` (which always uses the database owner role, i.e. `rdb_admin` in this
     case).

- Custom `ENUM` types like `"level"` can be modified via [`ALTER TYPE`](https://www.postgresql.org/docs/current/sql-altertype.html), e.g. to add change existing
  values or add new ones. Removing values is not possible – but we could work around this by converting existing columns of the custom type to type `text`,
  `DROP`ing the custom `ENUM` type, creating a new one and converting the columns back to the new `ENUM` type (I guess; untested!).

- In principle, there's no point in setting a password for PostgreSQL roles that can't login like `readonly` and `readwrite`. But since Neon doesn't support
  creating roles without a password set, we nevertheless have to define one, altough it will never be used.

## Relevant doc

- [SQL Key Words](https://www.postgresql.org/docs/current/sql-keywords-appendix.html)
- [CREATE ROLE](https://www.postgresql.org/docs/current/sql-createrole.html)
- [Database Roles](https://www.postgresql.org/docs/current/user-manag.html)
- [Privileges](https://www.postgresql.org/docs/current/ddl-priv.html)

*/

-- Switch to `rdb_admin` role (just to be explicit; has no effect on the Neon console)
SET ROLE rdb_admin;

-- Install necessary PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS moddatetime;
CREATE EXTENSION IF NOT EXISTS pg_graphql;

-- Set DB description
COMMENT ON DATABASE rdb IS
  'Referendum Database (RDB), aiming to record all direct democratic votings worldwide organized by states or state-like entities';

-- Reset public schema to initial state, cf. https://stackoverflow.com/a/21247009/7196903
-- NOTE: only relevant if DB wasn't re-created from scratch
/* DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO neon_superuser;
GRANT ALL ON SCHEMA public TO public;
ALTER SCHEMA public OWNER TO pg_database_owner; */

-- Set schema description and configure `pg_graphql` via SQL COMMENT directives, cf. https://supabase.github.io/pg_graphql/configuration/
-- TODO: Use more structured metadata once PostgREST allows for this, cf. https://github.com/supabase/pg_graphql/issues/331#issuecomment-1447455070
COMMENT ON SCHEMA public IS
$$RDB API

Official RESTful API for the Referendum Database (RDB). The RDB aims to record all direct democratic votings worldwide organized by states or state-like entities.

@graphql({"inflect_names": true})$$;

-- Create `public.graphql` function to be able to make GraphQL queries via the PostgREST `/rpc/graphql` endpoint
-- cf. https://github.com/supabase/pg_graphql/blob/20082ea311738979fa8a4e1d218441c891195e6f/dockerfiles/db/setup.sql#L18-L34
CREATE OR REPLACE FUNCTION public.graphql(
    query           text  DEFAULT NULL,
    variables       jsonb DEFAULT NULL,
    "operationName" text  DEFAULT NULL,
    extensions      jsonb DEFAULT NULL
  )
  RETURNS jsonb
  LANGUAGE sql
  AS $$
    SELECT graphql.resolve(
      query := query,
      variables := coalesce(variables, '{}'),
      "operationName" := "operationName",
      extensions := extensions
    );
  $$;

-- Create immutable `to_char` function for dates
CREATE OR REPLACE FUNCTION public.to_char_immutable(date)
  RETURNS text
  LANGUAGE sql
  IMMUTABLE
  AS $$
    SELECT to_char($1, 'YYYY-MM-DD');
  $$;

-- Create `drop_owned_by` and `reassign_owned_by` functions to drop/reassign owned by objs
CREATE OR REPLACE FUNCTION public.drop_owned_by(text)
  RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      IF EXISTS (SELECT FROM pg_roles WHERE rolname = $1) THEN
        EXECUTE format('DROP OWNED BY %I', $1);
      END IF;
    END
  $$;

CREATE OR REPLACE FUNCTION public.reassign_owned_by(text, text)
  RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      IF EXISTS (SELECT FROM pg_roles WHERE rolname = $1) THEN
        EXECUTE format('REASSIGN OWNED BY %I TO %I', $1, $2);
      END IF;
    END
  $$;
  
-- (Re-)create common read-only role
SELECT drop_owned_by('readonly');
DROP ROLE IF EXISTS readonly;
CREATE ROLE readonly WITH PASSWORD ?pw_readonly ROLE rdb_admin;
GRANT CONNECT ON DATABASE rdb TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT USAGE ON SCHEMA graphql TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;

-- (Re-)create common read-write role
SELECT reassign_owned_by('readwrite', 'rdb_admin');
SELECT drop_owned_by('readwrite');
DROP ROLE IF EXISTS readwrite;
CREATE ROLE readwrite WITH PASSWORD ?pw_readwrite ROLE rdb_admin;
GRANT CONNECT, TEMPORARY ON DATABASE rdb TO readwrite;
GRANT USAGE ON SCHEMA public TO readwrite;
GRANT USAGE ON SCHEMA graphql TO readwrite;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO readwrite;
GRANT ALL PRIVILEGES ON ALL ROUTINES IN SCHEMA public TO readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON ROUTINES TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO readwrite;

-- (Re-)create common read-write role with full privileges (including creating new objects in the schema)
SELECT reassign_owned_by('readwritefull', 'rdb_admin');
SELECT drop_owned_by('readwritefull');
DROP ROLE IF EXISTS readwritefull;
CREATE ROLE readwritefull WITH PASSWORD ?pw_readwritefull ROLE rdb_admin;
GRANT ALL PRIVILEGES ON DATABASE rdb TO readwritefull;
GRANT ALL PRIVILEGES ON SCHEMA public TO readwritefull;
GRANT USAGE ON SCHEMA graphql TO readwritefull;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO readwritefull;
GRANT ALL PRIVILEGES ON ALL ROUTINES IN SCHEMA public TO readwritefull;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO readwritefull;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO readwritefull;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON ROUTINES TO readwritefull;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO readwritefull;

-- (Re-)create user for automated backup task
SELECT drop_owned_by('archiver');
DROP ROLE IF EXISTS archiver;
CREATE ROLE archiver WITH LOGIN PASSWORD ?pw_archiver ROLE rdb_admin;
GRANT readonly TO archiver;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO archiver;

-- (Re-)create users for PostgREST and grant necessary access rights
SELECT reassign_owned_by('authenticator', 'rdb_admin');
SELECT drop_owned_by('authenticator');
SELECT drop_owned_by('web_anon');
SELECT reassign_owned_by('web_user', 'rdb_admin');
SELECT drop_owned_by('web_user');
DROP ROLE IF EXISTS authenticator;
DROP ROLE IF EXISTS web_anon;
DROP ROLE IF EXISTS web_user;
CREATE ROLE authenticator WITH NOINHERIT LOGIN PASSWORD ?pw_authenticator ROLE rdb_admin;
CREATE ROLE web_anon WITH PASSWORD ?pw_web_anon ROLE rdb_admin;
CREATE ROLE web_user WITH PASSWORD ?pw_web_user ROLE rdb_admin;
GRANT web_anon TO authenticator;
GRANT web_user TO authenticator;
GRANT readonly TO web_anon;
GRANT readwrite TO web_user;

-- (Re-)create users for R and grant necessary access rights
SELECT drop_owned_by('r_anon');
DROP ROLE IF EXISTS r_anon;
CREATE ROLE r_anon WITH LOGIN PASSWORD ?pw_r_anon ROLE rdb_admin;
GRANT readonly TO r_anon;
SELECT reassign_owned_by('r_user', 'rdb_admin');
SELECT drop_owned_by('r_user');
DROP ROLE IF EXISTS r_user;
CREATE ROLE r_user WITH LOGIN PASSWORD ?pw_r_user ROLE rdb_admin;
GRANT readwrite TO r_user;

-- (Re-)create user for NocoDB
SELECT reassign_owned_by('nocodb', 'rdb_admin');
SELECT drop_owned_by('nocodb');
DROP ROLE IF EXISTS nocodb;
CREATE ROLE nocodb WITH LOGIN PASSWORD ?pw_nocodb ROLE rdb_admin;
--- NOTE: we cannot grant the 'readwritefull' role since we don't wanna give write access to all tables
GRANT ALL PRIVILEGES ON DATABASE rdb TO nocodb;
GRANT ALL PRIVILEGES ON SCHEMA public TO nocodb;
GRANT USAGE ON SCHEMA graphql TO nocodb;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO nocodb;
GRANT ALL PRIVILEGES ON ALL ROUTINES IN SCHEMA public TO nocodb;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO nocodb;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON ROUTINES TO nocodb;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO nocodb;

-- Create trigger to notify PostgREST on schema updates, cf. https://postgrest.org/en/stable/references/schema_cache.html#automatic-schema-cache-reloading
/* COMMENTED OUT since we aren't allowed to create event triggers on Neon, cf. https://discord.com/channels/1176467419317940276/1216517379366846474
--- watch `CREATE`, `ALTER` and `COMMENT`
CREATE OR REPLACE FUNCTION pgrst_ddl_watch()
  RETURNS event_trigger
  LANGUAGE plpgsql
  AS $$
    DECLARE
      cmd record;
    BEGIN
      FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
      LOOP
        IF cmd.command_tag IN (
          'CREATE SCHEMA', 'ALTER SCHEMA'
        , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
        , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
        , 'CREATE VIEW', 'ALTER VIEW'
        , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
        , 'CREATE FUNCTION', 'ALTER FUNCTION'
        , 'CREATE TRIGGER'
        , 'CREATE TYPE', 'ALTER TYPE'
        , 'CREATE RULE'
        , 'COMMENT'
        )
        -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
        AND cmd.schema_name is distinct from 'pg_temp'
        THEN
          NOTIFY pgrst, 'reload schema';
        END IF;
      END LOOP;
    END;
  $$;

--- watch `DROP`
CREATE OR REPLACE FUNCTION pgrst_drop_watch()
  RETURNS event_trigger
  LANGUAGE plpgsql
  AS $$
    DECLARE
      obj record;
    BEGIN
      FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
      LOOP
        IF obj.object_type IN (
          'schema'
        , 'table'
        , 'foreign table'
        , 'view'
        , 'materialized view'
        , 'function'
        , 'trigger'
        , 'type'
        , 'rule'
        )
        AND obj.is_temporary IS false -- no pg_temp objects
        THEN
          NOTIFY pgrst, 'reload schema';
        END IF;
      END LOOP;
    END;
  $$;

CREATE EVENT TRIGGER pgrst_ddl_watch
  ON ddl_command_end
  EXECUTE PROCEDURE pgrst_ddl_watch();

CREATE EVENT TRIGGER pgrst_drop_watch
  ON sql_drop
  EXECUTE PROCEDURE pgrst_drop_watch();*/
