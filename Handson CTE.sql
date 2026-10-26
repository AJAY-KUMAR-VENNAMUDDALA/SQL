/*==============================================================================
1. BASIC CTE
==============================================================================*/

with employee_data as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
)
select *
  from employee_data;


/*==============================================================================
2. CTE WITH WHERE CONDITION
Find employees earning more than 60,000.
==============================================================================*/

with high_salary_employees as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where salary > 60000
)
select *
  from high_salary_employees;


/*==============================================================================
3. CTE WITH NULL CONDITION
Find employees whose salary is NULL.
==============================================================================*/

with missing_salary as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where salary is null
)
select *
  from missing_salary;


/*==============================================================================
4. CTE WITH NVL
Replace NULL salary with zero.
==============================================================================*/

with clean_salary as (
   select emp_id,
          emp_name,
          department,
          nvl(
             salary,
             0
          ) as salary
     from employee
)
select *
  from clean_salary;


/*==============================================================================
5. CTE WITH INNER JOIN
Get employees and their projects.
==============================================================================*/

with employee_projects as (
   select e.emp_id,
          e.emp_name,
          e.department,
          p.project_name,
          p.project_role,
          p.hours_worked
     from employee e
    inner join employee_project p
   on e.emp_id = p.emp_id
)
select *
  from employee_projects;


/*==============================================================================
6. CTE WITH LEFT JOIN
Return all employees including employees without projects.
==============================================================================*/

with employee_projects as (
   select e.emp_id,
          e.emp_name,
          e.department,
          p.project_name,
          p.project_role
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
)
select *
  from employee_projects;


/*==============================================================================
7. CTE WITH GROUP BY
Count number of projects assigned to every employee.
==============================================================================*/

with project_count as (
   select e.emp_id,
          e.emp_name,
          count(p.assignment_id) as total_projects
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
)
select *
  from project_count
 order by total_projects desc;


/*==============================================================================
8. CTE WITH SUM
Calculate total project hours.
==============================================================================*/

with employee_hours as (
   select e.emp_id,
          e.emp_name,
          sum(nvl(
             p.hours_worked,
             0
          )) as total_hours
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
)
select *
  from employee_hours
 order by total_hours desc;


/*==============================================================================
9. CTE WITH HAVING
Find employees working on more than one project.
==============================================================================*/

with multiple_projects as (
   select e.emp_id,
          e.emp_name,
          count(p.assignment_id) as total_projects
     from employee e
     join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
   having count(p.assignment_id) > 1
)
select *
  from multiple_projects;


/*==============================================================================
10. CTE WITH CASE
Categorize employees based on salary.
==============================================================================*/

with salary_category as (
   select emp_id,
          emp_name,
          salary,
          case
             when salary >= 80000 then
                'High Salary'
             when salary >= 60000 then
                'Medium Salary'
             when salary is null then
                'Salary Missing'
             else
                'Low Salary'
          end as salary_category
     from employee
)
select *
  from salary_category;


/*==============================================================================
11. TWO-LEVEL CTE

Level 1 -> Calculate total hours
Level 2 -> Categorize workload
==============================================================================*/

with employee_hours as (
   select e.emp_id,
          e.emp_name,
          sum(nvl(
             p.hours_worked,
             0
          )) as total_hours
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
),workload as (
   select emp_id,
          emp_name,
          total_hours,
          case
             when total_hours >= 200 then
                'High Workload'
             when total_hours >= 100 then
                'Medium Workload'
             else
                'Low Workload'
          end as workload_category
     from employee_hours
)
select *
  from workload
 order by total_hours desc;


/*==============================================================================
12. TWO-LEVEL CTE

Level 1 -> Clean salary
Level 2 -> Filter high salary employees
==============================================================================*/

with clean_salary as (
   select emp_id,
          emp_name,
          department,
          nvl(
             salary,
             0
          ) as salary
     from employee
),high_salary as (
   select *
     from clean_salary
    where salary >= 70000
)
select *
  from high_salary
 order by salary desc;


/*==============================================================================
13. TWO-LEVEL CTE

Level 1 -> Count projects
Level 2 -> Join project count with employee
==============================================================================*/

with project_count as (
   select emp_id,
          count(*) as total_projects
     from employee_project
    where emp_id is not null
    group by emp_id
),employee_summary as (
   select e.emp_id,
          e.emp_name,
          e.department,
          nvl(
             p.total_projects,
             0
          ) as total_projects
     from employee e
     left join project_count p
   on e.emp_id = p.emp_id
)
select *
  from employee_summary
 order by total_projects desc;


/*==============================================================================
14. TWO-LEVEL CTE - ACTIVE PROJECTS

Level 1 -> Filter active projects
Level 2 -> Join with employees
==============================================================================*/

with active_projects as (
   select emp_id,
          project_name,
          project_role,
          hours_worked
     from employee_project
    where status = 'Active'
),active_employee_projects as (
   select e.emp_id,
          e.emp_name,
          e.department,
          p.project_name,
          p.project_role,
          p.hours_worked
     from employee e
     join active_projects p
   on e.emp_id = p.emp_id
)
select *
  from active_employee_projects;


/*==============================================================================
15. TWO-LEVEL CTE WITH RANKING

Level 1 -> Calculate hours
Level 2 -> Rank employees
==============================================================================*/

with employee_hours as (
   select e.emp_id,
          e.emp_name,
          sum(nvl(
             p.hours_worked,
             0
          )) as total_hours
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
),employee_ranking as (
   select emp_id,
          emp_name,
          total_hours,
          dense_rank()
          over(
              order by total_hours desc
          ) as employee_rank
     from employee_hours
)
select *
  from employee_ranking
 order by employee_rank;


/*==============================================================================
16. THREE-LEVEL CTE

Level 1 -> Join employee/project
Level 2 -> Aggregate data
Level 3 -> Classify workload
==============================================================================*/

with employee_project_data as (
   select e.emp_id,
          e.emp_name,
          e.department,
          p.project_name,
          nvl(
             p.hours_worked,
             0
          ) as hours_worked
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
),employee_summary as (
   select emp_id,
          emp_name,
          department,
          count(project_name) as total_projects,
          sum(hours_worked) as total_hours
     from employee_project_data
    group by emp_id,
             emp_name,
             department
),employee_classification as (
   select emp_id,
          emp_name,
          department,
          total_projects,
          total_hours,
          case
             when total_hours >= 200 then
                'High'
             when total_hours >= 100 then
                'Medium'
             else
                'Low'
          end as workload
     from employee_summary
)
select *
  from employee_classification
 order by total_hours desc;


/*==============================================================================
17. THREE-LEVEL CTE - SALARY ANALYSIS

Level 1 -> Clean employee data
Level 2 -> Calculate department average
Level 3 -> Compare employee with department average
==============================================================================*/

with clean_employee as (
   select emp_id,
          emp_name,
          department,
          nvl(
             salary,
             0
          ) as salary
     from employee
    where department is not null
),department_average as (
   select department,
          avg(salary) as avg_salary
     from clean_employee
    group by department
),salary_comparison as (
   select e.emp_id,
          e.emp_name,
          e.department,
          e.salary,
          d.avg_salary,
          case
             when e.salary > d.avg_salary then
                'Above Average'
             when e.salary < d.avg_salary then
                'Below Average'
             else
                'Equal to Average'
          end as salary_status
     from clean_employee e
     join department_average d
   on e.department = d.department
)
select *
  from salary_comparison
 order by department,
          salary desc;


/*==============================================================================
18. THREE-LEVEL CTE - TOP 3 EMPLOYEES

Level 1 -> Calculate hours
Level 2 -> Rank employees
Level 3 -> Select top 3
==============================================================================*/

with employee_hours as (
   select e.emp_id,
          e.emp_name,
          sum(nvl(
             p.hours_worked,
             0
          )) as total_hours
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
),employee_ranking as (
   select emp_id,
          emp_name,
          total_hours,
          dense_rank()
          over(
              order by total_hours desc
          ) as employee_rank
     from employee_hours
),top_three as (
   select *
     from employee_ranking
    where employee_rank <= 3
)
select *
  from top_three
 order by employee_rank;


/*==============================================================================
19. THREE-LEVEL CTE - HIGHEST SALARY PER DEPARTMENT
==============================================================================*/

with employee_salary as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where department is not null
      and salary is not null
),salary_ranking as (
   select emp_id,
          emp_name,
          department,
          salary,
          dense_rank()
          over(partition by department
               order by salary desc
          ) as salary_rank
     from employee_salary
),highest_salary as (
   select *
     from salary_ranking
    where salary_rank = 1
)
select *
  from highest_salary
 order by department;


/*==============================================================================
20. THREE-LEVEL CTE - PROJECT ANALYSIS
==============================================================================*/

with valid_projects as (
   select emp_id,
          project_name,
          nvl(
             hours_worked,
             0
          ) as hours_worked
     from employee_project
    where emp_id is not null
),project_summary as (
   select project_name,
          count(distinct emp_id) as employee_count,
          sum(hours_worked) as total_hours,
          avg(hours_worked) as avg_hours
     from valid_projects
    group by project_name
),project_category as (
   select project_name,
          employee_count,
          total_hours,
          avg_hours,
          case
             when total_hours >= 200 then
                'Large Project'
             when total_hours >= 100 then
                'Medium Project'
             else
                'Small Project'
          end as project_size
     from project_summary
)
select *
  from project_category
 order by total_hours desc;


/*==============================================================================
21. FOUR-LEVEL CTE - EMPLOYEE PERFORMANCE

Level 1 -> Employee/project data
Level 2 -> Employee summary
Level 3 -> Performance classification
Level 4 -> Ranking
==============================================================================*/

with employee_project_data as (
   select e.emp_id,
          e.emp_name,
          e.department,
          p.project_name,
          nvl(
             p.hours_worked,
             0
          ) as hours_worked
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
),employee_summary as (
   select emp_id,
          emp_name,
          department,
          count(project_name) as total_projects,
          sum(hours_worked) as total_hours
     from employee_project_data
    group by emp_id,
             emp_name,
             department
),performance_data as (
   select emp_id,
          emp_name,
          department,
          total_projects,
          total_hours,
          case
             when total_projects >= 2
                and total_hours >= 150 then
                'Excellent'
             when total_hours >= 80  then
                'Good'
             when total_projects = 0 then
                'No Project'
             else
                'Average'
          end as performance
     from employee_summary
),performance_ranking as (
   select emp_id,
          emp_name,
          department,
          total_projects,
          total_hours,
          performance,
          dense_rank()
          over(
              order by total_hours desc
          ) as performance_rank
     from performance_data
)
select *
  from performance_ranking
 order by performance_rank;


/*==============================================================================
22. FIVE-LEVEL CTE - COMPLETE EMPLOYEE ANALYSIS

Level 1 -> Clean employees
Level 2 -> Project summary
Level 3 -> Combine data
Level 4 -> Performance calculation
Level 5 -> Final ranking
==============================================================================*/

with clean_employee as (
   select emp_id,
          emp_name,
          nvl(
             department,
             'Not Assigned'
          ) as department,
          nvl(
             salary,
             0
          ) as salary,
          nvl(
             city,
             'Unknown'
          ) as city
     from employee
),project_summary as (
   select emp_id,
          count(*) as total_projects,
          sum(nvl(
             hours_worked,
             0
          )) as total_hours
     from employee_project
    where emp_id is not null
    group by emp_id
),combined_data as (
   select e.emp_id,
          e.emp_name,
          e.department,
          e.salary,
          e.city,
          nvl(
             p.total_projects,
             0
          ) as total_projects,
          nvl(
             p.total_hours,
             0
          ) as total_hours
     from clean_employee e
     left join project_summary p
   on e.emp_id = p.emp_id
),performance_data as (
   select emp_id,
          emp_name,
          department,
          salary,
          city,
          total_projects,
          total_hours,
          case
             when total_projects >= 2
                and total_hours >= 180 then
                'Excellent'
             when total_hours >= 100 then
                'Good'
             when total_projects = 0 then
                'Unallocated'
             else
                'Average'
          end as performance
     from combined_data
),final_ranking as (
   select emp_id,
          emp_name,
          department,
          salary,
          city,
          total_projects,
          total_hours,
          performance,
          dense_rank()
          over(
              order by total_hours desc
          ) as overall_rank
     from performance_data
)
select *
  from final_ranking
 order by overall_rank;


/*==============================================================================
23. MULTIPLE INDEPENDENT CTEs

CTE 1 -> Employees
CTE 2 -> Active projects
CTE 3 -> Completed projects
Final -> Join all three
==============================================================================*/

with employee_data as (
   select emp_id,
          emp_name,
          department
     from employee
),active_projects as (
   select emp_id,
          count(*) as active_projects,
          sum(nvl(
             hours_worked,
             0
          )) as active_hours
     from employee_project
    where status = 'Active'
    group by emp_id
),completed_projects as (
   select emp_id,
          count(*) as completed_projects,
          sum(nvl(
             hours_worked,
             0
          )) as completed_hours
     from employee_project
    where status = 'Completed'
    group by emp_id
)
select e.emp_id,
       e.emp_name,
       e.department,
       nvl(
          a.active_projects,
          0
       ) as active_projects,
       nvl(
          a.active_hours,
          0
       ) as active_hours,
       nvl(
          c.completed_projects,
          0
       ) as completed_projects,
       nvl(
          c.completed_hours,
          0
       ) as completed_hours
  from employee_data e
  left join active_projects a
on e.emp_id = a.emp_id
  left join completed_projects c
on e.emp_id = c.emp_id
 order by e.emp_id;


/*==============================================================================
24. TWO-LEVEL CTE + ROW_NUMBER - CONTINUED

Find the highest-hours project for every employee.

Level 1 -> Employee + Project details
Level 2 -> Rank projects for each employee
==============================================================================*/

with employee_projects as (
   select e.emp_id,
          e.emp_name,
          p.project_name,
          nvl(
             p.hours_worked,
             0
          ) as hours_worked
     from employee e
     join employee_project p
   on e.emp_id = p.emp_id
),ranked_projects as (
   select emp_id,
          emp_name,
          project_name,
          hours_worked,
          row_number()
          over(partition by emp_id
               order by hours_worked desc
          ) as project_rank
     from employee_projects
)
select emp_id,
       emp_name,
       project_name,
       hours_worked
  from ranked_projects
 where project_rank = 1
 order by emp_id;


/*==============================================================================
25. TWO-LEVEL CTE + RANK

Level 1 -> Calculate total project hours
Level 2 -> Rank employees based on hours
==============================================================================*/

with employee_hours as (
   select e.emp_id,
          e.emp_name,
          sum(nvl(
             p.hours_worked,
             0
          )) as total_hours
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
),ranked_employees as (
   select emp_id,
          emp_name,
          total_hours,
          rank()
          over(
              order by total_hours desc
          ) as employee_rank
     from employee_hours
)
select *
  from ranked_employees
 order by employee_rank;


/*==============================================================================
26. TWO-LEVEL CTE + DENSE_RANK

DENSE_RANK does not skip ranking numbers when ties occur.
==============================================================================*/

with employee_hours as (
   select e.emp_id,
          e.emp_name,
          sum(nvl(
             p.hours_worked,
             0
          )) as total_hours
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
),ranked_employees as (
   select emp_id,
          emp_name,
          total_hours,
          dense_rank()
          over(
              order by total_hours desc
          ) as employee_rank
     from employee_hours
)
select *
  from ranked_employees
 order by employee_rank;


/*==============================================================================
27. THREE-LEVEL CTE + ROW_NUMBER

Find the highest-hours project for every employee.

Level 1 -> Prepare project data
Level 2 -> Rank projects
Level 3 -> Filter rank 1
==============================================================================*/

with project_data as (
   select e.emp_id,
          e.emp_name,
          e.department,
          p.project_name,
          nvl(
             p.hours_worked,
             0
          ) as hours_worked
     from employee e
     join employee_project p
   on e.emp_id = p.emp_id
),project_ranking as (
   select emp_id,
          emp_name,
          department,
          project_name,
          hours_worked,
          row_number()
          over(partition by emp_id
               order by hours_worked desc
          ) as rn
     from project_data
),top_project as (
   select *
     from project_ranking
    where rn = 1
)
select *
  from top_project
 order by emp_id;


/*==============================================================================
28. THREE-LEVEL CTE - TOP 3 EMPLOYEES BY PROJECT HOURS

Level 1 -> Calculate hours
Level 2 -> Rank employees
Level 3 -> Filter top 3
==============================================================================*/

with employee_hours as (
   select e.emp_id,
          e.emp_name,
          e.department,
          sum(nvl(
             p.hours_worked,
             0
          )) as total_hours
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name,
             e.department
),employee_ranking as (
   select emp_id,
          emp_name,
          department,
          total_hours,
          dense_rank()
          over(
              order by total_hours desc
          ) as employee_rank
     from employee_hours
),top_employees as (
   select *
     from employee_ranking
    where employee_rank <= 3
)
select *
  from top_employees
 order by employee_rank;


/*==============================================================================
29. THREE-LEVEL CTE - DEPARTMENT-WISE TOP SALARY

Level 1 -> Clean salary data
Level 2 -> Rank within each department
Level 3 -> Select rank 1
==============================================================================*/

with valid_salary as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where salary is not null
      and department is not null
),salary_ranking as (
   select emp_id,
          emp_name,
          department,
          salary,
          dense_rank()
          over(partition by department
               order by salary desc
          ) as salary_rank
     from valid_salary
),highest_paid as (
   select *
     from salary_ranking
    where salary_rank = 1
)
select *
  from highest_paid
 order by department;


/*==============================================================================
30. TWO-LEVEL CTE + LAG

Compare employee salary with previous employee salary
inside the same department.
==============================================================================*/

with salary_data as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where salary is not null
      and department is not null
),salary_comparison as (
   select emp_id,
          emp_name,
          department,
          salary,
          lag(salary)
          over(partition by department
               order by salary
          ) as previous_salary
     from salary_data
)
select emp_id,
       emp_name,
       department,
       salary,
       previous_salary,
       salary - previous_salary as salary_difference
  from salary_comparison
 order by department,
          salary;


/*==============================================================================
31. TWO-LEVEL CTE + LEAD

Compare employee salary with the next employee salary
inside the department.
==============================================================================*/

with salary_data as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where salary is not null
      and department is not null
),salary_comparison as (
   select emp_id,
          emp_name,
          department,
          salary,
          lead(salary)
          over(partition by department
               order by salary
          ) as next_salary
     from salary_data
)
select emp_id,
       emp_name,
       department,
       salary,
       next_salary,
       next_salary - salary as salary_difference
  from salary_comparison
 order by department,
          salary;


/*==============================================================================
32. TWO-LEVEL CTE + FIRST_VALUE

Find highest salary in each department.
==============================================================================*/

with salary_data as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where salary is not null
      and department is not null
),salary_analysis as (
   select emp_id,
          emp_name,
          department,
          salary,
          first_value(salary)
          over(partition by department
               order by salary desc
          ) as highest_department_salary
     from salary_data
)
select *
  from salary_analysis
 order by department,
          salary desc;


/*==============================================================================
33. TWO-LEVEL CTE + LAST_VALUE

Find lowest salary in each department.

Important:
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
allows LAST_VALUE to look at the complete department.
==============================================================================*/

with salary_data as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where salary is not null
      and department is not null
),salary_analysis as (
   select emp_id,
          emp_name,
          department,
          salary,
          last_value(salary)
          over(partition by department
               order by salary desc
             rows between unbounded preceding and unbounded following
          ) as lowest_department_salary
     from salary_data
)
select *
  from salary_analysis
 order by department,
          salary desc;


/*==============================================================================
34. TWO-LEVEL CTE - RUNNING TOTAL

Calculate cumulative project hours.
==============================================================================*/

with employee_hours as (
   select e.emp_id,
          e.emp_name,
          sum(nvl(
             p.hours_worked,
             0
          )) as total_hours
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
    group by e.emp_id,
             e.emp_name
),running_total as (
   select emp_id,
          emp_name,
          total_hours,
          sum(total_hours)
          over(
              order by emp_id
             rows between unbounded preceding and current row
          ) as cumulative_hours
     from employee_hours
)
select *
  from running_total
 order by emp_id;


/*==============================================================================
35. THREE-LEVEL CTE - DEPARTMENT PROJECT SUMMARY

Level 1 -> Employee/project data
Level 2 -> Employee summary
Level 3 -> Department summary
==============================================================================*/

with employee_project_data as (
   select e.emp_id,
          e.emp_name,
          nvl(
             e.department,
             'Not Assigned'
          ) as department,
          p.project_name,
          nvl(
             p.hours_worked,
             0
          ) as hours_worked
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
),employee_summary as (
   select emp_id,
          emp_name,
          department,
          count(project_name) as project_count,
          sum(hours_worked) as total_hours
     from employee_project_data
    group by emp_id,
             emp_name,
             department
),department_summary as (
   select department,
          count(*) as employee_count,
          sum(project_count) as total_projects,
          sum(total_hours) as total_hours
     from employee_summary
    group by department
)
select *
  from department_summary
 order by total_hours desc;


/*==============================================================================
36. FOUR-LEVEL CTE - DEPARTMENT RANKING

Level 1 -> Employee/project data
Level 2 -> Employee summary
Level 3 -> Department summary
Level 4 -> Rank departments
==============================================================================*/

with employee_project_data as (
   select e.emp_id,
          e.emp_name,
          nvl(
             e.department,
             'Not Assigned'
          ) as department,
          p.project_name,
          nvl(
             p.hours_worked,
             0
          ) as hours_worked
     from employee e
     left join employee_project p
   on e.emp_id = p.emp_id
),employee_summary as (
   select emp_id,
          emp_name,
          department,
          count(project_name) as project_count,
          sum(hours_worked) as total_hours
     from employee_project_data
    group by emp_id,
             emp_name,
             department
),department_summary as (
   select department,
          count(*) as employee_count,
          sum(project_count) as total_projects,
          sum(total_hours) as total_hours
     from employee_summary
    group by department
),department_ranking as (
   select department,
          employee_count,
          total_projects,
          total_hours,
          dense_rank()
          over(
              order by total_hours desc
          ) as department_rank
     from department_summary
)
select *
  from department_ranking
 order by department_rank;


/*==============================================================================
37. MULTIPLE INDEPENDENT CTEs

CTE 1 -> Active projects
CTE 2 -> Completed projects
CTE 3 -> Pending projects

Final -> Combine all project statuses for each employee.
==============================================================================*/

with active_projects as (
   select emp_id,
          count(*) as active_count
     from employee_project
    where status = 'Active'
    group by emp_id
),completed_projects as (
   select emp_id,
          count(*) as completed_count
     from employee_project
    where status = 'Completed'
    group by emp_id
),pending_projects as (
   select emp_id,
          count(*) as pending_count
     from employee_project
    where status = 'Pending'
    group by emp_id
)
select e.emp_id,
       e.emp_name,
       nvl(
          a.active_count,
          0
       ) as active_projects,
       nvl(
          c.completed_count,
          0
       ) as completed_projects,
       nvl(
          p.pending_count,
          0
       ) as pending_projects
  from employee e
  left join active_projects a
on e.emp_id = a.emp_id
  left join completed_projects c
on e.emp_id = c.emp_id
  left join pending_projects p
on e.emp_id = p.emp_id
 order by e.emp_id;


/*==============================================================================
38. THREE-LEVEL CTE - FIND EMPLOYEES ABOVE DEPARTMENT AVERAGE

Level 1 -> Valid salary data
Level 2 -> Department average
Level 3 -> Compare employees
==============================================================================*/

with employee_salary as (
   select emp_id,
          emp_name,
          department,
          salary
     from employee
    where salary is not null
      and department is not null
),department_average as (
   select department,
          avg(salary) as avg_salary
     from employee_salary
    group by department
),above_average_employees as (
   select e.emp_id,
          e.emp_name,
          e.department,
          e.salary,
          d.avg_salary
     from employee_salary e
     join department_average d
   on e.department = d.department
    where e.salary > d.avg_salary
)
select *
  from above_average_employees
 order by department,
          salary desc;


/*==============================================================================
39. FOUR-LEVEL CTE - PROJECT PERFORMANCE

Level 1 -> Valid project data
Level 2 -> Project summary
Level 3 -> Project classification
Level 4 -> Project ranking
==============================================================================*/

with valid_projects as (
   select emp_id,
          project_name,
          nvl(
             hours_worked,
             0
          ) as hours_worked
     from employee_project
    where emp_id is not null
),project_summary as (
   select project_name,
          count(distinct emp_id) as employee_count,
          sum(hours_worked) as total_hours,
          round(
             avg(hours_worked),
             2
          ) as avg_hours
     from valid_projects
    group by project_name
),project_classification as (
   select project_name,
          employee_count,
          total_hours,
          avg_hours,
          case
             when total_hours >= 200 then
                'High Effort Project'
             when total_hours >= 100 then
                'Medium Effort Project'
             else
                'Low Effort Project'
          end as project_category
     from project_summary
),project_ranking as (
   select project_name,
          employee_count,
          total_hours,
          avg_hours,
          project_category,
          dense_rank()
          over(
              order by total_hours desc
          ) as project_rank
     from project_classification
)
select *
  from project_ranking
 order by project_rank;


/*==============================================================================
40. FIVE-LEVEL CTE - COMPLETE BUSINESS SCENARIO

Level 1 -> Clean employee data
Level 2 -> Calculate project metrics
Level 3 -> Combine employee/project data
Level 4 -> Calculate employee performance
Level 5 -> Rank employees

This demonstrates how CTEs can replace deeply nested subqueries
and make complex SQL easier to understand.
==============================================================================*/

with clean_employee as (
   select emp_id,
          emp_name,
          nvl(
             department,
             'Not Assigned'
          ) as department,
          nvl(
             salary,
             0
          ) as salary,
          nvl(
             city,
             'Unknown'
          ) as city
     from employee
),project_metrics as (
   select emp_id,
          count(*) as project_count,
          sum(nvl(
             hours_worked,
             0
          )) as total_hours,
          round(
             avg(nvl(
                hours_worked,
                0
             )),
             2
          ) as avg_hours
     from employee_project
    where emp_id is not null
    group by emp_id
),combined_data as (
   select e.emp_id,
          e.emp_name,
          e.department,
          e.salary,
          e.city,
          nvl(
             p.project_count,
             0
          ) as project_count,
          nvl(
             p.total_hours,
             0
          ) as total_hours,
          nvl(
             p.avg_hours,
             0
          ) as avg_hours
     from clean_employee e
     left join project_metrics p
   on e.emp_id = p.emp_id
),performance_data as (
   select emp_id,
          emp_name,
          department,
          salary,
          city,
          project_count,
          total_hours,
          avg_hours,
          case
             when project_count >= 2
                and total_hours >= 180 then
                'Excellent'
             when project_count >= 1
                and total_hours >= 100 then
                'Good'
             when project_count = 0 then
                'Unallocated'
             else
                'Average'
          end as performance
     from combined_data
),final_employee_ranking as (
   select emp_id,
          emp_name,
          department,
          salary,
          city,
          project_count,
          total_hours,
          avg_hours,
          performance,
          dense_rank()
          over(
              order by total_hours desc
          ) as overall_rank
     from performance_data
)
select *
  from final_employee_ranking
 order by overall_rank;