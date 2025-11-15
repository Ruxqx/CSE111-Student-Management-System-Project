PRAGMA foreign_keys = ON;

-- Departments
INSERT INTO department VALUES
(1, 'Computer Science', 'Engineering Hall', NULL),
(2, 'Mathematics', 'Science Building', NULL),
(3, 'Physics', 'Newton Hall', NULL);

-- Instructors
INSERT INTO instructor VALUES
(101, 1, 'Dr. Alice Johnson', 'ENG-210', 'alice.johnson@uni.edu', 'Professor'),
(102, 1, 'Bob Smith', 'ENG-215', 'bob.smith@uni.edu', 'Teaching Assistant'),
(103, 2, 'Dr. Carol Lee', 'SCI-110', 'carol.lee@uni.edu', 'Professor'),
(104, 3, 'Dr. David Kim', 'NEW-120', 'david.kim@uni.edu', 'Professor');

-- Update department chairs
UPDATE department SET chair_id = 101 WHERE dept_id = 1;
UPDATE department SET chair_id = 103 WHERE dept_id = 2;
UPDATE department SET chair_id = 104 WHERE dept_id = 3;

-- Courses
INSERT INTO course VALUES
(201, 1, 'Intro to Programming', 'Learn Python basics'),
(202, 1, 'Data Structures', 'Explore algorithms and data organization'),
(203, 2, 'Calculus I', 'Differential calculus'),
(204, 3, 'General Physics', 'Mechanics and thermodynamics');

-- Sections
INSERT INTO section VALUES
(301, 201, 2025, 'Spring'),
(302, 202, 2025, 'Fall'),
(303, 203, 2025, 'Spring'),
(304, 204, 2025, 'Fall');

-- InstructorSection
INSERT INTO instructorSection VALUES
(301, 101, 'Lead Instructor'),
(301, 102, 'Teaching Assistant'),
(302, 101, 'Lead Instructor'),
(303, 103, 'Lead Instructor'),
(304, 104, 'Lead Instructor');

-- Students
INSERT INTO student VALUES
(401, 'Emily Davis', 'Computer Science', '2023', 'emily.davis@uni.edu'),
(402, 'Frank Miller', 'Mathematics', '2022', 'frank.miller@uni.edu'),
(403, 'Grace Lee', 'Physics', '2024', 'grace.lee@uni.edu'),
(404, 'Henry Brown', 'Computer Science', '2023', 'henry.brown@uni.edu');

-- Enrollments
INSERT INTO enrollment VALUES
(501, 401, 301, '2025-01-15', 'A'),
(502, 404, 301, '2025-01-15', 'B+'),
(503, 402, 303, '2025-01-15', 'A-'),
(504, 403, 304, '2025-01-15', 'B');

-- Office Hours
INSERT INTO officeHours VALUES
(601, 101, 'Monday', '10:00', '12:00', 'ENG-210'),
(602, 101, 'Wednesday', '13:00', '15:00', 'ENG-210'),
(603, 102, 'Tuesday', '14:00', '16:00', 'ENG-215'),
(604, 103, 'Thursday', '09:00', '11:00', 'SCI-110');

-- User Accounts
INSERT INTO user_account VALUES
(701, 401, 'emilyd', 'password123', 'student'),
(702, 404, 'henryb', 'pass456', 'student'),
(703, 101, 'alicej', 'teach789', 'instructor'),
(704, 102, 'bobs', 'ta321', 'instructor'),
(705, NULL, 'admin', 'rootpass', 'admin');
