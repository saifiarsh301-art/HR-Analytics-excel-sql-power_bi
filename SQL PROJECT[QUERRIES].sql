--KPI'S CARD : 
	-- TOTAL EMPLOYEE : 
		select 
			COUNT(Employee_id)	
		as Total_Employee from pr;
	-- AVERAGE SALARY PER EMPLOYEE :
		select 
			ROUND(AVG(monthly_salary),2) 
		as Avg_Salary from pr;
	-- AVERAGE PERFORMANCE SCORE :
		select 
			avg(Performance_Score) 
		as avg_performance_score from pr;
	-- HIGH PERFORMER EMPLOYEE :
		SELECT
			COUNT(*) AS High_Performer_Employees
		FROM pr
		WHERE Performance_Category = 'High';

-- Analytical Queries:
	-- Department-wise employee :
		SELECT
			Department , count(Employee_ID) as Total_Employee 
			FROM pr 
		GROUP BY Department
	-- Average salary by department :
		SELECT 
			Department ,ROUND(AVG(Monthly_Salary),2) AS Avg_Salary 
			FROM pr 
		GROUP BY Department;


	-- Performance by department :
		SELECT 
			Department , Performance_Category,
			COUNT(*) AS TOTAL_EMPLOYEE
			FROM pr
		GROUP BY Department, Performance_Category
		ORDER BY Department;
	-- Average salary by gender:
		SELECT 
			Gender, ROUND(AVG(Monthly_Salary),2)
			AS Avg_Monthly_Salary 
		FROM pr 
		Group BY Gender;
	--Employees with more than X years at the company :
		SELECT Employee_ID, Years_At_Company,
			CASE 
				WHEN Years_At_Company >= 6 THEN 'Loyal_Employee'
				WHEN Years_At_Company BETWEEN 2 AND 5 THEN 'Normal_Employee'
				WHEN Years_At_Company <= 1 THEN 'Fresher_Employee'
				END AS Working_Year
		from pr;

	--HIGH PAYING JOB ROLE :
		SELECT
			Job_Title,
			ROUND(AVG(Monthly_Salary),2) AS Avg_Salary
			FROM pr
		GROUP BY Job_Title
		ORDER BY Avg_Salary DESC;

-- Employees earning above department average:
	WITH dept_avg AS(
		SELECT 
			 department , AVG(monthly_salary) AS avg_salary 
		FROM pr 
		GROUP BY Department )
	SELECT 
		p.employee_id , p.Monthly_Salary , p.department , d.avg_salary 
	FROM pr p
	JOIN dept_avg d ON p.Department = d.Department
	WHERE p.monthly_salary > d.avg_salary ;

--Top 3 Highest-Paid Employees in Each Department:
	with high_salary as(	
		select 
			employee_id , department , monthly_salary ,Job_Title,
			row_number() over(partition by department order by monthly_salary desc) as high_paid
		from pr 
		)
		select 
			Employee_ID,Department,Monthly_Salary,Job_Title
		from high_salary
		where high_paid <= 3
		order by Department, Monthly_Salary desc;

-- Salary Difference from Department Average
	with dept_avg as (
		select department , avg(monthly_salary) as avg_salary
	from pr
	group by Department
	)
	select 
		p.employee_id , p.department , p.monthly_salary , d.avg_salary,
		(p.monthly_salary - d.avg_salary) as salary_difference,
	Case 
		when (p.monthly_salary - d.avg_salary) > 0 then 'High_then_avg_Salary'
		when (p.monthly_salary - d.avg_salary) < 0 then 'Less_then_avg_Salary'
		else 'Avg_Salary'
	End as salary_Status
	from pr p
	join dept_avg d on p.department = d.department;

-- Promotion Rate by Department :
	select 
		department ,count(*) as total_employee , 
		sum(case when promotions > 0 then 1 else 0 End) as total_promoted, 
		cast(round(sum(case when promotions > 0 then 1 else 0 End) *100/count(*),2) as varchar(10)) + '%' as promotion_rate
	from pr
	group by Department

-- Attrition Rate by Department 
	select 
		department ,count(*) as total_employee, sum(case when Resigned = 0 then 0 else 1 End) as total_resigned ,
		cast(round(sum(case when Resigned = 0 then 0 else 1 End) * 100 / count(*),2)as varchar(10)) + '%' as attrition_rate
	from pr 
	group by Department;

-- High Performers Who Earn Below Their Department Average
	with performance_check as (
		select Department, round(avg(Monthly_Salary),2) as avg_salary
		from pr 
		group by Department
	)
	select 
		p.employee_id , p.department ,p.Performance_Category, p.Monthly_salary ,c.avg_salary 
	from pr p
	join performance_check c on p.Department = c.Department
	where p.Performance_Category = 'High'
	and p.Monthly_Salary < c.avg_salary;


-- Department Salary Ranking
	select department , sum(monthly_salary) as total_salary ,
		rank() over(order by sum(monthly_salary) desc) as department_payroll_ranking
	from pr 
	group by Department


-- Department Average Salary for Every Employee
	select employee_id , department , Monthly_Salary,
		avg(monthly_salary) over(partition by department) as department_avg_salary
	from pr 
