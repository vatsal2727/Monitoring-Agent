--SQL script to create two tables "host_info" and "host_usage" if they do not already exist.

--connect to the host_agent database assuming that it is already created;
 \c host_agent;

--create host_info table if not already exist
CREATE TABLE IF NOT EXISTS PUBLIC.host_info
  (
     id               SERIAL PRIMARY KEY,
     hostname         VARCHAR UNIQUE NOT NULL,
     cpu_number       INTEGER NOT NULL,
     cpu_architecture VARCHAR NOT NULL,
     cpu_model        VARCHAR NOT NULL,
     cpu_mhz          DECIMAL NOT NULL,
     L2_cache         INTEGER NOT NULL,
     total_mem        INTEGER NOT NULL,
     timestamp        TIMESTAMP NOT NULL
  );

--create host_usage if not already exist
 CREATE TABLE IF NOT EXISTS PUBLIC.host_usage
  (
     timestamp      TIMESTAMP NOT NULL,
     host_id        SERIAL REFERENCES host_info(id),
     memory_free    INTEGER NOT NULL,
     cpu_idle       INTEGER NOT NULL,
     cpu_kernel     INTEGER NOT NULL,
     disk_io        INTEGER NOT NULL,
     disk_available INTEGER NOT NULL
  );