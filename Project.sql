create database GUCera;





create table Users
(
    id int identity,
    firstName varchar(20),
    lastName varchar(20),
    password varchar(20),
    gender bit,
    address varchar(10),
    PRIMARY key (id)
)

create table Instructor
(
    id int,
    rating int,
    FOREIGN Key (id) references Users,
    PRIMARY KEY (id)
)

create table UserMobileNumber
(
    id int,
    mobileNumber varchar(20),
    FOREIGN key (id) references Users,
    PRIMARY key (id, mobileNumber)
)

create table Student
(
    id int,
    gpa real,
    Primary key (id),
    foreign key (id) references Users
)

create table Admin
(
    id int,
    primary key (id),
    foreign key (id) references Users
)
create table Course
(
    id int identity,
    creditHours int,
    name varchar(20),
    courseDescription varchar(200),
    price real,
    content varchar(200),
    adminId int,
    instructorId int,
    accepted bit,
    primary key (id),
    foreign key (adminId) references Admin,
    foreign key (instructorId) references Instructor
)

create table Assignment
(
    cid int,
    number int,
    type varchar(10),
    fullGrade int,
    weight decimal(4,1),
    deadline datetime,
    content varchar(200),
    PRIMARY KEY (cid, number, type),
    foreign key (cid) references Course

)



Create TABLE StudentTakeAssignment
(
    sid              int,
    cid              int,
    assignmentNumber int,
    assignmentType   varchar,
    grade            decimal(5,2),
    FOREIGN Key (sid) references Student,
    FOREIGN Key (cid,assignmentNumber,assignmentType) references ASSIGNMENT,
    PRIMARY KEY (sid, cid, assignmentNumber, assignmentType, grade)
)
CREATE TABLE StudentRateInstructor
(
    sid    int,
    instId int,
    rate   int,
    PRIMARY KEY (sid, instId)
)
CREATE TABLE StudentCertifyCourse
(
    sid int,
    cid int ,
    issueDate DATETIME,
    FOREIGN KEY (sid) REFERENCES Student,
    foreign key (cid) REFERENCES Course,
    PRIMARY KEY (sid,cid)
)
CREATE TABLE CoursePrerequisiteCourse(
                                         cid int,
                                         prerequisiteId int,
                                         FOREIGN KEY (cid,prerequisiteId) REFERENCES Course,
                                         primary KEY  (cid,prerequisiteId)
)
CREATE TABLE InstructorTeachCourse(
                                      instId int,
                                      cid int,
                                      FOREIGN KEY (instId) REFERENCES Instructor,
                                      FOREIGN KEY (cid) REFERENCES Course,
                                      PRIMARY KEY (instId,cid)
)





