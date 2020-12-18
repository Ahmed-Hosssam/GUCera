create database GUCera;





create table Users
(
    id int identity,
    firstName varchar(20),
    lastName varchar(20),
    password varchar(20),
    gender bit,
    address varchar(10)
)

create table Instructor
(
    uid int,
    rating int,
    FOREIGN Key (uid) references Users,
    PRIMARY KEY (uid)
)

create table UserMobileNumber 
(
    uid int,
    mobileNumber varchar(20),
    FOREIGN key (uid) references Users,
    PRIMARY key (uid, mobileNumber)
)

create table Student
(
    uid int,
    gpa real,
    Primary key (id),
    foreign key (id) references Users
)

create table Admin
(
    uid int,
    primary key (uid),
    
)

















































create table Feedback (
    cid int ,
    number  int ,
    ommentvarchar (100) ,
    numberOfLint ,
    sid ikes s c
)  















Create TABLE StudentTakeAssignmentsi(d
 in t
 ,
    ci idnt,
    
       in int,
    t cid,
    assignmentTaype vrchar ,
    grade,
    FOREIGN Key (sid) references Student,
    FOREIGN Key (cid) references ASSIGNMENT,
    FOREIGN Key (assignmentNumber) references Student,
    FOREIGN Key (sid) references Student, real   int sid,
)




