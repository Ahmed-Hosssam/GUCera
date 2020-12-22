-- Register to the website 

create proc studentRegister 
    @first_name varchar(20), @last_name varchar(20), @password varchar(20), @email varchar(50),
    @gender bit, @address varchar(10)
    as
    insert into Users (firstName, lastName, password, gender, address)
    values (@first_name,@last_name,@password,@gender,@address)
    
go;

 create proc InstructorRegister
     @first_name varchar(20), @last_name varchar(20), @password varchar(20), @email varchar(50),
     @gender bit, @address varchar(10)
    as
    insert into Users (firstName, lastName, password, gender, address)
    values (@first_name,@last_name,@password,@gender,@address)
 go;

-- login
create proc userLogin
    @id int, @password varchar(20),
    @success bit output 
    as
    select @success = count(*) 
    from Users u
    where u.id = @id and u.password = @password
go;

-- add my telephone number(s)
create proc addMobile
    @id int, @mobile_number varchar(20)
    as
    insert into UserMobileNumber (id, mobileNumber) values (@id, @mobile_number)
go;

-- List all instructors in the system.
create proc AdminListInstr
    as 
    select u.firstName, u.lastName, u.address, u,gender
    from Instructor i 
    inner join Users u on i.id=u.id
go;

-- view the profile of any instructor that contains all his/her information.
create proc AdminViewInstructorProfile
    @instrId int
    as
    select u.firstName, u.lastName, u.address, u,gender
    from Instructor i
    inner join Users u on i.id=u.id
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
create proc AdminViewCourseDetails
    @courseId int
    as
    select *
    from Course
    where id = @courseId
go;

-- Accept/Reject any of the requested courses that are added by instructors.








-- Create new Promo codes by inserting all promo code details.
create proc AdminCreatePromocode
    @code varchar(6), @isuueDate datetime, @expiryDate datetime, @discount decimal(4,2), @adminId int
    as
    insert into Promocode (code, issueDate, expiryDate, discountamount, adminId)
    values (@code,@isuueDate,@expiryDate,@discount,@adminId)
go;

    

/*3 - h List all students in the system */
create  proc AdminListAllStudents
as 
select  *
from Student


/*view the profile of any student that contains all his/her information*/
    
create proc AdminViewStudentProfile 
sid int 
as
select * 
from Student inner join Users U on Student.id = U.id
where   Student.id is not null and Student.gpa is not null and u.firstName is not null and u.lastName is not null and u.password is not null
  and u.address is not null and u.gender is not null

/*   (Student.id or Student.gpa or u.gender or u.address or u.firstName or u.lastName or u.password) is not null
*/

/* Issue the promo code created to any student. */    
create proc AdminIssuePromocodeToStudent
sid int ,
pid varchar(6) 
as
insert into StudentHasPromocode values (sid , pid) 



/* Add new course with its details. */

create proc InstAddCourse
creditHours int ,
name varchar(10), 
price DECIMAL(6,2),
instructorId int
as 
insert into Course (creditHours , name , price , instructorId ) values (creditHours , name , price , instructorId) 


/* Choose any of my course to edit its description or content  */
create proc UpdateCourseContent
instrId int, 
courseId int,
content varchar(20)
as 
update Course
set Course.courseDescription = content
where Course.id =  courseId and EXISTS (
              select *
              from InstructorTeachCourse IT
              where IT.instId = instrId and IT.cid = courseId
          )

/* how to change only one */

    

 