drop database IF EXISTS tigerevents;
create database tigerevents;
connect tigerevents;
source tables.sql;
source dummyData.sql;
drop database IF EXISTS tigerevents_test;
create database tigerevents_test;
connect tigerevents_test;
source tables.sql;
source dummyData.sql;
drop database IF EXISTS tigerevents_dev;
create database tigerevents_dev;
connect tigerevents_dev;
source tables.sql;
source dummyData.sql;
