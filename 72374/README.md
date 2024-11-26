# Reproduce bug with a wrong S3 partitioning

A bug found in https://github.com/ClickHouse/ClickHouse/issues/72374

To reproduce:

```bash
$ docker compose down -v # resets the state
$ docker compose up -d
$ docker compose exec -T clickhouse clickhouse-client << EOF
SET s3_create_new_file_on_insert=1;
insert into s3 values (1);
insert into s3 values (1);
insert into s3 values (1);
insert into source values(2);
insert into source values(2);
insert into source values(2);
EOF
$ > docker compose exec minio mc ls -r minio/clickhouse
[2024-11-26 10:58:25 UTC]    10B STANDARD path/1.1.json
[2024-11-26 10:58:25 UTC]    10B STANDARD path/1.2.json
[2024-11-26 10:58:25 UTC]    10B STANDARD path/1.3.json
[2024-11-26 10:58:00 UTC]    10B STANDARD path/1.json
[2024-11-26 10:58:25 UTC]    10B STANDARD path/{_partition_id}.1.json
[2024-11-26 10:58:25 UTC]    10B STANDARD path/{_partition_id}.2.json
[2024-11-26 10:58:25 UTC]    10B STANDARD path/{_partition_id}.json
```
