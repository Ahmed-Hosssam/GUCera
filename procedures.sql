-- Register to the website 
create proc studentRegister @first_name varchar(20), @last_name varchar(20), @password varchar(20), @email varchar(50),
                            @gender bit, @address varchar(10)
as
insert into Users (firstName, lastName, password, gender, email, address)
values (@first_name, @last_name, @password, @gender, @email, @address)
declare @sid int;
select @sid = max(id)
from Users
where firstName = @first_name
  and lastName = @last_name
  and password = @password
  and email = @email
  and gender = @gender
  and address = @address
insert into Student (id)
values (@sid)
go;

--Register
create proc InstructorRegister @first_name varchar(20), @last_name varchar(20), @password varchar(20),
                               @email varchar(50),
                               @gender bit, @address varchar(10)
as
insert into Users (firstName, lastName, password, gender, email, address)
values (@first_name, @last_name, @password, @gender, @email, @address)
declare @instid int;
select @instid = max(id)
from Users
where firstName = @first_name
  and lastName = @last_name
  and password = @password
  and email = @email
  and gender = @gender
  and address = @address
insert into Instructor (id)
values (@instid)
go;


-- login
create proc userLogin @ID int, @password varchar(20),
                      @success bit output,
                      @Type int output
as
select @success = count(*)
from Users u
where u.id = @ID
  and u.password = @password
    if @success = 0
        begin
            set @Type = -1
        end
    else
        begin
            if exists(select * from Instructor where id = @ID)
                begin
                    set @Type = 0;
                end
            else
                begin
                    if exists(select * from Admin where id = @ID)
                        begin
                            set @Type = 1;
                        end
                    else
                        begin
                            set @Type = 2;
                        end
                end
        end

go;


-- add my telephone number(s)
create proc addMobile @ID int, @mobile_number varchar(20)
as
insert into UserMobileNumber (id, mobileNumber)
values (@ID, @mobile_number)
go;


-- List all instructors in the system.
create proc AdminListInstr
as
select u.firstName, u.lastName, u.address, u.gender
from Instructor i
         inner join Users u on u.id = i.id
go;


-- view the profile of any instructor that contains all his/her information.
create proc AdminViewInstructorProfile @instrId int
as
select u.firstName, u.lastName, u.address, u.gender
from Instructor i
         inner join Users u on i.id = u.id
where u.id = @instrId
go;


-- List all courses in the system.
create proc AdminViewAllCourses
as
select *
from Course
go;


-- List all the courses added by instructors not yet accepted.
create proc AdminViewNonAcceptedCourses
as
select *
from Course
where accepted = 0
go;


-- View any course details such as course description and content.
create proc AdminViewCourseDetails @courseId int
as
select *
from Course
where id = @courseId
go;


-- Accept/Reject any of the requested courses that are added by instructors.
create proc AdminAcceptRejectCourse @adminId int, @courseId int
as
update Course
set adminId  = @adminId,
    accepted = 1
where id = @courseId
go;


-- Create new Promo codes by inserting all promo code details.
create proc AdminCreatePromocode @code varchar(6), @isuueDate datetime, @expiryDate datetime, @discount decimal(4, 2),
                                 @adminId int
as
insert into Promocode (code, issueDate, expiryDate, discountamount, adminId)
values (@code, @isuueDate, @expiryDate, @discount, @adminId)
go;


/*3 - h List all students in the system */
create proc AdminListAllStudents
as
select firstName, lastName
from Student
         inner join Users U on Student.id = U.id
GO;


/*view the profile of any student that contains all his/her information*/
create proc AdminViewStudentProfile @sid int
as
select firstName, lastName, gender, email, address, gpa
from Student
         inner join Users on Student.id = Users.id
where @sid = Student.id
  and Student.id is not null
  and Student.gpa is not null
  and Users.firstName is not null
  and Users.lastName is not null
  and Users.password is not null
  and Users.address is not null
  and Users.gender is not null
GO;
/*   (Student.id or Student.gpa or u.gender or u.address or u.firstName or u.lastName or u.password) is not null
*/


/* Issue the promo code created to any student. */
create proc AdminIssuePromocodeToStudent @sid int,
                                         @pid varchar(6)
as
insert into StudentHasPromocode
values (@sid, @pid)
GO;



/* Add new course with its details. */
create proc InstAddCourse @creditHours int,
                          @name varchar(10),
                          @price DECIMAL(6, 2),
                          @instructorId int
as
insert into Course (creditHours, name, price, instructorId)
values (@creditHours, @name, @price, @instructorId)
declare @z int
select @z = max(Course.id)
from Course
insert into InstructorTeachCourse
values (@instructorId, @z)
GO;


/* Choose any of my course to edit its description or content  */
create proc UpdateCourseContent @instrId int,
                                @courseId int,
                                @content varchar(20)
as
update Course
set Course.courseDescription = @content
where Course.id = @courseId
  and Course.accepted = 1
  and EXISTS(
        select *
        from InstructorTeachCourse IT
        where IT.instId = @instrId
          and IT.cid = @courseId
    )
GO;

create proc UpdateCourseDescription @instrId int,
                                    @courseId int,
                                    @courseDescription varchar(200)
as
update Course
set Course.courseDescription = @courseDescription
where Course.id = @courseId
  and Course.accepted = 1
  and exists(
        select *
        from InstructorTeachCourse IT
        where IT.instId = @instrId
          and IT.cid = @courseId
    )
go;


-- Add another instructors to the course. 
create proc AddAnotherInstructorToCourse @insid int,
                                         @cid int,
                                         @adderIns int
as
    if exists(select *
              from Course
              where Course.id = @cid
                and Course.instructorId = @adderIns)
        begin
            insert into InstructorTeachCourse values (@insId, @cid)
        end
GO;


-- View my courses that were accepted by the admin 
create proc InstructorViewAcceptedCoursesByAdmin @instrId int
as
select Course.id
from Course
         inner join InstructorTeachCourse on Course.id = InstructorTeachCourse.cid
where instId = @instrId
  and Course.accepted = 1
GO;


-- specify the course pre-requisites. 
create proc DefineCoursePrerequisites @cid int,
                                      @prerequsiteId int
as
insert into CoursePrerequisiteCourse
values (@cid, @prerequsiteId)
GO;


-- Choose a course to define assignments of different types 
create proc DefineAssignmentOfCourseOfCertianType @instId int,
                                                  @cid int,
                                                  @number int,
                                                  @type varchar(10),
                                                  @fullGrade int,
                                                  @weight decimal(4, 1),
                                                  @deadline datetime,
                                                  @content varchar(200)
as
    if exists(select *
              from InstructorTeachCourse
              where instId = @instId
                and cid = @cid
        )
        begin
            insert into Assignment values (@cid, @number, @type, @fullGrade, @weight, @deadline, @content)
        end
GO;


create proc updateInstructorRate @insid int
as
declare @rate decimal(2, 1);
Select avg(rate)
from StudentRateInstructor
where instId = @insid;

Update Instructor
set rating=@rate
where id = @insid;
go;


create proc ViewInstructorProfile @instrId int
as
    EXEC updateInstructorRate @instrId;
SELECT firstName, lastName, gender, email, address, rating, mobileNumber
from Users U
         Inner Join Instructor I on U.id = I.id
         INNER JOIN UserMobileNumber UMN on U.id = UMN.id

where U.id = @instrId;
go;


/*Instructor view the assignments/exams/projects submitted by the students.*/
create proc InstructorViewAssignmentsStudents @instrId int, @cid int
as
    IF EXISTS(
            select *
            from InstructorTeachCourse
            where instId = @instrId
              and cid = @cid
        )
        BEGIN
            SELECT sid, cid, assignmentNumber, assignmentType
            from StudentTakeAssignment
            where cid = @cid;
        END
go;


/* Instructor grade assignments/exams/projects submitted by the students.*/
create proc InstructorgradeAssignmentOfAStudent @instrID int, @sid int, @cid int, @assignmentNumber int,
                                                @type varchar(10),
                                                @grade decimal(5, 2)
as
    IF EXISTS(
            select *
            from InstructorTeachCourse
            where instId = @instrId
              and cid = @cid
        )
        BEGIN
            INSERT INTO StudentTakeAssignment(sid, cid, assignmentNumber, assignmentType, grade)
            values (@sid, @cid, @assignmentNumber, @type, @grade);
        end
go;


/*View the feedback added by the students on Instructor.*/
create proc ViewFeedbacksAddedByStudentsOnMyCourse @instrId int, @cid int
as
SELECT number, comments, numberOfLikes
from Feedback F
         INNER JOIN Course C on C.id = F.cid
         Inner Join Instructor I on I.id = C.instructorId
where C.id = @cid
  and I.id = @instrId
go;


/*issue certificate to a student upon course completion if his final grade >50*/
create proc calculateFinalGrade @cid int, @sid int, @insId int
as
    IF EXISTS(
            SELECT *
            from InstructorTeachCourse
            where instId = @insId
              and cid = @cid
        )
        Begin
            Declare @grade decimal(5, 2);
            SELECT @grade = sum(STA.grade * A.weight)
            FROM Assignment A
                     inner join StudentTakeAssignment STA
                                on A.cid = STA.cid and A.number = STA.assignmentNumber and A.type = STA.assignmentType
            where A.cid = @cid
              and STA.sid = @sid;
            declare @sum int;
            SELECT @sum = sum(weight)
            FROM Assignment A
                     inner join StudentTakeAssignment STA
                                on A.cid = STA.cid and A.number = STA.assignmentNumber and A.type = STA.assignmentType
            UPDATE StudentTakeAssignment
            set grade=@grade / @sum
            where sid = @sid;
        END;
go;


/*Instructor issue certificate to a student upon course completion.*/
create proc InstructorIssueCertificateToStudent @cid int, @sid int, @insId int, @issueDate datetime
as
    Exec calculateFinalGrade @cid, @sid, @insId;
    IF EXISTS(
            SELECT *
            from InstructorTeachCourse
            where instId = @insId
              and cid = @cid
        )
        Begin
            declare @grade decimal(10, 2);
            select @grade = grade
            from StudentTakeCourse
            where sid = @sid
              and cid = @cid;
            if (@grade > 50)
                insert into StudentCertifyCourse (sid, cid, issueDate) values (@sid, @cid, @issueDate);
        end
go;


/*View the profile that contains all information of a student*/
create proc viewMyProfile @id int
as
SELECT S.id,
       gpa,
       firstName,
       lastName,
       password,
       gender,
       email,
       address
from Student S
         Inner Join Users U on U.id = S.id
         Inner Join UserMobileNumber UMN on U.id = UMN.id
where S.id = @id;
go;


/*Edit the profile of a student (change any of their personal information).*/
create proc editMyProfile @id int, @firstName varchar(10), @lastName varChar(10),
                          @password varchar(10), @gender binary, @email varchar(10), @address varchar(10)
as
UPDATE Users
SET firstName=@firstName,
    lastName=@lastName,
    password=@password,
    gender=@gender,
    email=@email,
    address=@address
where id = @id;
go;

/*List all courses in the system accepted by the admin so the student can choose one to enroll*/
create proc availableCourses
as
SELECT name
from Course
WHERE accepted = 1;
go;


/*View detailed information about a course such as course description and instructorsname.*/
create proc courseInformation @id int
as
SELECT creditHours, name, courseDescription, firstName, lastName
from Course C
         INNER JOIN Users U on C.instructorId = U.id
where C.instructorId = @id
go;


/*Enroll in a course which I had viewed its information (the student should choose the instructor as
well)*/
create proc enrollInCourse @sid int, @cid int, @instr int
as
declare @count int, @taken int;
Select @count = count(*)
from CoursePrerequisiteCourse
where cid = @cid;

SELECT @taken = count(*)
from CoursePrerequisiteCourse CPC
         INNER JOIN StudentCertifyCourse SCC on CPC.prerequisiteId = SCC.cid
where CPC.cid = @cid
  and SCC.sid = @sid;
    IF (@taken = @count)
        Begin
            insert into StudentTakeCourse(sid, cid, instId) values (@sid, @cid, @instr);
        End;
go;


/*student add credit card details.*/
create proc addCreditCard @sid int, @number varchar(15), @cardHolderName varchar(16), @expiryDate datetime,
                          @cvv varchar(3)
as
Insert Into CreditCard(number, cardHolderName, expiryDate, cvv)
values (@number, @cardHolderName, @expiryDate, @cvv);

Insert Into StudentAddCreditCard(sid, creditCardNumber)
values (@sid, @number);
go;


create procedure viewPromocode @sid int
as
select PC.code, PC.issueDate, PC.expiryDate, PC.discountamount, PC.adminId
from Promocode PC
         inner join StudentHasPromocode SHPC on PC.code = SHPC.code
where SHPC.sid = @sid
go;


create procedure payCourse @cid INT, @sid INT
as
insert into StudentTakeCourse (sid, cid, payedfor)
values (@sid, @cid, 1)
go;


create procedure enrollInCourseViewContent @id int, @cid int
as
select id, creditHours, name, courseDescription, price, content
from Course
         inner join StudentTakeCourse on Course.id = StudentTakeCourse.cid
where StudentTakeCourse.sid = @id
  and Course.id = @cid
go;


create procedure viewAssign @courseId int, @Sid int
as
select A.cid, A.number, A.type, A.fullGrade, A.weight, A.deadline, A.content
from Assignment A
         inner join StudentTakeCourse STC on A.cid = STC.cid and A.cid = STC.cid
where @Sid = STC.sid
go;


create procedure submitAssign @assignType VARCHAR(10), @assignnumber int, @sid INT, @cid INT
as
insert into StudentTakeAssignment (sid, cid, assignmentNumber, assignmentType)
values (@sid, @cid, @assignnumber, @assignType)
go;


create procedure viewAssignGrades @assignnumber int, @assignType VARCHAR(10), @cid INT, @sid INT,
                                  @assignGrade INT output
as
select @assignGrade = cast(grade as INT)
from StudentTakeAssignment
where sid = @sid
  and cid = @cid
  and assignmentNumber = @assignnumber
  and assignmentType = @assignType
go;

create procedure viewFinalGrade @cid INT, @sid INT, @finalgrade decimal(10, 2) output
as
select @finalgrade = sum((grade / fullGrade) * weight)
from StudentTakeAssignment
         inner join Assignment on StudentTakeAssignment.cid = Assignment.cid and
                                  StudentTakeAssignment.assignmentType = Assignment.type and
                                  StudentTakeAssignment.assignmentNumber = Assignment.number
where @cid = StudentTakeAssignment.cid
  and @sid = StudentTakeAssignment.sid
go;



create procedure addFeedback @comment VARCHAR(100), @cid INT, @sid INT
as
insert into Feedback (comments, cid, sid)
values (@comment, @cid, @sid)
go;


create procedure rateInstructor @rate DECIMAL(2, 1), @sid INT, @insid INT
as
insert into StudentRateInstructor (sid, instId, rate)
values (@sid, @insid, @rate)
go;



create procedure viewCertificate @cid INT, @sid INT
as
select *
from StudentCertifyCourse
where sid = @sid
  and cid = @cid
go; 
