------------------------------------------------------------------
-------------Jinglin Li (jxl163530) Database --------------------
--------------------Assignment 2-------------------------------
-------------------------------------------------------------

----------------Part I-----------------------------------
-- Create all the tables givin in following schema.


CREATE TABLE DEPARTMENT (
  Dname        varchar(25) not null,
  Dnumber      int not null,
  Mgr_ssn      char(9) not null, 
  Mgr_start_date date,
  primary key (dnumber),
  UNIQUE (dname) 
);


CREATE TABLE EMPLOYEE (
  Fname    varchar(15) not null, 
  Minit    varchar(1),
  Lname    varchar(15) not null,
  Ssn     char(9), 
  Bdate    date,
  Address  varchar(50),
  Sex      char,
  Salary   decimal(10,2),
  Super_ssn char(9),
  Dno      int,
  primary key (ssn),
  foreign key (dno) references DEPARTMENT(dnumber)
);


CREATE TABLE DEPENDENT (
  Essn           char(9),
  Dependent_name varchar(15),
  Sex            char,
  Bdate          date,
  Relationship   varchar(8),
  primary key (essn,dependent_name),
  foreign key (essn) references EMPLOYEE(ssn)
);


CREATE TABLE DEPT_LOCATIONS (
  Dnumber   int,
  Dlocation varchar(15), 
  primary key (dnumber,dlocation),
  foreign key (dnumber) references DEPARTMENT(dnumber)
);


CREATE TABLE PROJECT (
  Pname      varchar(25) not null,
  Pnumber    int,
  Plocation  varchar(15),
  Dnum       int not null,
  primary key (pnumber),
  unique (pname),
  foreign key (dnum) references DEPARTMENT(dnumber)
);


CREATE TABLE WORKS_ON (
  Essn   char(9),
  Pno    int,
  Hours  decimal(4,1),
  primary key (essn,pno),
  foreign key (essn) references EMPLOYEE(ssn),
  foreign key (pno) references PROJECT(pnumber)
);


-- Adding FK constraint after loading data into system
Alter table EMPLOYEE
ADD foreign key (super_ssn) references EMPLOYEE(ssn);

Alter table DEPARTMENT
ADD foreign key (Mgr_ssn) references EMPLOYEE(Ssn);


                             
-------------------------------------------------------------------
---------------Part II---------------------------------------------
-------------------------------------------------------------------

-- 1.a. For each department whose average employee salasy is more than $30,000, retrive the department name and the number of employees working for that department.

use Company;
select Dname, COUNT(*) Number_Of_Employee
from DEPARTMENT, EMPLOYEE
where Dno = Dnumber
group by Dname
having AVG(Salary) > 30000;


-- 1.b. Same as a, except ouput the number of male employees instead of the number of employees. 

use Company;
select Dname, COUNT(*) Number_Of_Male_Employee
from DEPARTMENT, EMPLOYEE
where Dno = Dnumber and sex = 'M' and dname in (select Dname 
												from DEPARTMENT, EMPLOYEE
												where Dno = Dnumber
												group by Dname
												having AVG(salary) > 30000)
group by dname


--1.c. Retrieve the names of all employees who work in the department that has the employee with the highest salary among all employees 

select Fname, Lname
from EMPLOYEE
where Dno = (select Dno
			 from EMPLOYEE
			 where Salary = (select MAX(Salary)
							from employee))


--1.d. Retrieve the names of all employees who make at least $10,000 more than the employe who is paid the least in the company.

use Company;
select Fname, Lname
from EMPLOYEE
where Salary > 10000 + (select MIN(Salary)
						from EMPLOYEE)


--1.e. Retrieve the names of employes who is making least in their departments and have more than one dependent (solve using correlated nested queries)

use Company;
select Fname, Lname
from EMPLOYEE E1
where Salary = (select min(Salary)
                from Employee E2
                where E1.Dno = E2.Dno)
	  and
	  Ssn in (select Ssn
			 from EMPLOYEE, DEPENDENT
			 where Ssn = Essn
			 group by Ssn
			 having COUNT(*) > 1)
			 


--------------------------------------------------------------------------------------------------------------


-- 2.Specify following views in SQL. Solve questions using correlated nested queries(except a).
-- 2.a. A view that has the department name, manager name and manager salary for every department.

create view manger_info
as select Dname, Fname, Lname, Salary
   from DEPARTMENT, EMPLOYEE
   where Mgr_ssn = Ssn 
   
-- 2.b. A view that has the department name, its manager's name, number of employees working in that department, and the number of projects controlled by that department (for each department).

create view manger_info
as select Dname, Fname, Lname, (select COUNT(*) 
								from EMPLOYEE E2
							    where E2.Dno = D1.Dnumber) as Num_Employee,

							   (select COUNT(*) 
								from PROJECT P
								where P.Dnum = D1.Dnumber) as Num_Project
   from DEPARTMENT D1, EMPLOYEE E1 
   where D1.Mgr_ssn = E1.Ssn
   
-- 2.c. A view that has the project name, controlling department name, number of employees, and total hours worked per week on the project for each project with more than one employee working on it.

create view project_info
as select Pname, Dname, (select COUNT(*)
						from WORKS_ON W1
						where W1.Pno = P1.Pnumber) as Num_Employee, 

						(select SUM(W2.Hours)
						from WORKS_ON W2
						where W2.Pno = P1.Pnumber 
						group by Pno) as Total_Hours

   from PROJECT P1, DEPARTMENT D1
   where P1.Dnum = D1.Dnumber
   
  
-- 2.d. A view that has the project name, controlling departmet name, number of employees, and total hours worked per week on the project for each project with more than one employee working on it.

create view project_info2
as select Pname, Dname, (select COUNT(*)
						from WORKS_ON W1
						where W1.Pno = P1.Pnumber) as Num_Employee, 

						(select SUM(W2.Hours)
						from WORKS_ON W2
						where W2.Pno = P1.Pnumber 
						group by Pno) as Total_Hours

   from PROJECT P1, DEPARTMENT D1
   where P1.Dnum = D1.Dnumber and (select COUNT(*)
								  from WORKS_ON W2
								  where W2.Pno = P1.Pnumber
								  group by W2.Pno) > 1


-- 2.e. A view that has the employee name, employee salary, department that the employee works in, department manager name, manger salary, and average salary for the department

create view employee_info
as select Fname + ' ' + Lname as Employee_Name, Salary, Dname, (select Fname + ' ' + Lname
																from EMPLOYEE E2
																where D1.Mgr_ssn = E2.Ssn) as Manger_Name,

																(select Salary
																from EMPLOYEE E3
																where D1.Mgr_ssn = E3.Ssn) as manger_Salary, 

																(select AVG(salary)
																from EMPLOYEE E4
																where E4.Dno = D1.Dnumber
																group by E4.Dno) as average_salary
			
   from EMPLOYEE E1, DEPARTMENT D1
   where E1.Dno = D1.Dnumber
   