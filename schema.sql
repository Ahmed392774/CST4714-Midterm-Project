-- Drop old objects if they exist
DROP VIEW IF EXISTS event_registration_summary;
DROP TABLE IF EXISTS registrations;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS students;

-- Create students table
CREATE TABLE students (
    student_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    major TEXT NOT NULL,
    class_level TEXT NOT NULL CHECK (class_level IN ('Freshman', 'Sophomore', 'Junior', 'Senior')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create events table
CREATE TABLE events (
    event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_title TEXT NOT NULL,
    event_date DATE NOT NULL,
    location TEXT NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    category TEXT NOT NULL CHECK (category IN ('Academic', 'Career', 'Social', 'Technology')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create registrations table
CREATE TABLE registrations (
    registration_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id BIGINT NOT NULL,
    event_id BIGINT NOT NULL,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status TEXT NOT NULL CHECK (status IN ('registered', 'waitlisted', 'cancelled')),
    CONSTRAINT fk_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_event
        FOREIGN KEY (event_id) REFERENCES events(event_id)
        ON DELETE CASCADE,
    CONSTRAINT unique_student_event UNIQUE (student_id, event_id)
);

-- Create view
CREATE VIEW event_registration_summary AS
SELECT 
    e.event_id,
    e.event_title,
    e.event_date,
    e.location,
    COUNT(r.registration_id) AS total_registrations
FROM events e
LEFT JOIN registrations r ON e.event_id = r.event_id
GROUP BY e.event_id, e.event_title, e.event_date, e.location;
