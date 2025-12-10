import sqlite3
from flask import Flask, render_template, request, redirect, session
from functools import wraps

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if "user_id" not in session:
            return redirect("/login")
        return f(*args, **kwargs)
    return decorated_function

app = Flask(__name__)
app.secret_key = "supersecretkey"
DATABASE="database.db"

def init_db():
    conn = sqlite3.connect(DATABASE)
    c = conn.cursor()

    # Users table
    c.execute("""
    CREATE TABLE IF NOT EXISTS user (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
    )
    """)

    # Students table
    c.execute("""
    CREATE TABLE IF NOT EXISTS student (
        student_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        major TEXT,
        enroll_year INTEGER,
        email TEXT,
        FOREIGN KEY (user_id) REFERENCES user(user_id)
    )
    """)

    # Instructors table
    c.execute("""
    CREATE TABLE IF NOT EXISTS instructor (
        i_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        dept_id INTEGER,
        name TEXT NOT NULL,
        office TEXT,
        email TEXT,
        role TEXT,
        FOREIGN KEY (user_id) REFERENCES user(user_id)
    )
    """)

    # Department table
    c.execute("""
    CREATE TABLE IF NOT EXISTS department (
        dept_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        building TEXT,
        chair_id INTEGER,
        FOREIGN KEY (chair_id) REFERENCES instructor(i_id)
    )
    """)

    # Course table
    c.execute("""
    CREATE TABLE IF NOT EXISTS course (
        c_id INTEGER PRIMARY KEY AUTOINCREMENT,
        dept_id INTEGER,
        name TEXT NOT NULL,
        desc TEXT,
        FOREIGN KEY (dept_id) REFERENCES department(dept_id)
    )
    """)

    # Section table
    c.execute("""
    CREATE TABLE IF NOT EXISTS section (
        section_id INTEGER PRIMARY KEY AUTOINCREMENT,
        c_id INTEGER,
        year INTEGER,
        semester TEXT,
        FOREIGN KEY (c_id) REFERENCES course(c_id)
    )
    """)

    # Enrollment table
    c.execute("""
    CREATE TABLE IF NOT EXISTS enrollment (
        enroll_id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER,
        section_id INTEGER,
        enroll_date TEXT,
        grade TEXT,
        FOREIGN KEY (student_id) REFERENCES student(student_id),
        FOREIGN KEY (section_id) REFERENCES section(section_id)
    )
    """)

    # InstructorSection table
    c.execute("""
    CREATE TABLE IF NOT EXISTS instructorSection (
        section_id INTEGER,
        i_id INTEGER,
        role_in_section TEXT,
        PRIMARY KEY (section_id, i_id),
        FOREIGN KEY (section_id) REFERENCES section(section_id),
        FOREIGN KEY (i_id) REFERENCES instructor(i_id)
    )
    """)

    # OfficeHours table
    c.execute("""
    CREATE TABLE IF NOT EXISTS officeHours (
        oh_id INTEGER PRIMARY KEY AUTOINCREMENT,
        i_id INTEGER,
        day TEXT,
        start_time TEXT,
        end_time TEXT,
        location TEXT,
        FOREIGN KEY (i_id) REFERENCES instructor(i_id)
    )
    """)

    conn.commit()
    conn.close()

init_db()

def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

# ---------- REGISTER ----------
@app.route("/register", methods=["GET", "POST"])
def register():
    error = None
    if request.method == "POST":
        email = request.form["email"]
        password = request.form["password"]
        role = request.form["role"]

        conn = get_db_connection()
        existing = conn.execute("SELECT * FROM user WHERE email = ?", (email,)).fetchone()
        if existing:
            error = "Email already registered"
        else:
            conn.execute("INSERT INTO user (email, password, role) VALUES (?, ?, ?)", (email, password, role))
            conn.commit()
            user_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]

            if role == "student":
                conn.execute("INSERT INTO student (name, major, enroll_year, email, user_id) VALUES (?, ?, ?, ?, ?)",
                             (email.split("@")[0], "Undeclared", 2025, email, user_id))
            elif role == "instructor":
                conn.execute("INSERT INTO instructor (name, dept_id, office, email, role, user_id) VALUES (?, ?, ?, ?, ?, ?)",
                             (email.split("@")[0], 1, "TBD", email, "Instructor", user_id))
            conn.commit()
            conn.close()
            return redirect("/login")
        conn.close()
    return render_template("register.html", error=error)

# ---------- LOGIN ----------
@app.route("/", methods=["GET", "POST"])
@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        email = request.form["email"]
        password = request.form["password"]

        conn = get_db_connection()
        user = conn.execute("SELECT * FROM user WHERE email = ? AND password = ?", (email, password)).fetchone()
        conn.close()

        if user:
            session["user_id"] = user["user_id"]
            session["role"] = user["role"]
            return redirect("/dashboard")
        else:
            error = "Invalid email or password"
    return render_template("login.html", error=error)

# ---------- LOGOUT ----------
@app.route("/logout")
def logout():
    session.clear()
    return redirect("/login")

# ---------- DASHBOARD ----------
@app.route("/dashboard")
@login_required
def dashboard():
    conn = get_db_connection()
    role = session["role"]

    # ----- ADMIN DASHBOARD -----
    if role == "admin":
        users = conn.execute("SELECT * FROM user").fetchall()
        departments = conn.execute("SELECT * FROM department").fetchall()
        courses = conn.execute("SELECT * FROM course").fetchall()
        sections = conn.execute("SELECT * FROM section").fetchall()
        instructor_sections = conn.execute("SELECT * FROM instructorSection").fetchall()
        conn.close()
        return render_template("dashboard_admin.html",
                               users=users,
                               departments=departments,
                               courses=courses,
                               sections=sections,
                               instructor_sections=instructor_sections)

    # ----- INSTRUCTOR DASHBOARD -----
    elif role == "instructor":
        conn.close()
        return render_template("dashboard_instructor.html")

    # ----- STUDENT DASHBOARD -----
    elif role == "student":
        student = conn.execute("SELECT * FROM student WHERE user_id=?", (session["user_id"],)).fetchone()

        enrollments = conn.execute("""
            SELECT e.enroll_id, e.grade, s.section_id, s.year, s.semester, c.name AS course_name
            FROM enrollment e
            JOIN section s ON e.section_id = s.section_id
            JOIN course c ON s.c_id = c.c_id
            WHERE e.student_id=?
        """, (student["student_id"],)).fetchall()

        sections = conn.execute("""
            SELECT s.section_id, c.name AS course_name, s.year, s.semester
            FROM section s
            JOIN course c ON s.c_id = c.c_id
        """).fetchall()

        instructor_info = conn.execute("""
            SELECT i.name, i.office, i.email, s.section_id
            FROM instructorSection ins
            JOIN instructor i ON ins.i_id = i.i_id
            JOIN section s ON ins.section_id = s.section_id
            WHERE s.section_id IN (SELECT section_id FROM enrollment WHERE student_id=?)
        """, (student["student_id"],)).fetchall()

        office_hours = conn.execute("""
            SELECT oh.*, i.name
            FROM officeHours oh
            JOIN instructor i ON oh.i_id = i.i_id
            WHERE i.i_id IN (SELECT i_id FROM instructorSection)
        """).fetchall()

        conn.close()
        return render_template("dashboard_student.html",
                               student=student,
                               enrollments=enrollments,
                               sections=sections,
                               instructor_info=instructor_info,
                               office_hours=office_hours)
    else:
        conn.close()
        return "Unknown role"

# ---------- STUDENT ENROLLMENT ----------
@app.route("/enrollments/add", methods=["POST"])
@login_required
def enrollment_add():
    student_id = request.form.get("student_id")
    section_id = request.form.get("section_id")
    enroll_date = request.form.get("enroll_date")

    conn = get_db_connection()
    conn.execute("INSERT INTO enrollment (student_id, section_id, enroll_date) VALUES (?, ?, ?)",
                 (student_id, section_id, enroll_date))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

# ------------------- ADMIN ROUTES -------------------
@app.route("/users/add", methods=["POST"])
@login_required
def user_add():
    email = request.form["email"]
    password = request.form["password"]
    role = request.form["role"]
    conn = get_db_connection()
    conn.execute("INSERT INTO user (email, password, role) VALUES (?, ?, ?)", (email, password, role))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/users/delete/<int:user_id>", methods=["POST"])
@login_required
def user_delete(user_id):
    conn = get_db_connection()
    conn.execute("DELETE FROM user WHERE user_id=?", (user_id,))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/departments/add", methods=["POST"])
@login_required
def department_add():
    name = request.form["name"]
    building = request.form.get("building")
    chair_id = request.form.get("chair_id")
    conn = get_db_connection()
    conn.execute("INSERT INTO department (name, building, chair_id) VALUES (?, ?, ?)", (name, building, chair_id))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/departments/edit/<int:dept_id>", methods=["POST"])
@login_required
def department_edit(dept_id):
    name = request.form["name"]
    building = request.form.get("building")
    chair_id = request.form.get("chair_id")
    conn = get_db_connection()
    conn.execute("UPDATE department SET name=?, building=?, chair_id=? WHERE dept_id=?", (name, building, chair_id, dept_id))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/departments/delete/<int:dept_id>", methods=["POST"])
@login_required
def department_delete(dept_id):
    conn = get_db_connection()
    conn.execute("DELETE FROM department WHERE dept_id=?", (dept_id,))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/courses/add", methods=["POST"])
@login_required
def course_add():
    dept_id = request.form.get("dept_id")
    name = request.form["name"]
    desc = request.form.get("desc")
    conn = get_db_connection()
    conn.execute("INSERT INTO course (dept_id, name, desc) VALUES (?, ?, ?)", (dept_id, name, desc))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/courses/edit/<int:c_id>", methods=["POST"])
@login_required
def course_edit(c_id):
    dept_id = request.form.get("dept_id")
    name = request.form["name"]
    desc = request.form.get("desc")
    conn = get_db_connection()
    conn.execute("UPDATE course SET dept_id=?, name=?, desc=? WHERE c_id=?", (dept_id, name, desc, c_id))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/courses/delete/<int:c_id>", methods=["POST"])
@login_required
def course_delete(c_id):
    conn = get_db_connection()
    conn.execute("DELETE FROM course WHERE c_id=?", (c_id,))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/instructorSections/add", methods=["POST"])
@login_required
def instructorSection_add():
    section_id = request.form.get("section_id")
    i_id = request.form.get("i_id")
    role_in_section = request.form.get("role_in_section")
    conn = get_db_connection()
    conn.execute("INSERT INTO instructorSection (section_id, i_id, role_in_section) VALUES (?, ?, ?)",
                 (section_id, i_id, role_in_section))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

@app.route("/instructorSections/delete/<int:section_id>/<int:i_id>", methods=["POST"])
@login_required
def instructorSection_delete(section_id, i_id):
    conn = get_db_connection()
    conn.execute("DELETE FROM instructorSection WHERE section_id=? AND i_id=?", (section_id, i_id))
    conn.commit()
    conn.close()
    return redirect("/dashboard")

if __name__=="__main__":
    app.run(debug=True, host="0.0.0.0", port=5555)
