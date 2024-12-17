/*

# Initialize main tables

## Notes

- The following tables must first be created *once* in NocoDB after the PGSQL DB has been added as external data source to let NocoDB register the necessary
  metadata for the `created/updated_by` cols. After creating the tables via NocoDB, delete them via SQL and run the below code.

- Column names equal to [reserved PostgreSQL keywords](https://www.postgresql.org/docs/current/sql-keywords-appendix.html) are preventively quoted.

- `ENUM` values are [expected to conform to ASCII snake_case by pg_graphql](https://github.com/supabase/pg_graphql/issues/172). For exceptions, mappings must
  be explicitly defined via suitable [comment directives](https://supabase.github.io/pg_graphql/configuration/#enum-variant).

- For columns of type `date` which mustn't be `NULL`, we use `0101-01-01` as default value. This easily allows to distinguish the default value from explicitly
  set ones (since a date as early as `0101-01-01` should never occur in real data). Note that year 1 is the first AD year and [there is no year 0 in
  PostgreSQL](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT), nor the [AD
  calendar](https://en.wikipedia.org/wiki/Year_zero) (but there is [in ISO 8601](https://en.wikipedia.org/wiki/Year_zero#ISO_8601)).

- The columns `created_by` and `updated_by` must be of type `varchar`, the original type assigned by NocoDB, and there mustn't be any column constraints in 
  order for them to keep working as supposed (but `DEFAULT`s are fine). If changed, NocoDB will detect a column type or attribute change during metadata sync
  and stop updating them automatically on insert/update.

- Tables with more than 5 columns [aren't recognized as M2M tables in NocoDB](https://github.com/nocodb/nocodb/issues/8241).

- NocoDB by default takes the first non-numeric column name after the primary key as the [display value](https://docs.nocodb.com/fields/display-value), which
  is used as label for foreign keys in other tables. We have to run our R function `rdb::set_ncdb_display_vals()` once after all tables are created to set
  the proper display value columns via NocoDB's metadata API.

- Possible alternatives to the `referendum_clusters` table include:

  - A simple array column `siblings text[] REFERENCES public.referendums ON UPDATE CASCADE ON DELETE SET NULL` in `referendums` which would require PostgreSQL
    to land [support for foreign key arrays](https://commitfest.postgresql.org/17/1252/) first. With this approach, we would lose the information encoded in the
    `referendum_clusters.description` column.
  
  - A many-to-many "junction" table like

    ```sql
    CREATE TABLE public.referendums_referendums (
      referendum_id           integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
      referendum_id_linked    integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
      PRIMARY KEY (referendum_id, referendum_id_linked),
      CONSTRAINT topics_referendums_check_referendum_id_ne_referendum_id_linked CHECK (referendum_id != referendum_id_linked)
    );
    ```

    Main problem with this approach is that it is not properly supported by NocoDB, which renders it basically unusable for us. Besides, the information encoded
    in the `referendum_clusters.description` column couldn't be easily replicated (i.e. without redundancy or introduction of another table).

## Relevant documentation

- [CREATE TABLE](https://www.postgresql.org/docs/current/sql-createtable.html)
- [Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [Pattern Matching](https://www.postgresql.org/docs/current/functions-matching.html)
- [Row Security Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Generated Columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html)
- [Executing Dynamic Commands](https://www.postgresql.org/docs/current/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN)
- [Overview of Trigger Behavior](https://www.postgresql.org/docs/current/trigger-definition.html)
  - NOTE: `CONSTRAINT TRIGGER`s are [not a viable solution for
    anything](https://www.cybertec-postgresql.com/en/triggers-to-enforce-constraints/#what-about-these-%e2%80%9cconstraint-triggers%e2%80%9d), it appears.

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
    FOREACH t IN ARRAY ARRAY['actors',
                             'legal_instruments',
                             'legal_norms',
                             'referendum_types',
                             'referendum_clusters',
                             'referendums',
                             'options',
                             'referendum_titles',
                             'referendum_questions',
                             'referendum_urls',
                             'referendum_positions',
                             'referendum_votes',
                             'referendum_sub_votes',
                             'electorate',
                             'referendum_types_legal_norms',
                             'referendum_types_referendums',
                             'topics_referendums']
    LOOP
      EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', t);
    END LOOP;
  END;
  $$;

-- Recreate custom enumerated types
DROP TYPE IF EXISTS hierarchy_level CASCADE;
CREATE TYPE hierarchy_level AS ENUM ('supra-level treaty', 'treaty', 'constitution', 'law', 'decree', 'other');
COMMENT ON TYPE hierarchy_level IS
$$Legal hierarchy level

Legal level at which the instrument is implemented.

@graphql({"mappings": {"supra-level treaty": "supra_level_treaty"}})$$;

-- Recreate custom domains
DROP DOMAIN IF EXISTS url CASCADE;
DROP DOMAIN IF EXISTS bigcount CASCADE;
DROP DOMAIN IF EXISTS roundedfraction CASCADE;
CREATE DOMAIN url AS text CHECK (VALUE ~ '^https?:\/\/[^/.\n]+\.[^/.\n]+[^\n]*');
CREATE DOMAIN bigcount AS bigint CHECK (VALUE >= 0);
CREATE DOMAIN roundedfraction AS numeric(10,9) CHECK (VALUE BETWEEN 0 AND 1);

-- Create prerequisite auxiliary tables intended to be updated via NocoDB
CREATE TABLE public.actors (
  label       text PRIMARY KEY,
  description text
);

-- Create main tables intended to be updated via NocoDB
CREATE TABLE public.legal_instruments (
  -- NOTE: we must define `display` as PK in order to be able to generate an intuitive `legal_norms.display` column
  display                 text GENERATED ALWAYS AS (administrative_unit_id || ': ' || abbreviation) STORED UNIQUE,
  administrative_unit_id  text NOT NULL REFERENCES public.administrative_units ON UPDATE CASCADE,
  hierarchy_level         text NOT NULL CHECK ("hierarchy_level" IN ('international treaty', 'treaty', 'constitution', 'law', 'decree', 'other')),
  language_code           text NOT NULL REFERENCES public.languages ON UPDATE CASCADE,
  title                   text NOT NULL,
  abbreviation            text NOT NULL,
  PRIMARY KEY (administrative_unit_id, abbreviation)
);

CREATE TABLE public.legal_norms (
  "id"                     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  display                  text GENERATED ALWAYS AS (concat_ws_immutable(
                                                      ' ',
                                                      legal_instrument_display,
                                                      clause,
                                                     NULLIF('(' || to_char_immutable(valid_from) || '–' || COALESCE(to_char_immutable(valid_to), 'ongoing') || ')', '(0101-01-01–ongoing)')
                                                    )) STORED,
  legal_instrument_display text NOT NULL REFERENCES public.legal_instruments (display) ON UPDATE CASCADE,
  clause                   text,
  "text"                   text NOT NULL,
  url                      url,
  adopted_urgently         boolean NOT NULL DEFAULT FALSE,
  valid_from               date NOT NULL DEFAULT '0101-01-01',
  valid_to                 date,
  UNIQUE (legal_instrument_display, clause, valid_from),
  CONSTRAINT legal_norms_check_valid_to_gte_valid_from CHECK (valid_to >= valid_from)
);

CREATE TABLE public.referendum_types (
  "id"                          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  display                       text GENERATED ALWAYS AS (concat_ws_immutable(
                                                           ' ',
                                                           administrative_unit_id || ': ',
                                                           "title",
                                                           NULLIF('(' || to_char_immutable(valid_from) || '–' || COALESCE(to_char_immutable(valid_to), 'ongoing') || ')', '(0101-01-01–ongoing)')
                                                         )) STORED,
  is_draft                      boolean NOT NULL DEFAULT TRUE,
  administrative_unit_id        text REFERENCES public.administrative_units ON UPDATE CASCADE,
  title                         text NOT NULL,
  valid_from                    date NOT NULL DEFAULT '0101-01-01',
  valid_to                      date,
  trigger_actor_label           text REFERENCES public.actors ON UPDATE CASCADE,
  trigger_threshold_absolute    bigcount,
  trigger_threshold_relative    roundedfraction,
  are_empty_votes_counted       boolean DEFAULT FALSE,
  is_binding                    boolean DEFAULT TRUE,
  is_electorate_abroad_eligible boolean DEFAULT FALSE,
  quorum_approval               roundedfraction DEFAULT 0.5,
  quorum_turnout                roundedfraction DEFAULT 0,
  UNIQUE (administrative_unit_id, title, valid_from),
  CONSTRAINT referendum_types_check_valid_to_gte_valid_from CHECK (valid_to >= valid_from)
);

CREATE TABLE public.referendum_clusters (
  "id"       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  remarks    text
);

CREATE TABLE public.referendums (
  "id"                   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  display                text GENERATED ALWAYS AS (concat_ws_immutable(
                                                    ' ',
                                                    to_char_immutable("date"),
                                                    administrative_unit_id,
                                                    '(id: ' || "id" || ')'
                                                  )) STORED,
  id_old                 text UNIQUE,
  id_official            text,
  id_sudd                text,
  is_draft               boolean NOT NULL DEFAULT TRUE,
  "date"                 date, --- this is allowed to be NULL for entries where the date is still uncertain (sometimes referendums get postponed to unspecified dates)
  administrative_unit_id text NOT NULL REFERENCES public.administrative_units ON UPDATE CASCADE,
  cluster_id             integer REFERENCES public.referendum_clusters ON UPDATE CASCADE ON DELETE SET NULL,
  init_actor_label       text REFERENCES public.actors ON UPDATE CASCADE,
  attachments            text,
  "source"               text,
  remarks                text,
  CONSTRAINT referendums_check_draft_or_date CHECK (is_draft OR date IS NOT NULL)
);

-- Create remaining auxiliary tables intended to be updated via NocoDB
CREATE TABLE public.options (
  -- NOTE: we need the `display` column here i.a. to be able to generate an intuitive `referendum_sub_votes.display` column
  display       text GENERATED ALWAYS AS (COALESCE('referendum_id ' || referendum_id, label)) STORED PRIMARY KEY,
  label         text UNIQUE,
  description   text,
  referendum_id integer UNIQUE REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT options_check_referendum_id_or_label_1 CHECK (referendum_id IS NOT NULL OR label IS NOT NULL),
  CONSTRAINT options_check_referendum_id_or_label_2 CHECK (referendum_id IS NULL OR label IS NULL)
);

CREATE TABLE public.referendum_titles (
  referendum_id integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  language_code text NOT NULL REFERENCES public.languages ON UPDATE CASCADE,
  title         text NOT NULL,
  is_official   boolean NOT NULL,
  PRIMARY KEY (referendum_id, language_code)
);

CREATE TABLE public.referendum_questions (
  referendum_id integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  language_code text NOT NULL REFERENCES public.languages ON UPDATE CASCADE,
  question      text NOT NULL,
  is_official   boolean NOT NULL,
  PRIMARY KEY (referendum_id, language_code)
);

CREATE TABLE public.referendum_urls (
  referendum_id integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  language_code text NOT NULL REFERENCES public.languages ON UPDATE CASCADE,
  url           url NOT NULL,
  description   text,
  is_official   boolean NOT NULL,
  PRIMARY KEY (referendum_id, language_code)
);

CREATE TABLE public.referendum_positions (
  display        text GENERATED ALWAYS AS (actor_label || ': ' || option_display) STORED,
  referendum_id  integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  actor_label    text NOT NULL REFERENCES public.actors ON UPDATE CASCADE,
  option_display text NOT NULL REFERENCES public.options ON UPDATE CASCADE,
  PRIMARY KEY (referendum_id, actor_label)
);

CREATE TABLE public.referendum_votes (
  referendum_id  integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  option_display text NOT NULL REFERENCES public.options ON UPDATE CASCADE,
  "count"        bigcount NOT NULL,
  "source"       text,
  remarks        text,
  PRIMARY KEY (referendum_id, option_display)
);

CREATE TABLE public.referendum_sub_votes (
  display                 text GENERATED ALWAYS AS (administrative_unit_id || ' ' || option_display) STORED,
  referendum_id           integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  administrative_unit_id  text NOT NULL REFERENCES public.administrative_units ON UPDATE CASCADE,
  option_display          text NOT NULL REFERENCES public.options ON UPDATE CASCADE,
  "count"                 bigcount NOT NULL,
  "source"                text,
  remarks                 text,
  PRIMARY KEY (referendum_id, administrative_unit_id, option_display)
);

CREATE TABLE public.electorate (
  display                text GENERATED ALWAYS AS (administrative_unit_id || ' ' || to_char_immutable("date")) STORED,
  administrative_unit_id text NOT NULL REFERENCES public.administrative_units ON UPDATE CASCADE,
  total                  bigcount NOT NULL,
  abroad                 bigcount,
  "date"                 date NOT NULL
);

-- Create junction tables intended to be updated via NocoDB
CREATE TABLE public.referendum_types_legal_norms (
  referendum_type_id integer NOT NULL REFERENCES public.referendum_types ON UPDATE CASCADE ON DELETE CASCADE,
  legal_norm_id      integer NOT NULL REFERENCES public.legal_norms ON UPDATE CASCADE ON DELETE CASCADE,
  PRIMARY KEY (referendum_type_id, legal_norm_id)
);

CREATE TABLE public.referendum_types_referendums (
  referendum_type_id integer NOT NULL REFERENCES public.referendum_types ON UPDATE CASCADE ON DELETE CASCADE,
  referendum_id      integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  PRIMARY KEY (referendum_type_id, referendum_id)
);

CREATE TABLE public.topics_referendums (
  topic_name    text NOT NULL REFERENCES public.topics ON UPDATE CASCADE ON DELETE CASCADE,
  referendum_id integer NOT NULL REFERENCES public.referendums ON UPDATE CASCADE ON DELETE CASCADE,
  PRIMARY KEY (topic_name, referendum_id)
);

-- Enable RLS and create policies
/* COMMENTED OUT because from R we can't easily write to a table that has RLS *and* a `GENERATED ALWAYS` PK
ALTER TABLE public.referendums      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referendums      FORCE  ROW LEVEL SECURITY;
ALTER TABLE public.referendum_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referendum_types FORCE  ROW LEVEL SECURITY;
CREATE POLICY default_allow          ON public.referendums      AS PERMISSIVE  FOR ALL    TO PUBLIC USING (TRUE);
CREATE POLICY nocodb_restrict_delete ON public.referendums      AS RESTRICTIVE FOR DELETE TO nocodb USING (is_draft);
CREATE POLICY default_allow          ON public.referendum_types AS PERMISSIVE  FOR ALL    TO PUBLIC USING (TRUE);
CREATE POLICY nocodb_restrict_delete ON public.referendum_types AS RESTRICTIVE FOR DELETE TO nocodb USING (is_draft);
*/

-- Create trigger function to ensure `referendum_sub_votes` consistency regarding administrative units
CREATE OR REPLACE FUNCTION check_referendum_sub_votes_administrative_units()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
    DECLARE
      referendum_administrative_unit_id text;
      parent_administrative_unit_id text;
    BEGIN
      -- Get the referendum's administrative unit id
      SELECT administrative_unit_id INTO referendum_administrative_unit_id
      FROM public.referendums
      WHERE id = NEW.referendum_id;

      -- Get the parent administrative unit id
      SELECT parent_id INTO parent_administrative_unit_id
      FROM public.administrative_units
      WHERE id = NEW.administrative_unit_id;

      -- Ensure referendum's administrative unit is the parent of the sub vote's administrative unit
      IF parent_administrative_unit_id IS NULL OR referendum_administrative_unit_id != parent_administrative_unit_id THEN
        RAISE EXCEPTION 'The referendum''s administrative unit must be the parent of the sub vote''s administrative unit.';
      END IF;

      RETURN NEW;
    END;
  $$;

CREATE TRIGGER check_administrative_units
  BEFORE INSERT OR UPDATE ON public.referendum_sub_votes
  FOR EACH ROW EXECUTE PROCEDURE public.check_referendum_sub_votes_administrative_units();

-- Create trigger function to ensure `referendum_types_legal_norms` consistency regarding administrative units
CREATE OR REPLACE FUNCTION check_referendum_types_legal_norms_administrative_units()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
    DECLARE
      rt_au_level text;
      ln_au_level text;
      rt_au_id text;
      ln_au_id text;
      rt_au_parent_id text;
      rt_au_parent_level text;
    BEGIN
      -- Get the required attrs of the administrative unit of the referendum type
      SELECT au.level, au.id, au.parent_id INTO rt_au_level, rt_au_id, rt_au_parent_id
      FROM public.referendum_types rt
      JOIN public.administrative_units au ON rt.administrative_unit_id = au.id
      WHERE rt.id = NEW.referendum_type_id;

      -- Get the required attrs of the administrative unit of the legal instrument associated with the legal norm
      SELECT au.level, au.id INTO ln_au_level, ln_au_id
      FROM public.legal_norms ln
      JOIN public.legal_instruments li ON ln.legal_instrument_display = li.display
      JOIN public.administrative_units au ON li.administrative_unit_id = au.id
      WHERE ln.id = NEW.legal_norm_id;

      -- Condition 1: If levels are equal, administrative units must match
      IF rt_au_level = ln_au_level THEN
        IF NOT EXISTS (
          SELECT 1
          FROM public.referendum_types rt
          JOIN public.legal_norms ln ON NEW.referendum_type_id = rt.id AND NEW.legal_norm_id = ln.id
          JOIN public.legal_instruments li ON ln.legal_instrument_display = li.display
          WHERE rt.administrative_unit_id = li.administrative_unit_id
        ) THEN
          RAISE EXCEPTION 'Administrative units of referendum type and legal norm''s legal instrument must match when on the same political `level`.';
        END IF;

      -- Condition 2: If levels differ, ensure legal norm's level is above referendum type's level
      ELSE
        CASE rt_au_level
          WHEN 'national' THEN
            IF ln_au_level != 'supranational' THEN
              RAISE EXCEPTION 'Administrative unit of the legal norm''s legal instrument cannot be below the referendum type''s administrative unit.';
            END IF;
          WHEN 'subnational' THEN
            IF ln_au_level NOT IN ('supranational', 'national') THEN
              RAISE EXCEPTION 'Administrative unit of the legal norm''s legal instrument cannot be below the referendum type''s administrative unit.';
            END IF;
          ELSE
            -- this empty else statement is necessary to avoid raising `CASE_NOT_FOUND` exception, cf. https://www.postgresql.org/docs/current/plpgsql-control-structures.html#PLPGSQL-CONDITIONALS-SIMPLE-CASE
            NULL;
        END CASE;
      END IF;

      -- Condition 3: Ensure the legal norm's administrative unit is in the parent chain of the referendum type's administrative unit
      LOOP
        EXIT WHEN rt_au_parent_id IS NULL; -- Stop when there are no more parents (i.e., top of the hierarchy)
        SELECT level INTO rt_au_parent_level FROM public.administrative_units WHERE id = rt_au_parent_id;
        IF ln_au_level = rt_au_parent_level AND ln_au_id != rt_au_parent_id THEN
          RAISE EXCEPTION 'The legal norm''s administrative unit must be an ancestor of the referendum type''s administrative unit.';
        END IF;
        SELECT parent_id INTO rt_au_parent_id FROM public.administrative_units WHERE id = rt_au_parent_id;
      END LOOP;

      RETURN NEW;
    END;
  $$;

CREATE TRIGGER check_administrative_units
  BEFORE INSERT OR UPDATE ON public.referendum_types_legal_norms
  FOR EACH ROW EXECUTE PROCEDURE public.check_referendum_types_legal_norms_administrative_units();

-- Create trigger function to ensure `referendum_types_legal_norms` consistency regarding `valid_from` and `valid_to`
CREATE OR REPLACE FUNCTION check_referendum_types_legal_norms_validity_period()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
    DECLARE
      rt_valid_from date;
      rt_valid_to   date;
      ln_valid_from date;
      ln_valid_to   date;
    BEGIN
      -- Get the valid_from and valid_to dates for the referendum type
      SELECT rt.valid_from, rt.valid_to
      INTO rt_valid_from, rt_valid_to
      FROM public.referendum_types rt
      WHERE rt.id = NEW.referendum_type_id;

      -- Get the valid_from and valid_to dates for the legal norm
      SELECT ln.valid_from, ln.valid_to
      INTO ln_valid_from, ln_valid_to
      FROM public.legal_norms ln
      WHERE ln.id = NEW.legal_norm_id;

      -- Condition 1: legal_norms.valid_from <= referendum_types.valid_to
      IF ln_valid_from > rt_valid_to THEN
        RAISE EXCEPTION '`valid_from` of the linked legal norm must be <= `valid_to` of the linked referendum type.';
      END IF;

      -- Condition 2: legal_norms.valid_to >= referendum_types.valid_from
      IF ln_valid_to < rt_valid_from THEN
        RAISE EXCEPTION '`valid_to` of the linked legal norm must be >= `valid_from` of the linked referendum type.';
      END IF;

      RETURN NEW;
    END;
  $$;

CREATE TRIGGER check_validity_period
  BEFORE INSERT OR UPDATE ON public.referendum_types_legal_norms
  FOR EACH ROW EXECUTE PROCEDURE public.check_referendum_types_legal_norms_validity_period();

-- Create trigger function to ensure `referendum_types_referendums` consistency
CREATE OR REPLACE FUNCTION public.check_referendum_types_referendums_administrative_units()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
    BEGIN
      IF NOT (
        SELECT
          rt.administrative_unit_id IS NOT DISTINCT FROM r.administrative_unit_id
        FROM 
          public.referendum_types rt, public.referendums r
        WHERE
          rt."id" = NEW.referendum_type_id AND 
          r."id" = NEW.referendum_id
      ) THEN
        RAISE EXCEPTION 'Administrative units from referendum type and referendum do not match.';
      END IF;

      RETURN NEW;
    END;
  $$;

CREATE TRIGGER check_administrative_units
  BEFORE INSERT OR UPDATE ON public.referendum_types_referendums
  FOR EACH ROW EXECUTE PROCEDURE public.check_referendum_types_referendums_administrative_units();

-- Create functions and triggers to complement `topics_referendums` with parent topics after `INSERT/UPDATE` and clean up child topics after `DELETE`
CREATE OR REPLACE FUNCTION public.add_parent_topic()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
    DECLARE
      parent_topic text;
    BEGIN
      -- Get the parent topic of the newly inserted topic
      SELECT parent_name INTO parent_topic
      FROM public.topics
      WHERE name = NEW.topic_name;

      -- Check if the parent topic exists and insert it if not already present
      IF parent_topic IS NOT NULL THEN
        INSERT INTO public.topics_referendums (topic_name, referendum_id)
        VALUES (parent_topic, NEW.referendum_id)
        ON CONFLICT DO NOTHING;
      END IF;

      RETURN NEW;
    END;
  $$;

CREATE OR REPLACE TRIGGER add_parent_topic
  AFTER INSERT OR UPDATE ON public.topics_referendums
  FOR EACH ROW EXECUTE PROCEDURE public.add_parent_topic();

CREATE OR REPLACE FUNCTION remove_children_topics()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
    DECLARE
      child_topic text;
    BEGIN
      -- Delete all rows in topics_referendums where the topic is a child of the deleted topic
      DELETE FROM public.topics_referendums
      WHERE topic_name IN (
        SELECT name
        FROM public.topics
        WHERE parent_name = OLD.topic_name
      )
      AND referendum_id = OLD.referendum_id;

      RETURN OLD;
    END;
  $$;

CREATE OR REPLACE TRIGGER remove_children_topics
  AFTER DELETE ON public.topics_referendums
  FOR EACH ROW EXECUTE PROCEDURE public.remove_children_topics();

-- Add column labels
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
        EXECUTE format('ALTER TABLE public.%I OWNER TO nocodb', r.table_name);
      END LOOP;
    END;
  $$;
