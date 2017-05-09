
--------------------------1-----------------------------------------

DROP TABLE Employee_Salaries;
CREATE TABLE Employee_Salaries
(
  "SSN" CHAR(9) NOT NULL,
  "Salary" VARCHAR2(10),
  "Log_Date" DATE,
  PRIMARY KEY ("SSN")
);

DROP PROCEDURE CATEGORIZE_SALARY;
/
DROP TRIGGER Check_S;
/
CREATE OR REPLACE PROCEDURE
  categorize_salary(thisSSN IN Employee_Salaries.SSN%TYPE, thisSalary IN Employee.Salary%TYPE) AS
BEGIN
    CASE
        WHEN thisSalary > 60000 THEN
            MERGE INTO Employee_Salaries ES USING DUAL ON (ES."SSN" = thisSSN)
                WHEN NOT MATCHED THEN INSERT (ES."SSN",ES."Salary", ES."Log_Date") VALUES (thisSSN, 'HIGH', sysDate)
                WHEN MATCHED THEN UPDATE SET ES."Salary" = 'HIGH';
        WHEN thisSalary <= 60000 AND thisSalary >= 40000 THEN
            MERGE INTO Employee_Salaries ES USING DUAL ON (ES."SSN" = thisSSN)
                WHEN NOT MATCHED THEN INSERT (ES."SSN",ES."Salary", ES."Log_Date") VALUES (thisSSN, 'MEDIUM', sysdate)
                WHEN MATCHED THEN UPDATE SET ES."Salary" = 'MEDIUM';
        WHEN thisSalary < 40000 THEN
            MERGE INTO Employee_Salaries ES USING DUAL ON (ES."SSN" = thisSSN)
                WHEN NOT MATCHED THEN INSERT (ES."SSN",ES."Salary", ES."Log_Date") VALUES (thisSSN, 'LOW', sysdate)
                WHEN MATCHED THEN UPDATE SET ES."Salary" = 'LOW';
    END CASE;
END;
/
CREATE OR REPLACE TRIGGER Check_S
  AFTER
    INSERT OR
    UPDATE OF Salary
  ON Employee
  FOR EACH ROW
BEGIN
    categorize_salary(:NEW.SSN,:NEW.Salary);
END;
/


-------------------------2-------------------------------------

create or replace PROCEDURE
  Check_Loans AS
CURSOR BOOK_INFO IS
SELECT BOOK.Title, BORROWER.Name, BOOK_LOANS.Due_date
FROM BOOK_LOANS, BOOK, BORROWER
WHERE BOOK_LOANS.Book_id = BOOK.Book_id
  AND BOOK_LOANS.Card_no = BORROWER.Card_no;
thisTitle BOOK.Title%TYPE;
thisBorrower BORROWER.Name%TYPE;
thisDate BOOK_LOANS.Due_date%TYPE;
BEGIN
    OPEN BOOK_INFO;
    LOOP
        FETCH BOOK_INFO INTO thisTitle, thisBorrower, thisDate;
        EXIT WHEN (BOOK_INFO%NOTFOUND);
        IF (to_date(thisDate,'DD-MON-YY') = to_date(SYSDATE,'DD-MON-YY')) THEN
          DBMS_OUTPUT.PUT_LINE('Book Title: ' || thisTitle );
          DBMS_OUTPUT.PUT_LINE('Borrower Name: ' ||thisBorrower);
          DBMS_OUTPUT.PUT_LINE('');
        END IF;
    END LOOP;
    CLOSE BOOK_INFO;
END;
