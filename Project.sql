create database GUCera;


create table Users
(
    id        int identity,
    firstName varchar(20),
    lastName  varchar(20),
    password  varchar(20),
    gender    bit,
    email     varchar(10),
    address   varchar(10),
    PRIMARY key (id)
)

create table Instructor
(
    id     int,
    rating decimal(2, 1),
    FOREIGN Key (id) references Users,
    PRIMARY KEY (id)
)

create table UserMobileNumber
(
    id           int,
    mobileNumber varchar(20),
    FOREIGN key (id) references Users,
    PRIMARY key (id, mobileNumber)
)

create table Student
(
    id  int,
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
    id                int identity,
    creditHours       int,
    name              varchar(20),
    courseDescription varchar(200),
    price             real,
    content           varchar(200),
    adminId           int,
    instructorId      int,
    accepted          bit,
    primary key (id),
    foreign key (adminId) references Admin,
    foreign key (instructorId) references Instructor
)

create table Assignment
(
    cid       int,
    number    int,
    type      varchar(10),
    fullGrade int,
    weight    decimal(4, 1),
    deadline  datetime,
    content   varchar(200),
    PRIMARY KEY (cid, number, type),
    foreign key (cid) references Course
)


Create TABLE StudentTakeAssignment
(
    sid              int,
    cid              int,
    assignmentNumber int,
    assignmentType   varchar(10),
    grade            decimal(5, 2),
    PRIMARY KEY (sid, cid, assignmentNumber, assignmentType, grade),
    FOREIGN Key (sid) references Student,
    FOREIGN Key (cid, assignmentNumber, assignmentType) references ASSIGNMENT,
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
    sid       int,
    cid       int,
    issueDate DATETIME,
    FOREIGN KEY (sid) REFERENCES Student,
    foreign key (cid) REFERENCES Course,
    PRIMARY KEY (sid, cid)
)
CREATE TABLE CoursePrerequisiteCourse
(
    cid            int,
    prerequisiteId int,
    FOREIGN KEY (cid) REFERENCES Course,
    FOREIGN KEY (prerequisiteId) REFERENCES Course,
    primary KEY (cid, prerequisiteId)
)

CREATE TABLE InstructorTeachCourse
(
    instId int,
    cid    int,
    FOREIGN KEY (instId) REFERENCES Instructor,
    FOREIGN KEY (cid) REFERENCES Course,
    PRIMARY KEY (instId, cid)
)


create table Feedback
(
    cid           int,
    number        int,
    comments      varchar(100),
    numberOfLikes int,
    sid           int,
    primary key (cid, number),
    foreign key (cid) references Course,
    foreign key (sid) references Student
)

create table Promocode
(

    code           varchar(6),
    issueDate      datetime,
    expiryDate     datetime,
    discountamount decimal(10, 2),
    adminId        int,
    primary key (code),
    foreign key (adminId) references Admin
)


create table StudentHasPromocode
(
    sid  int,
    code varchar(6),
    primary key (sid, code),
    foreign key (sid) references Student,
    foreign key (code) references Promocode
)


create table CreditCard
(
    number         int,
    cardHolderName varchar(16),
    expiryDate     datetime,
    cvv            varchar(3),
    primary key (number),
)

create table StudentAddCreditCard
(
    sid              int,
    creditCardNumber int,
    primary key (sid, creditCardNumber),
    foreign key (sid) references Student,
    foreign key (creditCardNumber) references CreditCard
)

create table StudentTakeCourse
(
    sid      int,
    cid      int,
    instId   int,
    payedfor decimal(10, 2),
    grade    decimal(10, 2),
    primary key (sid, cid, instId),
    foreign key (sid) references Student,
    foreign key (cid) references Course,
    foreign key (instId) references Instructor
)
