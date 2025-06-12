WITH
    a AS
    (
        SELECT
            product_id,
            procurement_status_group,
            dateDiff('month', source_date, start_date) AS m,
            sum(IF(fcst_type = 'manual', fcst_value, 0)) AS manual,
            sum(IF(fcst_type = 'system', fcst_value, 0)) AS system,
            if(manual > 0, manual, system) AS final
        FROM
        (
            SELECT *
            FROM ods.fcst_sales AS fs
            WHERE ((fcst_type, source_date) IN (
                SELECT
                    fcst_type,
                    max(source_date)
                FROM ods.fcst_sales
                WHERE ((fcst_type = 'manual') AND (fcst_note ILIKE '%S&OP Fcst%')) OR (fcst_type = 'system')
                GROUP BY fcst_type
            )) AND ((dateDiff('month', source_date, start_date) >= 1) AND (dateDiff('month', source_date, start_date) <= 5))
        ) AS f
        LEFT JOIN dws.dim_channel_1d AS dcd ON dcd.channel_id = f.channel_id
        GROUP BY
            product_id,
            procurement_status_group,
            m
    ),
    t1 AS
    (
        SELECT
            product_id,
            procurement_status_group,
            final AS m1
        FROM a
        WHERE m = 1
    ),
    t2 AS
    (
        SELECT
            product_id,
            procurement_status_group,
            final AS m2
        FROM a
        WHERE m = 2
    ),
    t3 AS
    (
        SELECT
            product_id,
            procurement_status_group,
            final AS m3
        FROM a
        WHERE m = 3
    ),
    t4 AS
    (
        SELECT
            product_id,
            procurement_status_group,
            final AS m4
        FROM a
        WHERE m = 4
    ),
    t5 AS
    (
        SELECT
            product_id,
            procurement_status_group,
            final AS m5
        FROM a
        WHERE m = 5
    ),
    `5m` AS
    (
        SELECT *
        FROM t1
        LEFT JOIN t2 ON (t1.product_id = t2.product_id) AND (t1.procurement_status_group = t2.procurement_status_group)
        LEFT JOIN t3 ON (t1.product_id = t3.product_id) AND (t1.procurement_status_group = t3.procurement_status_group)
        LEFT JOIN t4 ON (t1.product_id = t4.product_id) AND (t1.procurement_status_group = t4.procurement_status_group)
        LEFT JOIN t5 ON (t1.product_id = t5.product_id) AND (t1.procurement_status_group = t5.procurement_status_group)
    )
SELECT
    t1.product_id AS product_id,
    t1.procurement_status_group AS channel,
    sum(m1) AS m1,
    SUM(m2) AS m2,
    sum(m3) AS m3,
    sum(m4) AS m4,
    sum(m5) AS m5
FROM `5m`
GROUP BY
    product_id,
    channel
