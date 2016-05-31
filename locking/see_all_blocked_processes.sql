-- All blocked processes.
SELECT
    blocked_locks.pid AS blocked_pid,
    blocking_locks.pid AS blocking_pid,
    blocked_activity.application_name AS blocked_application,
    blocking_activity.application_name AS blocking_application,
    substring(blocked_activity.query, 1, 40) AS blocked_query,
    blocked_activity.state,
    substring(blocking_activity.query, 1, 40) AS current_query_in_blocking_process,
    blocking_activity.state
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON
    blocking_locks.locktype = blocked_locks.locktype AND
    blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE AND
    blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation AND
    blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page AND
    blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple AND
    blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid AND
    blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid AND
    blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid AND
    blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid AND
    blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid AND
    blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.GRANTED;