CREATE TABLE baseline AS
SELECT 
    e.position_id,
    'IQ'  AS tv_name, 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ps.iq)  AS benchmark_baseline
FROM profiles_psych ps
JOIN employees e ON e.employee_id = ps.employee_id
WHERE e.employee_id IN (SELECT benchmark_employee_id FROM talent_benchmarks)
GROUP BY e.position_id

UNION ALL

SELECT 
    e.position_id,
    'GTQ' AS tv_name, 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ps.gtq) AS benchmark_baseline
FROM profiles_psych ps
JOIN employees e ON e.employee_id = ps.employee_id
WHERE e.employee_id IN (SELECT benchmark_employee_id FROM talent_benchmarks)
GROUP BY e.position_id;