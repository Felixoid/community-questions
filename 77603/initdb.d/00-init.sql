CREATE DATABASE IF NOT EXISTS fcst;
CREATE DATABASE IF NOT EXISTS ods;

-- show create view ods.fcst_sales
CREATE VIEW ods.fcst_sales
(
    `fcst_sales_id` UUID,
    `channel_id` Int64,
    `product_id` Int32,
    `fcst_type` String,
    `fcst_source` String,
    `source_date` Date,
    `start_date` Date,
    `end_date` Date,
    `fcst_value` Float64,
    `user_email` String,
    `fcst_note` String,
    `created_time` DateTime
)
AS SELECT
    fcst_sales_id,
    if(channel_id = 214401, 318801, channel_id) AS channel_id,
    product_id,
    fcst_type,
    fcst_source,
    source_date,
    start_date,
    end_date,
    fcst_value,
    user_email,
    fcst_note,
    created_time
FROM fcst.fcst_sales;


-- show create table fcst.fcst_sales

CREATE TABLE fcst.fcst_sales
(
    `fcst_sales_id` UUID DEFAULT generateUUIDv4(),
    `channel_id` Int32 
    `product_id` Int32 
    `fcst_type` String 
    `fcst_source` String 
    `source_date` Date DEFAULT today() 
    `start_date` Date 
    `end_date` Date 
    `fcst_value` Float64 
    `user_email` String 
    `fcst_note` String 
    `created_time` DateTime DEFAULT now() 
    INDEX index_channel_id channel_id TYPE minmax GRANULARITY 8192,
    INDEX index_product_id product_id TYPE minmax GRANULARITY 8192,
    INDEX index_fcst_type fcst_type TYPE minmax GRANULARITY 8192,
    INDEX index_source_date source_date TYPE minmax GRANULARITY 8192,
    INDEX index_start_date start_date TYPE minmax GRANULARITY 8192
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{uuid}/{shard}', '{replica}')
PARTITION BY toYear(source_date)
ORDER BY (product_id, channel_id, source_date)
SETTINGS index_granularity = 8192



-- show create view dws.dim_channel_1d
CREATE VIEW dws.dim_channel_1d
(
    `date_id` Int32,
    `channel_id` Int32,
    `channel_description` String,
    `platform` LowCardinality(String),
    `account_name` String,
    `country` LowCardinality(String),
    `region` String,
    `fulfillment_type` LowCardinality(String),
    `account_id` Nullable(String),
    `sales_channel_id` UInt16,
    `efc_channel_id` Nullable(String),
    `channel_group` String,
    `procurement_status_group` String,
    `channel_status` LowCardinality(String),
    `language` String,
    `currency` LowCardinality(String),
    `size_uom` String,
    `weight_uom` String,
    `channel_group_bi_1` LowCardinality(String),
    `channel_group_bi_2` LowCardinality(String),
    `channel_group_bi_3` LowCardinality(String),
    `original_ownership` LowCardinality(Nullable(String)),
    `ma_date` Nullable(Date),
    `note` Nullable(String),
    `uds_load_date` Date,
    `uds_load_time` DateTime,
    `uds_ch_sign` Int8
)
AS SELECT *
FROM dws.dim_channel
WHERE date_id = (
    SELECT max(date_id)
    FROM dws.dim_channel
)

-- show create table dws.dim_channel
CREATE TABLE dws.dim_channel
(
    `date_id` Int32 DEFAULT toYYYYMMDD(today()) 
    `channel_id` Int32 
    `channel_description` String 
    `platform` LowCardinality(String) 
    `account_name` String 
    `country` LowCardinality(String) 
    `region` String 
    `fulfillment_type` LowCardinality(String) 
    `account_id` Nullable(String) 
    `sales_channel_id` UInt16 
    `efc_channel_id` Nullable(String) 
    `channel_group` String 
    `procurement_status_group` String 
    `channel_status` LowCardinality(String) 
    `language` String 
    `currency` LowCardinality(String) 
    `size_uom` String 
    `weight_uom` String 
    `channel_group_bi_1` LowCardinality(String) 
    `channel_group_bi_2` LowCardinality(String) 
    `channel_group_bi_3` LowCardinality(String) 
    `original_ownership` LowCardinality(Nullable(String)) 
    `ma_date` Nullable(Date) 
    `note` Nullable(String) 
    `uds_load_date` Date DEFAULT today() 
    `uds_load_time` DateTime DEFAULT now() 
    `uds_ch_sign` Int8 DEFAULT 1  
)
ENGINE = ReplicatedCollapsingMergeTree('/clickhouse/tables/{uuid}/{shard}', '{replica}', uds_ch_sign)
ORDER BY (channel_id, date_id)
SETTINGS index_granularity = 8192

