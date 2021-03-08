#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	CREATE USER tenejo;
	CREATE DATABASE tenejo_dev;
  CREATE DATABASE tenejo_test;
EOSQL
