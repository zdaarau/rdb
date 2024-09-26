/*

# Run post-NocoDB meta column creation steps

Alters meta columns which were created (and thus are auto-filled) by NocoDB

## Assumptions

- The columns `created_by`, `updated_by`, `created_at` and `updated_at` were freshly created from NocoDB *after* `init_main_tbls.sql` has been run (so they get
  auto-filled).

## Notes

- Column names equal to [reserved PostgreSQL keywords](https://www.postgresql.org/docs/current/sql-keywords-appendix.html) are preventively quoted.

- There mustn't be any column constraints for `created_by` and `updated_by` in order for them to keep working as supposed (but `DEFAULT`s are fine). If changed,
  NocoDB will detect a column type or attribute change during metadata sync and stop updating them automatically on insert/update.

- The columns `created_at` and `updated_at` must come last for NocoDB to be hidden as "system fields" until
  [nocodb/nocodb#6476](https://github.com/nocodb/nocodb/issues/6476) has been resolved.

## Relevant documentation

- [Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)

*/

-- Switch to `rdb_admin` role (errors if not authorized)
SET ROLE rdb_admin;

-- 
DO LANGUAGE plpgsql
  $$
    DECLARE
      r record;
    BEGIN
      FOR r IN SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'
      LOOP
        EXECUTE format('ALTER TABLE public.%I ALTER COLUMN created_at SET DATA TYPE timestamp with time zone', r.table_name);
        EXECUTE format('ALTER TABLE public.%I ALTER COLUMN updated_at SET DATA TYPE timestamp with time zone', r.table_name);
        EXECUTE format('ALTER TABLE public.%I ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP', r.table_name);
        EXECUTE format('ALTER TABLE public.%I ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP', r.table_name);
        EXECUTE format('ALTER TABLE public.%I ALTER COLUMN created_by SET DEFAULT CURRENT_USER', r.table_name);
        EXECUTE format('ALTER TABLE public.%I ALTER COLUMN updated_by SET DEFAULT CURRENT_USER', r.table_name);
        EXECUTE format('ALTER TABLE public.%I ADD CONSTRAINT %I_check_updated_at_gt_created_at CHECK (updated_at >= created_at)', r.table_name, r.table_name);
      END LOOP;
    END;
  $$;

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

/* Revoke write privileges from 'nocodb' for autofilled tables */
/* COMMENTED OUT for now due to issues with updating tables (certain actions are always performed as table owner which is currently `nocodb`)
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
                               'languages']
      LOOP
        EXECUTE format('REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON public.%I FROM nocodb', t);
      END LOOP;
    END;
  $$;
*/

-- Enable RLS and create policies to avoid edits from NocoDB (alternative to revoking privileges)
ALTER TABLE public.administrative_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.administrative_units FORCE  ROW LEVEL SECURITY;
ALTER TABLE public.languages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.languages FORCE  ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics FORCE  ROW LEVEL SECURITY;
CREATE POLICY default_allow          ON public.administrative_units AS PERMISSIVE  FOR ALL    TO PUBLIC USING (TRUE);
CREATE POLICY nocodb_restrict_insert ON public.administrative_units AS RESTRICTIVE FOR INSERT TO nocodb               WITH CHECK (FALSE);
CREATE POLICY nocodb_restrict_update ON public.administrative_units AS RESTRICTIVE FOR UPDATE TO nocodb USING (FALSE) WITH CHECK (FALSE);
CREATE POLICY nocodb_restrict_delete ON public.administrative_units AS RESTRICTIVE FOR DELETE TO nocodb USING (FALSE);
CREATE POLICY default_allow          ON public.languages            AS PERMISSIVE  FOR ALL    TO PUBLIC USING (TRUE);
CREATE POLICY nocodb_restrict_insert ON public.languages            AS RESTRICTIVE FOR INSERT TO nocodb               WITH CHECK (FALSE);
CREATE POLICY nocodb_restrict_update ON public.languages            AS RESTRICTIVE FOR UPDATE TO nocodb USING (FALSE) WITH CHECK (FALSE);
CREATE POLICY nocodb_restrict_delete ON public.languages            AS RESTRICTIVE FOR DELETE TO nocodb USING (FALSE);
CREATE POLICY default_allow          ON public.topics               AS PERMISSIVE  FOR ALL    TO PUBLIC USING (TRUE);
CREATE POLICY nocodb_restrict_insert ON public.topics               AS RESTRICTIVE FOR INSERT TO nocodb               WITH CHECK (FALSE);
CREATE POLICY nocodb_restrict_update ON public.topics               AS RESTRICTIVE FOR UPDATE TO nocodb USING (FALSE) WITH CHECK (FALSE);
CREATE POLICY nocodb_restrict_delete ON public.topics               AS RESTRICTIVE FOR DELETE TO nocodb USING (FALSE);
