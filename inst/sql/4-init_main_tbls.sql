/*

# Initialize main tables

## ASSUMPTIONS

- The following main tables (which are meant to be editable via NocoDB) were freshly created from NocoDB (so that their `created_by` and `updated_by`
  columns work as supposed) *after* `init_db.sql` was run.

## NOTES

- The following tables must first be created *once* in NocoDB after the PGSQL DB has been added as external data source to let NocoDB register the necessary
  metadata for the `created/updated_by` cols. After creating the tables via NocoDB, delete them via SQL and run the below code.

- Column names equal to [reserved PostgreSQL keywords](https://www.postgresql.org/docs/current/sql-keywords-appendix.html) are preventively quoted.

- For columns of type `date` which mustn't be `NULL`, we use `0001-01-01` as default value. This easily allows to distinguish the default value from explicitly
  set ones (since `0001-01-01` should never actually occur in real data). Note that year 1 is the first AD year and [there is no year
  0 in PostgreSQL](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT), nor the [AD
  calendar](https://en.wikipedia.org/wiki/Year_zero) (but there is [in ISO 8601](https://en.wikipedia.org/wiki/Year_zero#ISO_8601)).

- The columns `created_by` and `updated_by` must be of type `varchar`, the original type assigned by NocoDB, and there mustn't be any column constraints in 
  order for them to keep working as supposed (but `DEFAULT`s are fine). If changed, NocoDB will detect a column type or attribute change during metadata sync
  and stop updating them automatically on insert/update.

- The columns `created_at` and `updated_at` must come last for NocoDB to be hidden as "system fields" until
  [nocodb/nocodb#6476](https://github.com/nocodb/nocodb/issues/6476) has been resolved.

- NocoDB doesn't handle [PostgreSQL `ENUM` types](https://www.postgresql.org/docs/current/datatype-enum.html) as `SingleSelect` fields
  [yet](https://github.com/nocodb/nocodb/issues/4862), so we do not use them for now. Instead, we use `text` types and manually set the columns to NocoDB's
  virtual `SingleSelect` type and define the set of allowed values.

- Custom `ENUM` types like `"level"` can be modified via [`ALTER TYPE`](https://www.postgresql.org/docs/current/sql-altertype.html), e.g. to change existing
  values or add new ones. Removing values is not possible – but we could work around this by converting existing columns of the custom type to `text`, `DROP`ing
  the custom `ENUM` type, creating a new one and converting the columns back to the new `ENUM` type (I guess; untested!).

- NocoDB by default takes the first non-numeric column name after the primary key as the [display value](https://docs.nocodb.com/fields/display-value), which
  is used as label for foreign keys in other tables. We have to run our R function `rdb::set_ncdb_display_vals()` once after all tables are created to set
  the proper display value columns via NocoDB's metadata API.

## Relevant doc

- [CREATE TABLE](https://www.postgresql.org/docs/current/sql-createtable.html)
- [Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [Generated Columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html)
- [Executing Dynamic Commands](https://www.postgresql.org/docs/current/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN)

*/

-- Delete possibly existing tables
DO LANGUAGE plpgsql
  $$
  DECLARE
    t text;
  BEGIN
    FOREACH t IN ARRAY ARRAY['actors',
                             'options',
                             'referendum_types',
                             'legal_norms',
                             'referendum_types_legal_norms',
                             'referendums',
                             'referendum_titles',
                             'referendum_questions',
                             'referendum_positions',
                             'referendum_votes',
                             'referendum_sub_votes']
    LOOP
      EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', t);
    END LOOP;
  END;
  $$;

-- Recreate custom enumerated types
DROP TYPE IF EXISTS "level" CASCADE;
CREATE TYPE "level" AS ENUM ('municipal', 'subnational', 'national');

-- Create auxiliary tables intended to be updated via NocoDB
CREATE TABLE public.actors (
  label       text PRIMARY KEY,
  description text,
  created_by  varchar DEFAULT CURRENT_USER,
  updated_by  varchar DEFAULT CURRENT_USER,
  created_at  timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at  timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT actors_check_updated_at_gt_created_at CHECK (updated_at >= created_at)
);

CREATE TABLE public.options (
  label         text PRIMARY KEY,
  description   text,
  created_by    varchar DEFAULT CURRENT_USER,
  updated_by    varchar DEFAULT CURRENT_USER,
  created_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT options_check_updated_at_gt_created_at CHECK (updated_at >= created_at)
);

-- Create main tables intended to be updated via NocoDB
CREATE TABLE public.referendum_types (
  "id"                    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  country_code            text NOT NULL REFERENCES public.countries ON UPDATE CASCADE,
  "level"                 text NOT NULL CHECK ("level" IN ('national', 'subnational', 'municipal')),
  subnational_entity_code text REFERENCES public.subnational_entities ON UPDATE CASCADE,
  municipality_id         text REFERENCES public.municipalities ON UPDATE CASCADE,
  title                   text NOT NULL,
  valid_from              date NOT NULL DEFAULT '0001-01-01',
  valid_to                date,
  created_by              varchar DEFAULT CURRENT_USER,
  updated_by              varchar DEFAULT CURRENT_USER,
  created_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT referendum_types_check_valid_to_gte_valid_from CHECK (valid_to >= valid_from),
  CONSTRAINT referendum_types_check_updated_at_gt_created_at CHECK (updated_at >= created_at),
  CONSTRAINT referendum_types_check_level_and_codes_1 CHECK ("level" = 'national' OR subnational_entity_code IS NOT NULL),
  CONSTRAINT referendum_types_check_level_and_codes_2 CHECK ("level" IN ('national', 'subnational') OR municipality_id IS NOT NULL),
  CONSTRAINT referendum_types_check_level_and_codes_3 CHECK (subnational_entity_code IS NULL OR "level" IN ('subnational', 'municipal')),
  CONSTRAINT referendum_types_check_level_and_codes_4 CHECK (municipality_id IS NULL OR "level" = 'municipal')
);

CREATE TABLE public.legal_norms (
  "id"                    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  country_code            text NOT NULL REFERENCES public.countries ON UPDATE CASCADE,
  "level"                 text NOT NULL CHECK ("level" IN ('national', 'subnational', 'municipal')),
  subnational_entity_code text REFERENCES public.subnational_entities ON UPDATE CASCADE,
  municipality_id         text REFERENCES public.municipalities ON UPDATE CASCADE,
  title                   text NOT NULL,
  hierarchy_level         text NOT NULL CHECK ("hierarchy_level" IN ('international treaty', 'treaty', 'constitution', 'law', 'decree', 'other')),
  legal_text              text NOT NULL,
  url                     text NOT NULL,
  valid_from              date NOT NULL DEFAULT '0001-01-01',
  valid_to                date,
  created_by              varchar DEFAULT CURRENT_USER,
  updated_by              varchar DEFAULT CURRENT_USER,
  created_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT legal_norms_check_valid_to_gte_valid_from CHECK (valid_to >= valid_from),
  CONSTRAINT legal_norms_check_updated_at_gt_created_at CHECK (updated_at >= created_at),
  CONSTRAINT legal_norms_check_level_and_codes_1 CHECK ("level" = 'national' OR subnational_entity_code IS NOT NULL),
  CONSTRAINT legal_norms_check_level_and_codes_2 CHECK ("level" IN ('national', 'subnational') OR municipality_id IS NOT NULL),
  CONSTRAINT legal_norms_check_level_and_codes_3 CHECK (subnational_entity_code IS NULL OR "level" IN ('subnational', 'municipal')),
  CONSTRAINT legal_norms_check_level_and_codes_4 CHECK (municipality_id IS NULL OR "level" = 'municipal')
);

CREATE TABLE public.referendum_types_legal_norms (
  referendum_type_id      integer NOT NULL REFERENCES public.referendum_types ON UPDATE CASCADE ON DELETE CASCADE,
  legal_norm_id           integer NOT NULL REFERENCES public.legal_norms ON UPDATE CASCADE ON DELETE CASCADE,
  created_by              varchar DEFAULT CURRENT_USER,
  updated_by              varchar DEFAULT CURRENT_USER,
  created_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (referendum_type_id, legal_norm_id),
  CONSTRAINT referendum_types_legal_norms_check_updated_at_gt_created_at CHECK (updated_at >= created_at)
);

CREATE TABLE public.referendums (
  "id"                    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  display                 text GENERATED ALWAYS AS (to_char_immutable("date") || " " || "level" || " " || COALESCE(municipality_id, subnational_entity_code, country_code) || " (" || "id" || ")") STORED,
  id_official             text,
  id_sudd                 text,
  is_draft                boolean NOT NULL DEFAULT TRUE,
  "date"                  date NOT NULL,
  country_code            text NOT NULL REFERENCES public.countries ON UPDATE CASCADE,
  "level"                 text NOT NULL CHECK ("level" IN ('national', 'subnational', 'municipal')),
  subnational_entity_code text REFERENCES public.subnational_entities ON UPDATE CASCADE,
  municipality_id         text REFERENCES public.municipalities ON UPDATE CASCADE,
  type_id                 integer NOT NULL REFERENCES public.referendum_types ON UPDATE CASCADE,
  attachments             text,
  created_by              varchar DEFAULT CURRENT_USER,
  updated_by              varchar DEFAULT CURRENT_USER,
  created_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT referendums_check_updated_at_gt_created_at CHECK (updated_at >= created_at),
  CONSTRAINT referendums_check_level_and_codes_1 CHECK ("level" = 'national' OR subnational_entity_code IS NOT NULL),
  CONSTRAINT referendums_check_level_and_codes_2 CHECK ("level" IN ('national', 'subnational') OR municipality_id IS NOT NULL),
  CONSTRAINT referendums_check_level_and_codes_3 CHECK (subnational_entity_code IS NULL OR "level" IN ('subnational', 'municipal')),
  CONSTRAINT referendums_check_level_and_codes_4 CHECK (municipality_id IS NULL OR "level" = 'municipal')
);

-- Create remaining auxiliary tables intended to be updated via NocoDB
CREATE TABLE public.referendum_titles (
  referendum_id integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  language_code text NOT NULL REFERENCES public.languages ON UPDATE CASCADE,
  title         text NOT NULL,
  is_official   boolean NOT NULL,
  "source"      text,
  remarks       text,
  created_by    varchar DEFAULT CURRENT_USER,
  updated_by    varchar DEFAULT CURRENT_USER,
  created_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (referendum_id, language_code),
  CONSTRAINT referendum_titles_check_updated_at_gt_created_at CHECK (updated_at >= created_at)
);

CREATE TABLE public.referendum_questions (
  referendum_id integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  language_code text NOT NULL REFERENCES public.languages ON UPDATE CASCADE,
  question      text NOT NULL,
  is_official   boolean NOT NULL,
  "source"      text,
  remarks       text,
  created_by    varchar DEFAULT CURRENT_USER,
  updated_by    varchar DEFAULT CURRENT_USER,
  created_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (referendum_id, language_code),
  CONSTRAINT referendum_questions_check_updated_at_gt_created_at CHECK (updated_at >= created_at)
);

CREATE TABLE public.referendum_positions (
  referendum_id integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  actor_label   text NOT NULL REFERENCES public.actors ON UPDATE CASCADE,
  option_label  text NOT NULL REFERENCES public.options ON UPDATE CASCADE,
  created_by    varchar DEFAULT CURRENT_USER,
  updated_by    varchar DEFAULT CURRENT_USER,
  created_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (referendum_id, actor, "option"),
  CONSTRAINT referendum_positions_check_updated_at_gt_created_at CHECK (updated_at >= created_at)
);

CREATE TABLE public.referendum_votes (
  referendum_id integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  option_label  text NOT NULL REFERENCES public.options ON UPDATE CASCADE,
  "count"       bigint NOT NULL CHECK ("count" >= 0),
  "source"      text,
  remarks       text,
  created_by    varchar DEFAULT CURRENT_USER,
  updated_by    varchar DEFAULT CURRENT_USER,
  created_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (referendum_id, option),
  CONSTRAINT referendum_votes_check_updated_at_gt_created_at CHECK (updated_at >= created_at)
);

CREATE TABLE public.referendum_sub_votes (
  referendum_id           integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  subnational_entity_code text NOT NULL REFERENCES public.subnational_entities ON UPDATE CASCADE,
  option_label            text NOT NULL REFERENCES public.options ON UPDATE CASCADE,
  "count"                 bigint NOT NULL CHECK ("count" >= 0),
  "source"                text,
  remarks                 text,
  created_by              varchar DEFAULT CURRENT_USER,
  updated_by              varchar DEFAULT CURRENT_USER,
  created_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at              timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (referendum_id, subnational_entity_code, option),
  CONSTRAINT referendum_sub_votes_check_updated_at_gt_created_at CHECK (updated_at >= created_at)
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

--- Create function and trigger to fix NocoDB attachment URLs, cf. https://github.com/nocodb/nocodb/issues/5914#issuecomment-2005008734
CREATE OR REPLACE FUNCTION public.fix_attachments_url()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
    BEGIN
      NEW.attachments = regexp_replace(NEW.attachments, '"url":"/nc/uploads/', '"url":"https://rdb-attachments.s3.eu-central-003.backblazeb2.com/nc/uploads/', 'g');
      RETURN NEW;
    END;
  $$;

CREATE OR REPLACE TRIGGER set_attachments_url
  BEFORE INSERT OR UPDATE OF attachments ON public.referendums
  FOR EACH ROW EXECUTE PROCEDURE public.fix_attachments_url();

-- Add column labels
--- for common column names
DO LANGUAGE plpgsql
  $$
    DECLARE
      r record;
    BEGIN
      FOR r IN SELECT table_name FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'created_by'
      LOOP
        EXECUTE format('COMMENT ON COLUMN public.%I.created_by IS %L', r.table_name, E'creator\n\nuser who created the entry');
      END LOOP;
    END;
  $$;

DO LANGUAGE plpgsql
  $$
    DECLARE
      r record;
    BEGIN
      FOR r IN SELECT table_name FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'updated_by'
      LOOP
        EXECUTE format('COMMENT ON COLUMN public.%I.updated_by IS %L', r.table_name, E'updater\n\nuser who last updated the entry');
      END LOOP;
    END;
  $$;

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

--- for referendums table
--- TODO: add lbls via R pkg rdb

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

/* Revoke write privileges from 'nocodb' for autofilled tables */
/* NOTE: commented out for now due to issues with updating tables (certain actions are always performed as table owner which is currently `nocodb`)
DO LANGUAGE plpgsql
  $$
    DECLARE
      t text;
    BEGIN
      FOREACH t IN ARRAY ARRAY['countries',
                               'subnational_entities',
                               'municipalities',
                               'languages']
      LOOP
        EXECUTE format('REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON public.%I FROM nocodb', t);
      END LOOP;
    END;
  $$;
*/
