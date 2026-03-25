-- Query 1: Join query
-- Show student names and the events they registered for
SELECT s.full_name, e.event_title, r.status
FROM registrations r
JOIN students s ON r.student_id = s.student_id
JOIN events e ON r.event_id = e.event_id
ORDER BY s.full_name;

-- Query 2: Join query
-- Show event title, date, and student email
SELECT e.event_title, e.event_date, s.email
FROM registrations r
JOIN events e ON r.event_id = e.event_id
JOIN students s ON r.student_id = s.student_id
ORDER BY e.event_date;

-- Query 3: Aggregate/grouping query
-- Count registrations for each event
SELECT e.event_title, COUNT(r.registration_id) AS registration_count
FROM events e
LEFT JOIN registrations r ON e.event_id = r.event_id
GROUP BY e.event_title
ORDER BY registration_count DESC, e.event_title;

-- Query 4: CTE query
-- Show students registered for more than one event
WITH student_event_counts AS (
    SELECT student_id, COUNT(*) AS total_events
    FROM registrations
    WHERE status = 'registered'
    GROUP BY student_id
)
SELECT s.full_name, sec.total_events
FROM student_event_counts sec
JOIN students s ON sec.student_id = s.student_id
WHERE sec.total_events > 1
ORDER BY sec.total_events DESC;

-- Query 5: Subquery
-- Show events with more registrations than the average number of registrations per event
SELECT event_title
FROM events
WHERE event_id IN (
    SELECT event_id
    FROM registrations
    GROUP BY event_id
    HAVING COUNT(*) > (
        SELECT AVG(reg_count)
        FROM (
            SELECT COUNT(*) AS reg_count
            FROM registrations
            GROUP BY event_id
        ) avg_table
    )
);

-- Query 6: View-based query
-- Query the view created in schema.sql
SELECT *
FROM event_registration_summary
ORDER BY total_registrations DESC, event_title;
