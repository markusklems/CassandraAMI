#!/bin/sh -ex
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

  CREATE_TABLE_STATEMENTS=/home/ubuntu/create_usertable

  cat >$CREATE_TABLE_STATEMENTS <<END_OF_FILE
create keyspace usertable with strategy_options = [{replication_factor:1}] and placement_strategy = 'org.apache.cassandra.locator.SimpleStrategy';
use usertable;
create column family data with comparator='AsciiType';
END_OF_FILE
  
  cassandra-cli -f $CREATE_TABLE_STATEMENTS