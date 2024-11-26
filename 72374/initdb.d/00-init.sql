-- stream

CREATE TABLE s3 (
  `p` Int64
)
ENGINE = S3('http://minio:9000/clickhouse/path/{_partition_id}.json', 'minioadmin', 'minioadmin', 'JSONEachRow')
partition by p
SETTINGS s3_create_new_file_on_insert=1;

-- table

CREATE TABLE source
(
    `s` Int64
) ENGINE = MergeTree()
partition by tuple()
order by tuple();

--- view

create materialized view mv to s3 as select s as p from source;
