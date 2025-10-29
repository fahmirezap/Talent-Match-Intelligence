CREATE TABLE tv_match_rates AS
SELECT 
    e.employee_id,
    b.tv_name,
    ROUND((1 - ABS(ps.iq - b.benchmark_baseline) / NULLIF(b.benchmark_baseline, 0))::numeric, 4) AS tv_match_rate
FROM employees e
JOIN profiles_psych ps ON e.employee_id = ps.employee_id
JOIN baseline b ON e.position_id = b.position_id AND b.tv_name = 'IQ'

UNION ALL

SELECT 
    e.employee_id,
    b.tv_name,
    ROUND((1 - ABS(ps.gtq - b.benchmark_baseline) / NULLIF(b.benchmark_baseline, 0))::numeric, 4) AS tv_match_rate
FROM employees e
JOIN profiles_psych ps ON e.employee_id = ps.employee_id
JOIN baseline b ON e.position_id = b.position_id AND b.tv_name = 'GTQ';