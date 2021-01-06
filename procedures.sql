-- Register to the website 
create proc studentRegister @first_name varchar(20), @last_name varchar(20), @password varchar(20), @email varchar(50),
                            @gender bit, @address varchar(10)
as
    IF NOT EXISTS(SELECT *
                  from Users
                  where email = @email)
        BEGIN
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
        END
go;

--Register
create proc InstructorRegister @first_name varchar(20), @last_name varchar(20), @password varchar(20),
                               @email varchar(50),
                               @gender bit, @address varchar(10)
as
    IF NOT EXISTS(SELECT *
                  from Users
                  where email = @email)
        BEGIN
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
        END
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
    if not exists(select *
                  from UserMobileNumber
                  where @mobile_number = mobileNumber)
        begin
            insert into UserMobileNumber (id, mobileNumber)
            values (@ID, @mobile_number)
        end
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
select name, creditHours, price, content, accepted
from Course
go;


-- List all the courses added by instructors not yet accepted.
create proc AdminViewNonAcceptedCourses
as
select name, creditHours, price, content
from Course
where accepted = 0
go;


-- View any course details such as course description and content.
create proc AdminViewCourseDetails @courseId int
as
select name, creditHours, price, content, accepted
from Course
where id = @courseId
go;


-- Accept/Reject any of the requested courses that are added by instructors.
create proc AdminAcceptRejectCourse @adminId int, @courseId int
as
    IF EXISTS(SELECT *
              FROM Admin
              where id = @adminId)
        BEGIN
            update Course
            set adminId  = @adminId,
                accepted = 1
            where id = @courseId
        END
go;


-- Create new Promo codes by inserting all promo code details.
create proc AdminCreatePromocode @code varchar(6), @isuueDate datetime, @expiryDate datetime, @discount decimal(4, 2),
                                 @adminId int
as
    IF EXISTS(SELECT *
              FROM Admin
              where id = @adminId)
        BEGIN
            insert into Promocode (code, issueDate, expiryDate, discountamount, adminId)
            values (@code, @isuueDate, @expiryDate, @discount, @adminId)
        END
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
    IF EXISTS(SELECT *
              FROM Instructor
              WHERE id = @instructorId)
        BEGIN
            insert into Course (creditHours, name, price, instructorId)
            values (@creditHours, @name, @price, @instructorId)
            declare @z int
            select @z = max(Course.id)
            from Course
            insert into InstructorTeachCourse
            values (@instructorId, @z)
        END
GO;


/* Choose any of my course to edit its description or content  */
create proc UpdateCourseContent @instrId int,
                                @courseId int,
                                @content varchar(20)
as
    if EXISTS(
            select *
            from InstructorTeachCourse IT
            where IT.instId = @instrId
              and IT.cid = @courseId
        )
        BEGIN
            update Course
            set content = @content
            where Course.id = @courseId
        END
GO;

create proc UpdateCourseDescription @instrId int,
                                    @courseId int,
                                    @courseDescription varchar(200)
as
    if exists(
            select *
            from InstructorTeachCourse IT
            where IT.instId = @instrId
              and IT.cid = @courseId
        )
        begin
            update Course
            set Course.courseDescription = @courseDescription
            where Course.id = @courseId
              and Course.accepted = 1
        end
go;


-- Add another instructors to the course. 
create proc AddAnotherInstructorToCourse @insid int,
                                         @cid int,
                                         @adderIns int
as
    if exists(select *
              from InstructorTeachCourse
              where cid = @cid
                and instId = @adderIns)
        begin
            if exists(select * from Instructor where id = @insid)
                begin
                    insert into InstructorTeachCourse values (@insId, @cid)
                end
        end
GO;


-- View my courses that were accepted by the admin 
create proc InstructorViewAcceptedCoursesByAdmin @instrId int
as
    if exists(select *
              from Instructor
              where id = @instrId)
        BEGIN
            select Course.id
            from Course
                     inner join InstructorTeachCourse on Course.id = InstructorTeachCourse.cid
            where instId = @instrId
              and Course.accepted = 1
        END;
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
                       inner join Course C on C.id = InstructorTeachCourse.cid
              where instId = @instId
                and cid = @cid
                and c.accepted = 1)
        begin
            insert into Assignment values (@cid, @number, @type, @fullGrade, @weight, @deadline, @content)
        end
GO;


create proc updateInstructorRate @insid int
as
declare @rate decimal(2, 1);
Select @rate = avg(rate)
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
         left outer JOIN UserMobileNumber UMN on U.id = UMN.id
         Inner Join Instructor I on U.id = I.id

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
            update StudentTakeAssignment
            set grade=@grade
            where sid = @sid
              and cid = @cid
              and assignmentNumber = @assignmentNumber
              and assignmentType = @type;
        end
go;


/*View the feedback added by the students on Instructor.*/
create proc ViewFeedbacksAddedByStudentsOnMyCourse @instrId int, @cid int
as
SELECT number, comments, numberOfLikes
from Feedback F
where cid = @cid
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
            Declare @grade decimal(10, 2);
            EXEC viewFinalGrade @cid, @sid, @grade output;
            UPDATE StudentTakeCourse
            set grade=@grade
            where sid = @sid
              and @cid = cid;
        END;
go;


/*Instructor issue certificate to a student upon course completion.*/
create proc InstructorIssueCertificateToStudent @cid int, @sid int, @insId int, @issueDate datetime
as
    IF EXISTS(
            SELECT *
            from InstructorTeachCourse
            where instId = @insId
              and cid = @cid
        )
        Begin
            exec calculateFinalGrade @cid, @sid, @insId
            declare @grade decimal(10, 2);
            select @grade = grade
            from StudentTakeCourse
            where sid = @sid
              and cid = @cid;
            if (@grade >= 50)
                begin
                    insert into StudentCertifyCourse (sid, cid, issueDate) values (@sid, @cid, @issueDate);
                end
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
       email
from Student S
         Inner Join Users U on U.id = S.id
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
SELECT creditHours,
       name,
       courseDescription,
       price,
       content,
       adminId,
       instructorId,
       firstName,
       lastName
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
    if not exists(select *
                  from CreditCard
                  where number = @number)
        begin
            Insert Into CreditCard(number, cardHolderName, expiryDate, cvv)
            values (@number, @cardHolderName, @expiryDate, @cvv);

            Insert Into StudentAddCreditCard(sid, creditCardNumber)
            values (@sid, @number);
        end;
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
    if not EXISTS(SELECT *
                  FROM StudentTakeCourse
                  WHERE @cid = cid
                    AND sid = @sid
                    and payedfor = 1)
        BEGIN
            update StudentTakeCourse
            set payedfor = 1
            where @cid = cid
              and @sid = sid;
        end
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
         inner join StudentTakeAssignment STA on A.cid = STA.cid and A.cid = STA.cid
where @Sid = STA.sid
  and STA.cid = @courseId
go;


create procedure submitAssign @assignType VARCHAR(10), @assignnumber int, @sid INT, @cid INT
as
    if not exists(select *
                  from StudentTakeAssignment
                  where sid = @sid
                    and @cid = cid
                    and @assignnumber = assignmentNumber
                    and @assignType = assignmentType)
        begin
            insert into StudentTakeAssignment (sid, cid, assignmentNumber, assignmentType)
            values (@sid, @cid, @assignnumber, @assignType)
        end
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
    if exists(select *
              from StudentTakeCourse
              where @sid = sid
                and @cid = cid)
        begin
            insert into Feedback (comments, cid, sid)
            values (@comment, @cid, @sid)
        end;
go;


create procedure rateInstructor @rate DECIMAL(2, 1), @sid INT, @insid INT
as
insert into StudentRateInstructor (sid, instId, rate)
values (@sid, @insid, @rate)
go;



create procedure viewCertificate @cid INT, @sid INT
as
select sid, cid, issueDate
from StudentCertifyCourse
where sid = @sid
  and cid = @cid
go;
TRUNCATE TABLE GUCera.dbo.StudentTakeCourse
exec InstructorIssueCertificateToStudent 2, 2, 1, '2/2/2019'
SELECT *
FROM Student
