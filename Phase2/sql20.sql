SELECT user_id, role, linked_id
FROM user_account
WHERE username = 'jdoe' AND password = 'hashedpassword1';

-- 1. List all departments
SELECT * FROM department;

-- 2. Find all instructors in the Computer Science department
SELECT name FROM instructor WHERE dept_id = 1;

-- 3. List all courses with their department names
SELECT c.name AS course, d.name AS department
FROM course c
JOIN department d ON c.dept_id = d.dept_id;

-- 4. Find all sections taught in Spring 2025
SELECT * FROM section WHERE semester = 'Spring' AND year = 2025;

-- 5. Show instructors and their assigned sections
SELECT i.name, s.section_id, c.name AS course
FROM instructor i
JOIN instructorSection isec ON i.i_id = isec.i_id
JOIN section s ON s.section_id = isec.section_id
JOIN course c ON c.c_id = s.c_id;

-- 6. List students and their enrolled courses
SELECT st.name AS student, c.name AS course
FROM enrollment e
JOIN student st ON e.student_id = st.student_id
JOIN section s ON e.section_id = s.section_id
JOIN course c ON s.c_id = c.c_id;

-- 7. Find students with grade 'A'
SELECT st.name, c.name AS course, e.grade
FROM enrollment e
JOIN student st ON e.student_id = st.student_id
JOIN section s ON e.section_id = s.section_id
JOIN course c ON c.c_id = s.c_id
WHERE grade = 'A';

-- 8. Count students per department (based on major)
SELECT major, COUNT(*) AS total_students
FROM student
GROUP BY major;

-- 9. Show office hours for Dr. Alice Johnson
SELECT day, start_time, end_time, location
FROM officeHours
WHERE i_id = 101;

-- 10. Get average grade per section (simple example)
SELECT section_id, AVG(
    CASE grade
        WHEN 'A' THEN 4.0
        WHEN 'A-' THEN 3.7
        WHEN 'B+' THEN 3.3
        WHEN 'B' THEN 3.0
        ELSE 0
    END
) AS avg_gpa
FROM enrollment
GROUP BY section_id;

-- 11. Find all Teaching Assistants
SELECT * FROM instructor WHERE role = 'Teaching Assistant';

-- 12. Show department chairs
SELECT d.name AS department, i.name AS chair
FROM department d
JOIN instructor i ON d.chair_id = i.i_id;

-- 13. Find all students enrolled in Dr. Alice Johnson's sections
SELECT DISTINCT st.name
FROM student st
JOIN enrollment e ON st.student_id = e.student_id
JOIN section s ON e.section_id = s.section_id
JOIN instructorSection isec ON s.section_id = isec.section_id
WHERE isec.i_id = 101;

-- 14. Update a student grade
UPDATE enrollment SET grade = 'A+' WHERE enroll_id = 502;

-- 15. Delete a student record
DELETE FROM student WHERE student_id = 404;

-- 16. Add a new section for "Data Structures"
INSERT INTO section VALUES (305, 202, 2025, 'Spring');

-- 17. Assign Dr. Alice Johnson to new section
INSERT INTO instructorSection VALUES (305, 101, 'Lead Instructor');

-- 18. Show all user accounts and their linked roles
SELECT username, role FROM user_account;

-- 19. List all courses taught by professors (not assistants)
SELECT DISTINCT c.name
FROM course c
JOIN section s ON c.c_id = s.c_id
JOIN instructorSection isec ON s.section_id = isec.section_id
JOIN instructor i ON i.i_id = isec.i_id
WHERE i.role = 'Professor';

-- 20. Show total enrollments per course
SELECT c.name, COUNT(e.enroll_id) AS total_enrolled
FROM course c
JOIN section s ON c.c_id = s.c_id
LEFT JOIN enrollment e ON s.section_id = e.section_id
GROUP BY c.name;
