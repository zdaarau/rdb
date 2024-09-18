/*

# Reset database

## Assumptions

- The PostgreSQL role `rdb_admin` has already been created in the Neon Console, API or CLI, so that it is granted membership in the [`neon_superuser`
  role](https://neon.tech/docs/manage/roles#the-neonsuperuser-role).

## Relevant documentation

- [SQL Key Words](https://www.postgresql.org/docs/current/sql-keywords-appendix.html)
- [DROP DATABASE](https://www.postgresql.org/docs/16/sql-dropdatabase.html)
- [CREATE DATABASE](https://www.postgresql.org/docs/16/sql-createdatabase.html)

*/

-- Switch to `rdb_admin` role (errors if not authorized)
SET ROLE rdb_admin;

-- Disable printing `NOTICE`s during this session
SET client_min_messages TO WARNING;

-- Drop possibly existing DB
DROP DATABASE IF EXISTS rdb WITH (FORCE);

-- Create fresh DB
CREATE DATABASE rdb WITH OWNER rdb_admin;
