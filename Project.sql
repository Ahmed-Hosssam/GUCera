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





