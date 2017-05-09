-- Quiz 2
-- 1.a. A view that has the department name, manager name, and manager salary for every department

create view manager_info_quiz1a
as select Dname, Fname, Lname, Salary
   from DEPARTMENT, EMPLOYEE
   where Mgrssn = Ssn;


-- 1.b. A view that has the employee name, supervisor name, and employee salary for each employee who works in the 'Research' department

create view employee_info_quiz1b
as select E.Fname ||' '|| E.Lname Employee_Name,  (select M.Fname || ' ' || M.Lname 
                                                   from EMPLOYEE M
                                                   where E.Superssn = M.Ssn) Supervisor_name,

												   Salary
   from EMPLOYEE E, DEPARTMENT D
   where E.Dno = D.Dno and D.Dname = 'Research';


-- 2. For each employee, list his/her ssn, last name and the number of dependents he/she has, even if it is zero (Output: Ssn, LName, Num Deps). Output should be ordered alphabetically, by last name of employee.
select E.ssn, E.Lname, (SELECT COUNT(*)
                    FROM DEPENDENT D
                    WHERE E.SSN = D.ESSN
                    GROUP BY D.ESSN) Num_Deps
from EMPLOYEE E
ORDER BY E.Lname;

-- 3. Find the last names of employees earning above average salary in their respective departments. Output the average salary of the department along with the employee’s salary (Output: Lname, DNo, Salary, Avg Sal). 
select E.Lname, (select Avg(salary)
                  from employee E3
                  where E.Dno = E3.Dno) Avg_salary
from Employee E, Department D
where E.Dno = D.Dno and salary > (select Avg(salary)
                                  from employee E2
                                  where E.Dno = E2.Dno)

                                      
-- 4. List the last names of employees who do not work on any project controlled by their respective departments (Output: LName). 
select E1.Lname
from Employee E1, Department D1
where E1.Dno = D1.Dno and not exists (select *
                                      from WORKS_ON W2, PROJECT P2, DEPARTMENT D2 
                                      where W2.Pno = P2.Pno and P2.Dno = D2.Dno and E1.Dno = D2.Dno and E1.Ssn = W2.Ssn);
                                      
-- 5. List the female employees, each of whom works on 2 or more projects. (Output: SSN, Number-of-projects)
select E.Fname || ' ' || E.Lname Female_Employee, count(*) Number_of_Project
from Employee E, WORKS_ON W
where W.ssn = E.ssn and E.Sex = 'F' and E.Ssn in (select W.ssn
                                                  from WORKS_ON W2
                                                  GROUP by W2.ssn
                                                  having count(*) > 1)
group by E.Fname, E.Lname;
                                        
-------------------------------------------------END OF THE QUIZ-------------------------------------------------------------