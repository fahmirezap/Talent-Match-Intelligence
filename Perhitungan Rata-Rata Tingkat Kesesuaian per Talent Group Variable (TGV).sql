CREATE TABLE tgv_match_summary AS
SELECT
    tm."Talent Group Variable (TGV)" AS talent_group_variable,
    ROUND(AVG(t.tv_match_rate)::numeric, 4) AS avg_match_rate
FROM
    tv_match_rates t
JOIN
    tgv_mapping tm ON t.tv_name = tm."Test as Talent Variable (TV)"
GROUP BY
    tm."Talent Group Variable (TGV)"
ORDER BY
    avg_match_rate DESC;