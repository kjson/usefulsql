-- Gets all transactions locking any table. this also includes blocking relionships.
SELECT
    a.txn_owner AS "TXN Owner",
    a.txn_db AS "TXN Database",
    a.xid AS "TXN ID",
    a.pid AS "PID",
    SUBSTRING(r.query, 1, 30) AS "QUERY",
    a.txn_start AS "TXT Start",
    a.lock_mode AS "Lock Mode",
    CASE
        WHEN a.lock_mode = 'AccessExclusiveLock' THEN 'AccessExclusiveLock,ShareRowExclusiveLock,AccessShareLock'
        WHEN a.lock_mode = 'AccessShareLock' THEN 'AccessExclusiveLock'
        WHEN a.lock_mode = 'ShareRowExclusiveLock' THEN 'AccessExclusiveLock,ShareRowExclusiveLock'
    END AS "Blocks",
    a.relation AS "Table ID",
    NVL(TRIM(c."name"),d.relname) AS "Table Name",
    a.granted AS "Lock Granted?",
    b.pid as "Blocking PID",
    DATEDIFF(s, a.txn_start, GETDATE()) / 86400
      || ' days '
      || DATEDIFF(s, a.txn_start, GETDATE()) % 86400 / 3600
      || ' hrs '
      || DATEDIFF(s, a.txn_start, GETDATE()) % 3600 / 60
      || ' mins '
      || DATEDIFF(s, a.txn_start, GETDATE()) % 60
      || ' secs' AS "TXN Duration"
FROM svv_transactions a
LEFT JOIN (
    SELECT pid, relation, granted
    FROM pg_locks
    GROUP BY 1,2,3
    ) b 
ON a.relation = b.relation AND a.granted = 'f' AND b.granted = 't' 
LEFT JOIN (
    SELECT *
    FROM stv_tbl_perm
    WHERE slice = 0
    ) c
ON a.relation = c.id
LEFT JOIN pg_clASs d ON a.relation = d.oid
LEFT JOIN stv_recents r ON r.pid = a.pid
WHERE a.relation IS NOT NULL
ORDER BY DATEDIFF(s, a.txn_start, GETDATE()) DESC;
