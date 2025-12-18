/*	
  
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's name, book title, issue date, and days overdue.
*/

-- issued_status == members = books = returns_stauts
-- filter books which is return 
-- overdue >30

select 
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
 rs.return_date
    -- current_date - ist.issued_date as overdue_days
from issued_status as ist
join 
members as m 
  on m.member_id = ist.issued_member_id
join 
books as bk
  on bk.isbn = ist.issued_book_isbn
left join
return_status as rs
  on rs.issued_id = ist.issued_id
where rs.return_date is null
       and 
	   (current_date - ist.issued_date )>30
order by 1;	   
	   
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned
(based on entries in the return_status table).
*/
SELECT * from return_status;		
SELECT * from books;      
SELECT * from issued_status;

select * from issued_status
where issued_book_isbn='978-0-451-52994-2';

select * from books 
where isbn = '978-0-451-52994-2';

update books
set status ='yes'
where isbn='978-0-451-52994-2';

select * from return_status
where issued_id ='IS130';

-- 
insert into return_status(return_id, issued_id,return_date)
values
('RS125','IS130',current_date);

select * from return_status
where issued_id ='IS130';

-- store proceder

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id varchar(10),P_issued_id varchar(10),p_book_quality varchar(15))
LANGUAGE plpgsql
AS $$

DECLARE
	   v_isbn varchar(50);
	   v_book_name varchar(80);

BEGIN
     --  all your LOGIC AND CODE
	 -- INSERTING INTO RETURNS BASED ON USER INPUT
	insert into return_status(return_id, issued_id,return_date,book_quality)
	values
	(p_return_id,P_issued_id,CURRENT_DATE,p_book_quality);

	SELECT 
		  issued_book_isbn,
		  issued_book_name
	      into
		  v_isbn,
		  v_book_name
	from issued_status
	where issued_id = p_issued_id;


    update books
    set status ='YES'
    where isbn=v_isbn;
	
	RAISE NOTICE 'Thankyou you for returninG the book: %',v_book_name;
END;
$$;


CALL add_return_records();
--  TESTING FUNCTION add_return_records
issued_id = IS135
isbn = "978-0-307-58837-1";

select * from books
where isbn ='978-0-307-58837-1';

select * from issued_status

where issued_book_isbn ='978-0-307-58837-1';

select * from return_status
where issued_id ='IS135'

-- calling function
CALL add_return_records('RS138','IS135','GOOD');

-- other solution
update books 
set status = 'Yes'
where isbn in (
  select issued_book_isbn
  from issued_status
  where issued_id in(select issued_id from return_status)
  )


/*Task 16: CTAS: Create a Table of Active Members
   Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
   containing members who have issued at least one book in the last 30 months.
*/

select 
	*
	
from issued_status 
where 
	issued_date >= current_date - INTERVAL '30 month';


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

SELECT  e.emp_name,b.*,count(ist.issued_id)
from issued_status as ist 
join employees as e 
on e.emp_id = ist.issued_emp_id 
join branch as b 
on e.branch_id = b.branch_id 
group by 1,2;


-- Task 19: Stored Procedure
-- Objective: Create a stored procedure to manage the status of books in a library system.
--     Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
--     If a book is issued, the status should change to 'no'.
--     If a book is returned, the status should change to 'yes'

create or replace procedure issue_book(p_issued_id varchar(10),p_issued_member_id varchar(10),
                                 p_issued_book_isbn varchar(50),p_issued_emp_id varchar(10))
language plpgsql
as $$

declare -- all the vairabel deaclare here 
   v_status varchar(10);
begin -- all the code write here 
	 -- checking if book is available 'yes '
	 select status
	 into v_status
	 from books 
	 where isbn = p_issued_book_isbn;

	if  v_status  = 'yes' then 
		insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
			 values (p_issued_id,p_issued_member_id,current_date,p_issued_book_isbn,p_issued_emp_id);
		 update books
    		set status ='NO'
    	where isbn=p_issued_book_isbn;	 
		
		raise 'book record addeb succssfully for book isbn :%',p_issued_book_isbn;	
	else 
		RAISE 'SORRY TO INFORM YOU THE BOOK  YOU HAVE REQUESTED IS UNAVAILABLE BOOK_ISBN :%',p_issued_book_isbn;
	end if  ;
	 

end;
$$;

CALL issue_book('IS155','C108','978-0-553-29698-2','E104');

CALL issue_book('IS156','C108','978-0-375-41398-8','E104');

end;
$$;


-- Task 20: Create Table As Select (CTAS)
-- Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
--     The number of overdue books.
--     The total fines, with each day's fine calculated at $0.50.
--     The number of books issued by each member.
--     The resulting table should show:
--     Member ID
--     Number of overdue books
--     Total fines

SELECT 
    ist.issued_member_id,
    COUNT(*) AS overdue_books,
    ROUND(
        SUM( (CURRENT_DATE - ist.issued_date - 30) * 0.50 ),
        2
    ) AS total_fines
FROM members AS m
JOIN issued_status AS ist
    ON ist.issued_member_id = m.member_id
WHERE  (CURRENT_DATE - ist.issued_date) > 30
GROUP BY ist.issued_member_id;



	
SELECT * from branch;
SELECT * from employees;
SELECT * from return_status;
SELECT * from issued_status;
SELECT * from members;
SELECT * from books;


