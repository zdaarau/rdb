/*

# Initialize auxiliary tables

## Notes

- Column names equal to [reserved PostgreSQL keywords](https://www.postgresql.org/docs/current/sql-keywords-appendix.html) are preventively quoted.

- The columns `created_at` and `updated_at` must come last for NocoDB to be hidden as "system fields" until
  [nocodb/nocodb#6476](https://github.com/nocodb/nocodb/issues/6476) has been resolved.

- NocoDB by default takes the first non-numeric column name after the primary key as the [display value](https://docs.nocodb.com/fields/display-value), which
  is used as label for foreign keys in other tables. We have to run our R function `rdb::set_ncdb_display_vals()` once after all tables are created to set
  the proper display value columns via NocoDB's metadata API.

## Relevant documentation

- [CREATE TABLE](https://www.postgresql.org/docs/current/sql-createtable.html)
- [Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [Generated Columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html)
- [Executing Dynamic Commands](https://www.postgresql.org/docs/current/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN)

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
    FOREACH t IN ARRAY ARRAY['supranational_entities',
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

-- Create tables *not* intended to be updated via NocoDB
CREATE TABLE public.supranational_entities (
  "id"         text PRIMARY KEY,
  "name"       text NOT NULL,
  created_at   timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at   timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CHECK (updated_at >= created_at)
);

CREATE TABLE public.countries (
  code         text PRIMARY KEY,
  "name"       text NOT NULL,
  name_long    text NOT NULL,
  created_at   timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at   timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CHECK (updated_at >= created_at)
);

CREATE TABLE public.subnational_entities (
  code        text PRIMARY KEY,
  parent_code text REFERENCES public.subnational_entities,
  "name"      text NOT NULL,
  "type"      text NOT NULL,
  valid_from  date NOT NULL,
  valid_to    date,
  created_at  timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at  timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CHECK (valid_to >= valid_from),
  CHECK (updated_at >= created_at)
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
  created_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (country_code, id_official, valid_from), -- this might seem redundant with the PK, but is actually required for proper `ON CONFLICT` handling in upserts, cf. https://stackoverflow.com/questions/42022362/no-unique-or-exclusion-constraint-matching-the-on-conflict
  UNIQUE (un_locode, valid_from),
  CHECK (valid_to >= valid_from),
  CHECK (updated_at >= created_at)
);

CREATE TABLE public.languages (
  code       text PRIMARY KEY,
  "name"     text NOT NULL,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CHECK (updated_at >= created_at)
);

CREATE TABLE public.topics (
  name        text PRIMARY KEY,
  parent_name text REFERENCES public.topics,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CHECK (updated_at >= created_at)
);

-- Create triggers for `updated_at` columns
DO LANGUAGE plpgsql
  $$
    DECLARE
      r record;
    BEGIN
      FOR r IN SELECT table_name FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'updated_at'
      LOOP
        EXECUTE format('CREATE OR REPLACE TRIGGER %I BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE PROCEDURE moddatetime (%I)', 'set_updated_at', r.table_name, 'updated_at');
      END LOOP;
    END;
  $$;

-- Add column labels
--- for common column names
DO LANGUAGE plpgsql
  $$
    DECLARE
      r record;
    BEGIN
      FOR r IN SELECT table_name FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'created_at'
      LOOP
        EXECUTE format('COMMENT ON COLUMN public.%I.created_at IS %L', r.table_name, E'creation time\n\ndate and time on which the entry was created');
      END LOOP;
    END;
  $$;

DO LANGUAGE plpgsql
  $$
    DECLARE
      r record;
    BEGIN
      FOR r IN SELECT table_name FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'updated_at'
      LOOP
        EXECUTE format('COMMENT ON COLUMN public.%I.updated_at IS %L', r.table_name, E'update time\n\ndate and time on which the entry was last updated');
      END LOOP;
    END;
  $$;

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
