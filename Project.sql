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
















































