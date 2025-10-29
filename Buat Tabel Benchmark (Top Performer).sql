CREATE TABLE talent_benchmarks AS
SELECT DISTINCT
    e.position_id,
    e.employee_id AS benchmark_employee_id
FROM employees e
JOIN performance_yearly p ON e.employee_id = p.employee_id
WHERE p.rating = 5;