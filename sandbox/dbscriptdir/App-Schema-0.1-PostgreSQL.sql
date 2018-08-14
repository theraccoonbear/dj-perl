-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Aug 14 03:01:08 2018
-- 
--
-- Table: users
--
DROP TABLE users CASCADE;
CREATE TABLE users (
  id serial NOT NULL,
  username text NOT NULL,
  pass_hash text NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT users_username UNIQUE (username)
);

