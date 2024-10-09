-- total salary view
	-- total part-time salary
    create view Part_time_salary as
	select E.emp_id, concat(E.first_name,'  ',E.last_name) as name, P.hourly_rate,P.hours_worked, P.hourly_rate*P.hours_worked as salary
    from employees E right join part_time P
    on E.emp_id = P.emp_id;
    -- total full-time salary
    create view full_time_salary as
    select E.emp_id,concat(E.first_name,'  ',E.last_name) as name, F.monthly_salary
    from employees E right join full_time F
    on E.emp_id = F.emp_id;

CREATE VIEW All_Salaries AS
SELECT 
    E.emp_id,
    CONCAT(E.first_name, ' ', E.last_name) AS name,
    COALESCE(P.salary, 0) AS part_time_salary,
    COALESCE(F.monthly_salary, 0) AS full_time_salary,
    (COALESCE(P.salary, 0) + COALESCE(F.monthly_salary, 0)) AS total_salary
FROM 
    employees E
LEFT JOIN 
    Part_time_salary P ON E.emp_id = P.emp_id
LEFT JOIN 
    full_time_salary F ON E.emp_id = F.emp_id;
    
CREATE VIEW Total_Salary AS
SELECT 
    SUM(COALESCE(P.salary, 0)) AS total_part_time_salary,
    SUM(COALESCE(F.monthly_salary, 0)) AS total_full_time_salary,
    (SUM(COALESCE(P.salary, 0)) + SUM(COALESCE(F.monthly_salary, 0))) AS grand_total_salary
FROM 
    employees E
LEFT JOIN 
    Part_time_salary P ON E.emp_id = P.emp_id
LEFT JOIN 
    full_time_salary F ON E.emp_id = F.emp_id;
-- end total salary view

-- list of chef
create view list_of_chef as
select E.*
from employees E
where E.position = 'chef';
-- list of waiter
create view list_of_waiter as
select E.*
from employees E
where E.position = 'waiter';
-- list of host
create view list_of_host as
select E.*
from employees E
where E.position = 'host';
-- list of janitor
create view list_of_janitor as
select E.*
from employees E
where E.position = 'janitor';
-- list of full-time
create view list_of_full_time as
select E.*
from employees E
where E.type = 'full-time';
-- list of part-time
create view list_of_part_time as
select E.*
from employees E
where E.type = 'part-time';
