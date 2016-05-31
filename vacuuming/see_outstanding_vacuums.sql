SELECT
    count(nullif((pt.n_tup_del + pt.n_tup_upd) > pgs_threshold.setting::int + (pgs_scale.setting::float * pc.reltuples), false)) as pending_vacume,
    count(1)
FROM
    pg_class pc
JOIN
    pg_stat_all_tables pt ON pc.relname = pt.relname
CROSS JOIN
    pg_settings pgs_threshold
CROSS JOIN
    pg_settings pgs_scale
WHERE
    pgs_threshold.name = 'autovacuum_vacuum_threshold'
    AND pgs_scale.name = 'autovacuum_vacuum_scale_factor';