CREATE TABLE final_match_summary AS
SELECT
    e.employee_id,
    d.name AS directorate,
    p.name AS role,
    g.name AS grade,
    tm."Talent Group Variable (TGV)" AS tgv_name,
    t.tv_name,
    b.benchmark_baseline AS baseline_score,
    -- Dinamis berdasarkan tv_name
    CASE
        WHEN t.tv_name ILIKE 'IQ' THEN ps.iq
        WHEN t.tv_name ILIKE 'GTQ' THEN ps.gtq
        WHEN t.tv_name ILIKE 'TIKI' THEN ps.tiki
        WHEN t.tv_name ILIKE 'Pauli' THEN ps.pauli
        WHEN t.tv_name ILIKE 'Faxtor' THEN ps.faxtor
        WHEN t.tv_name ILIKE 'MBTI' THEN NULL  -- MBTI biasanya kategori, bukan skor numerik
        WHEN t.tv_name ILIKE 'DISC' THEN NULL  -- DISC juga kategori
        ELSE NULL
    END AS user_score,
    t.tv_match_rate,
    ROUND(tgv.avg_match_rate::numeric, 4) AS tgv_match_rate,
    ROUND(AVG(t.tv_match_rate) OVER (PARTITION BY e.employee_id)::numeric, 4) AS final_match_rate
FROM
    tv_match_rates t
JOIN
    employees e ON t.employee_id = e.employee_id
LEFT JOIN
    dim_directorates d ON e.directorate_id = d.directorate_id
LEFT JOIN
    dim_positions p ON e.position_id = p.position_id
LEFT JOIN
    dim_grades g ON e.grade_id = g.grade_id
JOIN
    tgv_mapping tm ON t.tv_name = tm."Test as Talent Variable (TV)"
JOIN
    tgv_match_summary tgv ON tm."Talent Group Variable (TGV)" = tgv.talent_group_variable
JOIN
    baseline b ON b.tv_name = t.tv_name
LEFT JOIN
    profiles_psych ps ON ps.employee_id = e.employee_id
ORDER BY
    e.employee_id, tm."Talent Group Variable (TGV)";