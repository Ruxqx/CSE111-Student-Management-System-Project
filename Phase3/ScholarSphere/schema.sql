CREATE TABLE user (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL
);
CREATE TABLE student (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    major TEXT,
    enroll_year INTEGER,
    email TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);
CREATE TABLE instructor (
    i_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    dept_id INTEGER,
    name TEXT NOT NULL,
    office TEXT,
    email TEXT,
    role TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);
CREATE TABLE department (
    dept_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    building TEXT,
    chair_id INTEGER,
    FOREIGN KEY (chair_id) REFERENCES instructor(i_id)
);
CREATE TABLE course (
    c_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dept_id INTEGER,
    name TEXT NOT NULL,
    desc TEXT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);
CREATE TABLE section (
    section_id INTEGER PRIMARY KEY AUTOINCREMENT,
    c_id INTEGER,
    year INTEGER,
    semester TEXT,
    FOREIGN KEY (c_id) REFERENCES course(c_id)
);
CREATE TABLE enrollment (
    enroll_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER,
    section_id INTEGER,
    enroll_date TEXT,
    grade TEXT,
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (section_id) REFERENCES section(section_id)
);
CREATE TABLE instructorSection (
    section_id INTEGER,
    i_id INTEGER,
    role_in_section TEXT,
    PRIMARY KEY (section_id, i_id),
    FOREIGN KEY (section_id) REFERENCES section(section_id),
    FOREIGN KEY (i_id) REFERENCES instructor(i_id)
);
CREATE TABLE officeHours (
    oh_id INTEGER PRIMARY KEY AUTOINCREMENT,
    i_id INTEGER,
    day TEXT,
    start_time TEXT,
    end_time TEXT,
    location TEXT,
    FOREIGN KEY (i_id) REFERENCES instructor(i_id)
);
