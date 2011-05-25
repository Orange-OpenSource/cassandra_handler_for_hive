SET hive.support.concurrency=false;

DROP TABLE cassandra_hive_table;
CREATE EXTERNAL TABLE
cassandra_hive_table(key int, value string)
STORED BY 'org.apache.hadoop.hive.cassandra.CassandraStorageHandler'
WITH SERDEPROPERTIES ("cassandra.columns.mapping" = ":key,value" , "cassandra.cf.name" = "Table" , "cassandra.host" = "127.0.0.1" , "cassandra.port" = "9160", "cassandra.partitioner" = "org.apache.cassandra.dht.RandomPartitioner" )
TBLPROPERTIES ("cassandra.ks.name" = "Hive", "cassandra.ks.repfactor" = "1", "cassandra.ks.strategy" = "org.apache.cassandra.locator.SimpleStrategy", "cassandra.input.split.size" = "64000", "cassandra.range.size" = "100");

DESCRIBE cassandra_hive_table;

select * from cassandra_hive_table;

EXPLAIN FROM src INSERT OVERWRITE TABLE cassandra_hive_table SELECT * WHERE (key%7)=0 ORDER BY key;
FROM src INSERT OVERWRITE TABLE cassandra_hive_table SELECT * WHERE (key%7)=0 ORDER BY key;

EXPLAIN select * from cassandra_hive_table ORDER BY key;
select * from cassandra_hive_table ORDER BY key;

EXPLAIN select key from cassandra_hive_table ORDER BY key;
select key from cassandra_hive_table ORDER BY key;

EXPLAIN select value from cassandra_hive_table ORDER BY VALUE;
select value from cassandra_hive_table ORDER BY VALUE;

EXPLAIN select a.key,a.value,b.value from cassandra_hive_table a JOIN cassandra_hive_table b on a.key=b.key ORDER BY a.key;
select a.key,a.value,b.value from cassandra_hive_table a JOIN cassandra_hive_table b on a.key=b.key ORDER BY a.key;

EXPLAIN
SELECT Y.*
FROM
(SELECT cassandra_hive_table.* FROM cassandra_hive_table) x
JOIN
(SELECT src.* FROM src) Y
ON (x.key = Y.key)
ORDER BY key, value LIMIT 20;

SELECT Y.*
FROM
(SELECT cassandra_hive_table.* FROM cassandra_hive_table) x
JOIN
(SELECT src.* FROM src) Y
ON (x.key = Y.key)
ORDER BY key, value LIMIT 20;

DROP TABLE cassandra_hive_table2;
CREATE EXTERNAL TABLE cassandra_hive_table2(key int, value string)
STORED BY 'org.apache.hadoop.hive.cassandra.CassandraStorageHandler'
WITH SERDEPROPERTIES ("cassandra.cf.name" = "Table2" , "cassandra.host" = "127.0.0.1" , "cassandra.port" = "9160", "cassandra.partitioner" = "org.apache.cassandra.dht.RandomPartitioner" )
TBLPROPERTIES ("cassandra.ks.name" = "Hive", "cassandra.ks.repfactor" = "1", "cassandra.ks.strategy" = "org.apache.cassandra.locator.SimpleStrategy");

EXPLAIN
SELECT Y.*
FROM
(SELECT cassandra_hive_table.* FROM cassandra_hive_table WHERE cassandra_hive_table.key > 100) x
JOIN
(SELECT cassandra_hive_table2.* FROM cassandra_hive_table2 WHERE cassandra_hive_table2.key < 120) Y
ON (x.key = Y.key)
ORDER BY key, value;

SELECT Y.*
FROM
(SELECT cassandra_hive_table.* FROM cassandra_hive_table WHERE cassandra_hive_table.key > 100) x
JOIN
(SELECT cassandra_hive_table2.* FROM cassandra_hive_table2 WHERE cassandra_hive_table2.key < 120) Y
ON (x.key = Y.key)
ORDER BY key,value;

DROP TABLE empty_cassandra_table;
CREATE EXTERNAL TABLE empty_cassandra_table(key int, value string)
STORED BY 'org.apache.hadoop.hive.cassandra.CassandraStorageHandler'
WITH SERDEPROPERTIES ("cassandra.cf.name" = "emptyTable" , "cassandra.host" = "127.0.0.1" , "cassandra.port" = "9160", "cassandra.partitioner" = "org.apache.cassandra.dht.RandomPartitioner" )
TBLPROPERTIES ("cassandra.ks.name" = "Hive", "cassandra.ks.repfactor" = "1", "cassandra.ks.strategy" = "org.apache.cassandra.locator.SimpleStrategy");

DROP TABLE empty_normal_table;
CREATE TABLE empty_normal_table(key int, value string);

select * from (select count(1) as c from empty_normal_table union all select count(1) as c from empty_cassandra_table) x order by c;
select * from (select count(1) c from empty_normal_table union all select count(1) as c from empty_cassandra_table) x order by c;
select * from (select count(1) c from src union all select count(1) as c from empty_cassandra_table) x order by c;
select * from (select count(1) c from src union all select count(1) as c from cassandra_hive_table) x order by c;

DROP TABLE cassandra_hive_table3;
CREATE EXTERNAL TABLE cassandra_hive_table3(key int, value string, count int)
STORED BY 'org.apache.hadoop.hive.cassandra.CassandraStorageHandler'
WITH SERDEPROPERTIES ("cassandra.columns.mapping" = ":key,value,count" , "cassandra.cf.name" = "Table3" , "cassandra.host" = "127.0.0.1" , "cassandra.port" = "9160", "cassandra.partitioner" = "org.apache.cassandra.dht.RandomPartitioner" )
TBLPROPERTIES ("cassandra.ks.name" = "Hive", "cassandra.ks.repfactor" = "1", "cassandra.ks.strategy" = "org.apache.cassandra.locator.SimpleStrategy");

EXPLAIN
INSERT OVERWRITE TABLE cassandra_hive_table3
SELECT x.key, x.value, Y.count
FROM
(SELECT cassandra_hive_table.* FROM cassandra_hive_table) x
JOIN
(SELECT src.key, count(src.key) as count FROM src GROUP BY src.key) Y
ON (x.key = Y.key);

INSERT OVERWRITE TABLE cassandra_hive_table3
SELECT x.key, x.value, Y.count
FROM
(SELECT cassandra_hive_table.* FROM cassandra_hive_table) x
JOIN
(SELECT src.key, count(src.key) as count FROM src GROUP BY src.key) Y
ON (x.key = Y.key);

select count(1) from cassandra_hive_table3;
select * from cassandra_hive_table3 order by key, value limit 5;
select key, count from cassandra_hive_table3 order by key, count desc limit 5;

DROP TABLE cassandra_hive_table4;
CREATE EXTERNAL TABLE cassandra_hive_table4(key int, value1 string, value2 int, value3 int)
STORED BY 'org.apache.hadoop.hive.cassandra.CassandraStorageHandler'
WITH SERDEPROPERTIES ("cassandra.columns.mapping" = ":key,value1,value2,value3" , "cassandra.cf.name" = "Table4" , "cassandra.host" = "127.0.0.1" , "cassandra.port" = "9160", "cassandra.partitioner" = "org.apache.cassandra.dht.RandomPartitioner" )
TBLPROPERTIES ("cassandra.ks.name" = "Hive", "cassandra.ks.repfactor" = "1", "cassandra.ks.strategy" = "org.apache.cassandra.locator.SimpleStrategy");

INSERT OVERWRITE TABLE cassandra_hive_table4 SELECT key, value, key+1, key+2
FROM src WHERE key=98 OR key=100;

SELECT * FROM cassandra_hive_table4 ORDER BY key;

DROP TABLE cassandra_hive_table5;
CREATE EXTERNAL TABLE cassandra_hive_table5(key int, value map<string,string>)
STORED BY 'org.apache.hadoop.hive.cassandra.CassandraStorageHandler'
WITH SERDEPROPERTIES ("cassandra.cf.name" = "Table5" , "cassandra.host" = "127.0.0.1" , "cassandra.port" = "9160", "cassandra.partitioner" = "org.apache.cassandra.dht.RandomPartitioner" )
TBLPROPERTIES ("cassandra.ks.name" = "Hive", "cassandra.ks.repfactor" = "1", "cassandra.ks.strategy" = "org.apache.cassandra.locator.SimpleStrategy");

INSERT OVERWRITE TABLE cassandra_hive_table5 SELECT key, map(value, key) FROM src
WHERE key=98 OR key=100;

SELECT * FROM cassandra_hive_table5 ORDER BY key;

DROP TABLE cassandra_hive_table;
DROP TABLE cassandra_hive_table2;
DROP TABLE cassandra_hive_table3;
DROP TABLE cassandra_hive_table4;
DROP TABLE cassandra_hive_table5;
DROP TABLE empty_cassandra_table;