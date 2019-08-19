-- See all processes blocking process with a specified application_name
WITH blocked_query AS (
    SELECT * FROM pg_stat_activity WHERE waiting AND application_name ilike '%alembic%'
)
SELECT
    blocked.pid AS "Blocked PID",
    blocked.application_name AS "Blocked App",
    dep_query.application_name,
    dep_query.pid,
    dep_query.state_change,
    dep_query.query
FROM
    blocked_query blocked,
    pg_locks blocked_lock,
    pg_locks dep_lock,
    pg_stat_activity dep_query
WHERE
    blocked_lock.pid = blocked.pid
    AND NOT blocked_lock.granted
    AND (
        -- curiously, all four constraints make the query slow..
        dep_lock.relation = blocked_lock.relation
        --OR dep_lock.tuple = blocked_lock.tuple
        OR dep_lock.virtualxid = blocked_lock.virtualxid
        OR dep_lock.transactionid = blocked_lock.transactionid
    )
    AND dep_lock.pid != blocked.pid
    AND dep_lock.granted
    AND dep_query.pid = dep_lock.pid;
