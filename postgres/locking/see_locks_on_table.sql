-- All things locking a specific table
select
    pgc.relname as "TABLE",
    pgs.application_name as "APP NAME",
    pgs.client_addr as "CLIENT ADDR",
    pgs.backend_start as "BACKEND START",
    pgs.query_start as "Q START",
    pgl.locktype as "LOCKTYPE",
    pgl.pid as "PID",
    pgl.transactionid as "TRANSACTIONID",
    pgl.classid as "CLASSID",
    pgl.objid as "OBJID",
    pgl.objsubid as "OBJSUBID",
    pgl.virtualtransaction as "VIRTUALTRANSACTION",
    pgl.mode as "MODE",
    -- pgl.granted as "GRANTED",
    pgs.state as "STATE",
    substring(pgs.query from 0 for 100) as "QUERY"
from
    pg_locks pgl,
    pg_class pgc,
    pg_stat_activity pgs
where
    pgc.oid = pgl.relation
    and pgl.pid = pgs.pid
    and pgc.relname = 'table_name'
order by
    pgs.backend_start desc;

