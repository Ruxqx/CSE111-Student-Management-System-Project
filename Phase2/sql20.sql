SELECT user_id, role, linked_id
FROM user_account
WHERE username = 'jdoe' AND password = 'hashedpassword1';

-- 1. List all departments
SELECT * FROM department;

-- 2. Find all staff in the Computer Science department
SELECT name FROM instructor WHERE dept_id = 1;
--more complex way via subquery
SELECT name 
FROM instructor
WHERE dept_id = (
    SELECT dept_id 
    FROM department 
    WHERE name = 'Computer Science'
);


-- 3. List all courses with their department names
SELECT c.name AS course, d.name AS department
FROM course c
JOIN department d ON c.dept_id = d.dept_id;

-- 4. Find all sections taught in Spring 2025
SELECT * FROM section WHERE semester = 'Spring' AND year = 2025;

-- 5. Show all staff and their assigned sections
SELECT i.name, s.section_id, c.name AS course
FROM instructor i
JOIN instructorSection isec ON i.i_id = isec.i_id
JOIN section s ON s.section_id = isec.section_id
JOIN course c ON c.c_id = s.c_id
order by c.name;

-- 6. List students and their enrolled courses
SELECT st.name AS student, c.name AS course
FROM enrollment e
JOIN student st ON e.student_id = st.student_id
JOIN section s ON e.section_id = s.section_id
JOIN course c ON s.c_id = c.c_id
order by c.name;

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

-- 9. Show office hours for Dr. Smith
SELECT day, start_time, end_time, location
FROM officeHours
WHERE i_id = 50001;

-- 10. Get average grade per section (simple example)
SELECT section_id, AVG(
    CASE grade
        WHEN 'A' THEN 4
        WHEN 'B' THEN 3
        WHEN 'C' THEN 2
        WHEN 'D' THEN 1
        ELSE 0
    END
) AS avg_gpa
FROM enrollment
GROUP BY section_id;

-- 11. Find all Teaching Assistants
-- Select all columns from the instructor table where the role is 'Teaching Assistant'
SELECT * 
FROM instructor 
WHERE role = 'Teaching Assistant';

-- 12. Show department chairs
SELECT d.name AS department, i.name AS chair -- Select the department name and the name of the instructor who is the chair
FROM department d -- Join the department table with the instructor table to find the chair of each department
JOIN instructor i ON d.chair_id = i.i_id;

-- 13. Find all students enrolled in Dr. Alice Johnson's sections
SELECT DISTINCT st.name -- Use DISTINCT to avoid duplicate student names
FROM student st -- Join student, enrollment, section, and instructorSection tables to get students in sections taught by a specific instructor
JOIN enrollment e ON st.student_id = e.student_id
JOIN section s ON e.section_id = s.section_id
JOIN instructorSection isec ON s.section_id = isec.section_id 
WHERE isec.i_id = 50001; -- Filter by the instructor's ID 

-- 14. Update a student grade
-- Update the 'grade' column in the enrollment table to 'A' for the enrollment with ID 400002
UPDATE enrollment 
SET grade = 'A' 
WHERE enroll_id = 400002;

-- 15. Delete a student record
-- Delete the student from the student table whose student_id is 100002
delete from enrollment where student_id=100002;
DELETE FROM student WHERE student_id = 100002;


-- 16. Add a new section for "Data Structures"
-- Insert a new row into the section table with values for section_id, course_id, year, and semester
INSERT INTO section 
VALUES (20021, 1002, 2025, 'Spring');

-- 17. Assign Dr. Johnson to new section
-- Insert a row into instructorSection linking instructor 50002 (Dr. Alice Johnson) to section 20021 as 'Lead Instructor'
INSERT INTO instructorSection 
VALUES (20021, 50002, 'Lead Instructor');

-- 18. Show all user accounts and their linked roles
-- Select the username and role from the user_account table to see all accounts and what role they have
SELECT username, role 
FROM user_account;

-- 19. List all courses taught by professors (not assistants)
SELECT DISTINCT c.name 
FROM course c
JOIN section s ON c.c_id = s.c_id -- Join course, section, instructorSection, and instructor tables
JOIN instructorSection isec ON s.section_id = isec.section_id
JOIN instructor i ON i.i_id = isec.i_id
WHERE i.role = 'Professor'; -- Select distinct course names where the instructor's role is 'Professor'

-- 20. Show total enrollments per course
SELECT c.name, COUNT(e.enroll_id) AS total_enrolled -- Count the number of enrollments for each course
FROM course c
JOIN section s ON c.c_id = s.c_id -- Join course, section, and enrollment tables
LEFT JOIN enrollment e ON s.section_id = e.section_id -- Use LEFT JOIN to include courses even if they have no enrollments
GROUP BY c.name -- Group results by course name
having count(e.enroll_id)>=3; -- Having more than 3 enrollments 
