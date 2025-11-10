-- =========================
-- 1️⃣ Department
-- =========================
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    building VARCHAR(50),
    chair_id INT,
    CONSTRAINT fk_chair FOREIGN KEY (chair_id) REFERENCES instructor(i_id)
);

-- =========================
-- 2️⃣ Instructor
-- =========================
CREATE TABLE instructor (
    i_id INT PRIMARY KEY,
    dept_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    office VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    role VARCHAR(50) CHECK (role IN ('Professor','Teaching Assistant','Learning Assistant')),
    CONSTRAINT fk_instructor_dept FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- =========================
-- 3️⃣ Course
-- =========================
CREATE TABLE course (
    c_id INT PRIMARY KEY,
    dept_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    CONSTRAINT fk_course_dept FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- =========================
-- 4️⃣ Section
-- =========================
CREATE TABLE section (
    section_id INT PRIMARY KEY,
    c_id INT NOT NULL,
    year INT NOT NULL,
    semester VARCHAR(10) NOT NULL,
    CONSTRAINT fk_section_course FOREIGN KEY (c_id) REFERENCES course(c_id)
);

-- =========================
-- 5️⃣ InstructorSection
-- =========================
CREATE TABLE instructorSection (
    section_id INT NOT NULL,
    i_id INT NOT NULL,
    role_in_section VARCHAR(50),
    PRIMARY KEY (section_id, i_id),
    CONSTRAINT fk_is_section FOREIGN KEY (section_id) REFERENCES section(section_id),
    CONSTRAINT fk_is_instructor FOREIGN KEY (i_id) REFERENCES instructor(i_id)
);

-- =========================
-- 6️⃣ Student
-- =========================
CREATE TABLE student (
    student_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    major VARCHAR(50),
    enroll_year VARCHAR(10),
    email VARCHAR(100) UNIQUE
);

-- =========================
-- 7️⃣ Enrollment
-- =========================
CREATE TABLE enrollment (
    enroll_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    enroll_date DATE,
    grade VARCHAR(5),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT fk_enroll_section FOREIGN KEY (section_id) REFERENCES section(section_id)
);

-- =========================
-- 8️⃣ OfficeHours
-- =========================
CREATE TABLE officeHours (
    oh_id INT PRIMARY KEY,
    i_id INT NOT NULL,
    day VARCHAR(10) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(50),
    CONSTRAINT fk_oh_instructor FOREIGN KEY (i_id) REFERENCES instructor(i_id)
);

-- =========================
-- 9️⃣ User
-- =========================
CREATE TABLE user_account (
    user_id INT PRIMARY KEY,
    linked_id INT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('student','instructor','admin'))
    -- NOTE: linked_id can point to student or instructor; enforce in app logic
);
