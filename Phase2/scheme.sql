create table department(
    dept_id int,
    name char(50) not null,
    building char(50),
    chair_id int
);

create table instructor(
    i_id int,
    dept_id int not null,
    name char(50) not null,
    office char(50),
    email char(50) unique,
    role char(50)
);

create table course(
    c_id int,
    dept_id int not null,
    name char(50) not null,
    description varchar(150)
);

create table section(
    section_id int,
    c_id int not null,
    year int not null,
    semester char(50) not null
);

create table instructorSection(
    section_id int not null,
    i_id int not null,
    role_in_section char(50)
);

create table student(
    student_id int,
    name char(50) not null,
    major char(50),
    enroll_year char(50),
    email char(50) unique
);

create table enrollment(
    enroll_id int,
    student_id int not null,
    section_id int not null,
    enroll_date date,
    grade char(50)
);

create table officeHours(
    oh_id int,
    i_id int not null,
    day char(50) not null,
    start_time time not null,
    end_time time not null,
    location char(50)
);

create table user_account(
    user_id int,
    linked_id int,
    username char(50) unique not null,
    password char(50) not null,
    role char(50)
);