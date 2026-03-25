-- =========================================
-- PART A: COMMIT vs ROLLBACK demonstration
-- =========================================

-- Check original value first
SELECT event_id, event_title, capacity
FROM events
WHERE event_id = 1;

-- ROLLBACK DEMO
BEGIN;

UPDATE events
SET capacity = 55
WHERE event_id = 1;

SELECT event_id, event_title, capacity
FROM events
WHERE event_id = 1;

ROLLBACK;

SELECT event_id, event_title, capacity
FROM events
WHERE event_id = 1;

-- COMMIT DEMO
BEGIN;

UPDATE events
SET capacity = 60
WHERE event_id = 1;

SELECT event_id, event_title, capacity
FROM events
WHERE event_id = 1;

COMMIT;

SELECT event_id, event_title, capacity
FROM events
WHERE event_id = 1;

-- =========================================
-- PART B: Blocking / locking demonstration
-- Run these in TWO separate SQL sessions
-- =========================================

-- SESSION A
BEGIN;
UPDATE events
SET capacity = 65
WHERE event_id = 2;
-- Leave this transaction open and do not commit yet

-- SESSION B
BEGIN;
UPDATE events
SET capacity = 75
WHERE event_id = 2;
-- This should wait until Session A finishes

-- SESSION C or another tab for diagnostics
SELECT pid, state, wait_event_type, wait_event, query
FROM pg_stat_activity
WHERE datname = current_database()
ORDER BY pid;

-- Optional blocking detail
SELECT pid, pg_blocking_pids(pid) AS blocked_by, query
FROM pg_stat_activity
WHERE datname = current_database()
ORDER BY pid;

-- Then go back to SESSION A
COMMIT;

-- Then SESSION B should continue
COMMIT;

-- Verify final value
SELECT event_id, event_title, capacity
FROM events
WHERE event_id = 2;

-- =========================================
-- PART C: Admin/Ops control
-- Roles and grants setup
-- =========================================

-- Create a reporting role
CREATE ROLE report_reader NOLOGIN;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO report_reader;

-- Grant select permissions on tables
GRANT SELECT ON students TO report_reader;
GRANT SELECT ON events TO report_reader;
GRANT SELECT ON registrations TO report_reader;

-- Verification queries
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'report_reader'
ORDER BY table_name, privilege_type;

-- =========================================
-- PART D: Schema introspection / verification
-- =========================================

SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name IN ('students', 'events', 'registrations')
ORDER BY table_name, ordinal_position;
