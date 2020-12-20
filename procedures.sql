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
insert into StudentHasPromcode values (sid , pid) 



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

    

 