'''A. Engagement overview'''

-- G01: Calculate the average employee engagement score
SELECT
    ROUND(AVG(engagement_score), 2) AS avg_engagement_score
FROM engagement_surveys;

-- G02: Calculate the average employee satisfaction score
SELECT
    ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score
FROM engagement_surveys;

-- G03: Calculate the average work-life balance score
SELECT
    ROUND(AVG(work_life_balance_score), 2) AS avg_work_life_balance_score
FROM engagement_surveys;

-- G04: Analyze the distribution of employee engagement scores
SELECT
    engagement_score,
    COUNT(*) AS survey_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM engagement_surveys
GROUP BY engagement_score
ORDER BY engagement_score;

-- G05: Segment employees based on engagement scores
WITH engagement_segments AS (
    SELECT
        CASE
            WHEN engagement_score BETWEEN 1 AND 2 THEN 'Low'
            WHEN engagement_score = 3 THEN 'Moderate'
            WHEN engagement_score BETWEEN 4 AND 5 THEN 'High'
            ELSE 'Outside Defined Scale'
        END AS engagement_level
    FROM engagement_surveys
)
SELECT
    engagement_level,
    COUNT(*) AS employee_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM engagement_segments
GROUP BY engagement_level
ORDER BY
    CASE engagement_level
        WHEN 'Low' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'High' THEN 3
        ELSE 4
    END;

'''A. Engagement segmentation'''

-- G06: Identify departments with the lowest average engagement
SELECT
    e.departmenttype,
    ROUND(AVG(s.engagement_score), 2) AS avg_engagement_score,
    COUNT(*) AS survey_count
FROM engagement_surveys s
JOIN employees e
    ON s.employee_id = e.empid
GROUP BY e.departmenttype
ORDER BY avg_engagement_score ASC;

-- G07: Compare average employee satisfaction across business units
SELECT
    e.businessunit,
    ROUND(AVG(s.satisfaction_score), 2) AS avg_satisfaction_score,
    COUNT(*) AS survey_count
FROM engagement_surveys s
JOIN employees e
    ON s.employee_id = e.empid
GROUP BY e.businessunit
ORDER BY avg_satisfaction_score DESC;

-- G08: Analyze work-life balance across departments
SELECT
    e.departmenttype,
    ROUND(AVG(s.work_life_balance_score), 2) AS avg_work_life_balance,
    COUNT(*) AS survey_count
FROM engagement_surveys s
JOIN employees e
    ON s.employee_id = e.empid
GROUP BY e.departmenttype
ORDER BY avg_work_life_balance ASC;

-- G09: Compare satisfaction across employee groups
SELECT
    e.employeetype,
    e.employeestatus,
    ROUND(AVG(s.satisfaction_score), 2) AS avg_satisfaction_score,
    COUNT(*) AS survey_count
FROM engagement_surveys s
JOIN employees e
    ON s.employee_id = e.empid
GROUP BY
    e.employeetype,
    e.employeestatus
ORDER BY avg_satisfaction_score ASC;

-- G10: Track average engagement scores over time
SELECT
    DATE_TRUNC('month', survey_date)::DATE AS survey_month,
    ROUND(AVG(engagement_score), 2) AS avg_engagement_score,
    COUNT(*) AS survey_count
FROM engagement_surveys
WHERE survey_date IS NOT NULL
GROUP BY survey_month
ORDER BY survey_month;

-- G11: Measure correlation between engagement and satisfaction
SELECT
    ROUND(
        CORR(engagement_score, satisfaction_score)::NUMERIC,
        3
    ) AS engagement_satisfaction_correlation
FROM engagement_surveys
WHERE engagement_score IS NOT NULL
  AND satisfaction_score IS NOT NULL;

  -- G12: Compare work-life balance across engagement levels
SELECT
    CASE
        WHEN engagement_score BETWEEN 1 AND 2 THEN 'Low'
        WHEN engagement_score = 3 THEN 'Moderate'
        WHEN engagement_score BETWEEN 4 AND 5 THEN 'High'
        ELSE 'Outside Defined Scale'
    END AS engagement_level,
    ROUND(AVG(work_life_balance_score), 2) AS avg_work_life_balance,
    COUNT(*) AS survey_count
FROM engagement_surveys
GROUP BY engagement_level
ORDER BY avg_work_life_balance ASC;

'''C. Engagement and workforce performance'''

-- G13: Compare engagement with employee performance scores
SELECT
    e.performance_score,
    ROUND(AVG(s.engagement_score), 2) AS avg_engagement_score,
    COUNT(*) AS survey_count
FROM engagement_surveys s
JOIN employees e
    ON s.employee_id = e.empid
GROUP BY e.performance_score
ORDER BY avg_engagement_score DESC;

-- G14: Compare satisfaction between active and exited employees
SELECT
    CASE
        WHEN e.employeestatus = 'Active' THEN 'Active'
        WHEN e.employeestatus IN (
            'Voluntarily Terminated',
            'Terminated for Cause'
        ) THEN 'Exited'
        ELSE 'Other Employment Status'
    END AS employment_group,
    ROUND(AVG(s.satisfaction_score), 2) AS avg_satisfaction_score,
    COUNT(*) AS survey_count
FROM engagement_surveys s
JOIN employees e
    ON s.employee_id = e.empid
GROUP BY employment_group
ORDER BY avg_satisfaction_score DESC;

-- G15: Compare engagement between trained and untrained employees
WITH training_participation AS (
    SELECT DISTINCT employee_id
    FROM employee_training_cleaned
)
SELECT
    CASE
        WHEN t.employee_id IS NOT NULL THEN 'Participated in Training'
        ELSE 'No Training Recorded'
    END AS training_group,
    ROUND(AVG(s.engagement_score), 2) AS avg_engagement_score,
    COUNT(*) AS survey_count
FROM engagement_surveys s
LEFT JOIN training_participation t
    ON s.employee_id = t.employee_id
GROUP BY training_group
ORDER BY avg_engagement_score DESC;