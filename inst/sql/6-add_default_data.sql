/*

# Add default data

## Relevant documentation

- [INSERT](https://www.postgresql.org/docs/current/sql-insert.html)

*/

-- Switch to `rdb_admin` role (errors if not authorized)
SET ROLE rdb_admin;

--- Add default rows
INSERT INTO public.referendum_types (is_draft, title, are_empty_votes_counted) VALUES (FALSE, 'tie-breaker question', FALSE);

INSERT INTO public.actors (label, description) VALUES ('government',         'executive body of the political system');
INSERT INTO public.actors (label, description) VALUES ('parliament',         'legislative body of the political system');
INSERT INTO public.actors (label, description) VALUES ('citizens',           'all individuals in the political system with active political rights');
INSERT INTO public.actors (label, description) VALUES ('sub-level entity',   'administrative unit below the level of the political system');
INSERT INTO public.actors (label, description) VALUES ('supra-level entity', 'administrative unit above the level of the political system');

INSERT INTO public.options (label, description) VALUES ('yes',     'approval of the referendum proposal');
INSERT INTO public.options (label, description) VALUES ('no',      'rejection of the referendum proposal');
INSERT INTO public.options (label, description) VALUES ('empty',   'explicit abstention from voting on the referendum proposal');
INSERT INTO public.options (label, description) VALUES ('invalid', 'formally invalid vote cast on the referendum proposal');

--- Set default values
UPDATE public.administrative_units SET guarantees_referendum_id_official = TRUE WHERE "id" IN ('CH');
