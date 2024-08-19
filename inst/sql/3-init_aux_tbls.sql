/*

# Initialize auxiliary tables

## Notes

- Column names equal to [reserved PostgreSQL keywords](https://www.postgresql.org/docs/current/sql-keywords-appendix.html) are preventively quoted.

- The columns `created_at` and `updated_at` must come last for NocoDB to be hidden as "system fields" until
  [nocodb/nocodb#6476](https://github.com/nocodb/nocodb/issues/6476) has been resolved.

- NocoDB doesn't handle [PostgreSQL `ENUM` types](https://www.postgresql.org/docs/current/datatype-enum.html) as `SingleSelect` fields
  [yet](https://github.com/nocodb/nocodb/issues/4862), so we do not use them for now. Instead, we use `text` types and manually set the columns to NocoDB's
  virtual `SingleSelect` type and define the set of allowed values.

- Custom `ENUM` types like `"level"` can be modified via [`ALTER TYPE`](https://www.postgresql.org/docs/current/sql-altertype.html), e.g. to change existing
  values or add new ones. Removing values is not possible – and just replacing `ENUM`s is a bad idea [since the old `ENUM` could still be in use in
  indexes](https://www.postgresql.org/message-id/835.1527628154%40sss.pgh.pa.us). Read the [excellent Supabase documentation on this
  topic](https://supabase.com/docs/guides/database/postgres/enums#managing-enums) for details.

## Relevant documentation

- [CREATE TABLE](https://www.postgresql.org/docs/current/sql-createtable.html)
- [Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [Generated Columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html)
- [Row Security Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Generated Columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html)
- [Executing Dynamic Commands](https://www.postgresql.org/docs/current/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN)
- [Overview of Trigger Behavior](https://www.postgresql.org/docs/current/trigger-definition.html)

*/

-- Switch to `rdb_admin` role (errors if not authorized)
SET ROLE rdb_admin;

-- Disable printing `NOTICE`s during this session
SET client_min_messages TO WARNING;

-- Delete possibly existing tables
DO LANGUAGE plpgsql
  $$
  DECLARE
    t text;
  BEGIN
    FOREACH t IN ARRAY ARRAY['administrative_units',
                             'supranational_entities',
                             'countries',
                             'subnational_entities',
                             'municipalities',
                             'languages',
                             'topics']
    LOOP
      EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', t);
    END LOOP;
  END;
  $$;

-- Recreate custom enumerated types
DROP TYPE IF EXISTS "level" CASCADE;
CREATE TYPE "level" AS ENUM ('municipal', 'subnational', 'national', 'supranational');

-- Create tables *not* intended to be updated via NocoDB
CREATE TABLE public.supranational_entities (
  "id"         text PRIMARY KEY,
  "name"       text NOT NULL
);

CREATE TABLE public.countries (
  code         text PRIMARY KEY,
  "name"       text NOT NULL,
  name_long    text NOT NULL
);

CREATE TABLE public.subnational_entities (
  code        text PRIMARY KEY,
  parent_code text REFERENCES public.subnational_entities,
  "name"      text NOT NULL,
  "type"      text NOT NULL,
  valid_from  date NOT NULL,
  valid_to    date,
  CHECK (valid_to >= valid_from)
);

CREATE TABLE public.municipalities (
  "id"                    text GENERATED ALWAYS AS (country_code || '_' || id_official || '_' || to_char_immutable(valid_from)) STORED PRIMARY KEY,
  country_code            text NOT NULL REFERENCES public.countries ON UPDATE CASCADE,
  subnational_entity_code text NOT NULL REFERENCES public.subnational_entities ON UPDATE CASCADE,
  id_official             text NOT NULL,
  un_locode               text,
  "name"                  text NOT NULL,
  valid_from              date NOT NULL,
  valid_to                date,
  UNIQUE (country_code, id_official, valid_from), -- this might seem redundant with the PK, but is actually required for proper `ON CONFLICT` handling in upserts, cf. https://stackoverflow.com/questions/42022362/no-unique-or-exclusion-constraint-matching-the-on-conflict
  UNIQUE (un_locode, valid_from),
  CHECK (valid_to >= valid_from)
);

CREATE TABLE public.administrative_units (
  "id"       text PRIMARY KEY,
  "name"     text NOT NULL,
  "level"    text NOT NULL CHECK ("level" IN ('municipal', 'subnational', 'national', 'supranational')),
  "type"     text NOT NULL,
  parent_id  text REFERENCES public.administrative_units
);

CREATE TABLE public.languages (
  code       text PRIMARY KEY,
  "name"     text NOT NULL
);

CREATE TABLE public.topics (
  name        text PRIMARY KEY,
  parent_name text REFERENCES public.topics
);

/* Set all 'public' schema tables to be owned by 'nocodb' to avoid bug
   TODO: remove this once [nocodb/nocodb#719](https://github.com/nocodb/nocodb/issues/719) is fixed, i.e. [nocodb/nocodb#5397](https://github.com/nocodb/nocodb/pull/5397) is merged and released. */
DO LANGUAGE plpgsql
  $$
    DECLARE
      r record;
    BEGIN
      FOR r IN SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'
      LOOP
        EXECUTE format('ALTER TABLE public.%I OWNER TO %I', r.table_name, 'nocodb');
      END LOOP;
    END;
  $$;
