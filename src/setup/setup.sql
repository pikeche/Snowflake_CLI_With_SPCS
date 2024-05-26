USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS tutorial_cicd_role;

CREATE DATABASE IF NOT EXISTS tutorial_cicd_db;
GRANT OWNERSHIP ON DATABASE tutorial_cicd_db TO ROLE tutorial_cicd_role;
GRANT OWNERSHIP ON SCHEMA tutorial_cicd_db.public TO ROLE tutorial_cicd_role;


CREATE OR REPLACE WAREHOUSE tutorial_cicd_wh WITH
  WAREHOUSE_SIZE='X-SMALL';
GRANT USAGE ON WAREHOUSE tutorial_cicd_wh TO ROLE tutorial_cicd_role;


CREATE SECURITY INTEGRATION IF NOT EXISTS snowservices_ingress_oauth
  TYPE=oauth
  OAUTH_CLIENT=snowservices_ingress
  ENABLED=true;

GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE tutorial_cicd_role;

CREATE COMPUTE POOL if not exists tutorial_cicd_compute_pool
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_XS;

GRANT USAGE, MONITOR ON COMPUTE POOL tutorial_cicd_compute_pool TO ROLE tutorial_cicd_role;

EXECUTE IMMEDIATE $$
DECLARE
    username varchar;
    stmt varchar;
BEGIN
    Select current_user() into :username;
    stmt := 'GRANT ROLE tutorial_cicd_role TO USER ' || :username;
    execute immediate stmt;
    return 'role assigned';
END;
$$
;

use role tutorial_cicd_role;
use database tutorial_cicd_db;
use warehouse tutorial_cicd_wh;
Drop service if exists STREAMLIT_SPCS;