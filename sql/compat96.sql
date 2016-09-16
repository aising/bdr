--- emulate the pg_xlog_wait_remote_apply on vanilla postgres
SELECT bdr.bdr_replicate_ddl_command($DDL$
CREATE OR REPLACE FUNCTION public.pg_xlog_wait_remote_apply(i_pos pg_lsn, i_pid integer) RETURNS VOID
AS $FUNC$
BEGIN
    WHILE EXISTS(SELECT true FROM pg_stat_get_wal_senders() s WHERE s.flush_location < i_pos AND (i_pid = 0 OR s.pid = i_pid)) LOOP
	PERFORM pg_sleep(0.01);
    END LOOP;
END;$FUNC$ LANGUAGE plpgsql;
$DDL$);

SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location(), 0);