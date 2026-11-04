'''A. Training and employee performance'''

-- I01: Compare employee performance between trained and untrained groups
WITH training_participation AS (
    SELECT DISTINCT employee_id
    FROM employee_training_cleaned
)
SELECT
    CASE
        WHEN t.employee_id IS NOT NULL THEN 'Trained'
        ELSE 'Not Trained'
    END AS training_group,
    e.performance_score,
    COUNT(*) AS employee_count,
    ROUND(AVG(e.current_employee_rating)::NUMERIC, 2) AS avg_employee_rating
FROM employees e
LEFT JOIN training_participation t
    ON e.empid = t.employee_id
GROUP BY training_group, e.performance_score
ORDER BY training_group, employee_count DESC;

-- I02: Compare employee ratings by training participation frequency
WITH training_counts AS (
    SELECT
        employee_id,
        COUNT(*) AS total_training_records
    FROM employee_training_cleaned
    GROUP BY employee_id
)
SELECT
    CASE
        WHEN COALESCE(t.total_training_records, 0) = 0 THEN 'No Training'
        WHEN t.total_training_records = 1 THEN '1 Training'
        WHEN t.total_training_records BETWEEN 2 AND 3 THEN '2-3 Trainings'
        ELSE '4+ Trainings'
    END AS training_group,
    COUNT(*) AS employee_count,
    ROUND(AVG(e.current_employee_rating)::NUMERIC, 2) AS avg_employee_rating
FROM employees e
LEFT JOIN training_counts t
    ON e.empid = t.employee_id
GROUP BY training_group
ORDER BY avg_employee_rating DESC;

-- I03: Compare average engagement with employee performance scores
WITH employee_engagement AS (
    SELECT
        employee_id,
        AVG(engagement_score) AS avg_engagement_score
    FROM engagement_surveys
    GROUP BY employee_id
)
SELECT
    e.performance_score,
    COUNT(*) AS employee_count,
    ROUND(AVG(ee.avg_engagement_score)::NUMERIC, 2) AS avg_engagement_score,
    ROUND(AVG(e.current_employee_rating)::NUMERIC, 2) AS avg_employee_rating
FROM employees e
JOIN employee_engagement ee
    ON e.empid = ee.employee_id
GROUP BY e.performance_score
ORDER BY avg_engagement_score DESC;

-- I04: Compare employee exit rates across engagement groups
WITH employee_engagement AS (
    SELECT
        employee_id,
        AVG(engagement_score) AS avg_engagement_score
    FROM engagement_surveys
    GROUP BY employee_id
),
employee_groups AS (
    SELECT
        e.empid,
        CASE
            WHEN ee.avg_engagement_score < 3 THEN 'Low Engagement'
            WHEN ee.avg_engagement_score < 4 THEN 'Moderate Engagement'
            ELSE 'High Engagement'
        END AS engagement_group,
        CASE
            WHEN e.employeestatus IN (
                'Voluntarily Terminated',
                'Terminated for Cause'
            ) THEN 1
            ELSE 0
        END AS exited
    FROM employees e
    JOIN employee_engagement ee
        ON e.empid = ee.employee_id
)
SELECT
    engagement_group,
    COUNT(*) AS employee_count,
    SUM(exited) AS exited_employees,
    ROUND(
        SUM(exited) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS exit_percentage
FROM employee_groups
GROUP BY engagement_group
ORDER BY exit_percentage DESC;

'''C. Training investment and workforce distribution'''

-- I05: Compare training investment across departments
SELECT
    e.departmenttype,
    COUNT(t.employee_id) AS training_records,
    COUNT(DISTINCT e.empid) AS employee_count,
    ROUND(SUM(t.training_cost)::NUMERIC, 2) AS total_training_investment,
    ROUND(AVG(t.training_cost)::NUMERIC, 2) AS avg_cost_per_training_record
FROM employees e
JOIN employee_training_cleaned t
    ON e.empid = t.employee_id
GROUP BY e.departmenttype
ORDER BY total_training_investment DESC;

-- I06: Compare training participation across employee statuses
WITH training_counts AS (
    SELECT
        employee_id,
        COUNT(*) AS training_records
    FROM employee_training_cleaned
    GROUP BY employee_id
)
SELECT
    e.employeestatus,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (
        WHERE COALESCE(t.training_records, 0) > 0
    ) AS trained_employees,
    COUNT(*) FILTER (
        WHERE COALESCE(t.training_records, 0) = 0
    ) AS untrained_employees,
    ROUND(
        COUNT(*) FILTER (
            WHERE COALESCE(t.training_records, 0) > 0
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS training_participation_percentage
FROM employees e
LEFT JOIN training_counts t
    ON e.empid = t.employee_id
GROUP BY e.employeestatus
ORDER BY training_participation_percentage DESC;

-- I07: Compare active employment rates by training participation
WITH training_participation AS (
    SELECT DISTINCT employee_id
    FROM employee_training_cleaned
)
SELECT
    CASE
        WHEN t.employee_id IS NOT NULL THEN 'Trained'
        ELSE 'Not Trained'
    END AS training_group,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (
        WHERE e.employeestatus = 'Active'
    ) AS active_employees,
    ROUND(
        COUNT(*) FILTER (
            WHERE e.employeestatus = 'Active'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS active_employee_percentage
FROM employees e
LEFT JOIN training_participation t
    ON e.empid = t.employee_id
GROUP BY training_group
ORDER BY active_employee_percentage DESC;

-- I08: Compare department performance with training investment
WITH department_training AS (
    SELECT
        e.departmenttype,
        COUNT(t.employee_id) AS training_records,
        ROUND(SUM(t.training_cost)::NUMERIC, 2) AS total_training_investment
    FROM employees e
    LEFT JOIN employee_training_cleaned t
        ON e.empid = t.employee_id
    GROUP BY e.departmenttype
),
department_performance AS (
    SELECT
        departmenttype,
        COUNT(*) AS employee_count,
        COUNT(*) FILTER (
            WHERE performance_score IN ('Needs Improvement', 'PIP')
        ) AS low_performance_employees,
        ROUND(
            COUNT(*) FILTER (
                WHERE performance_score IN ('Needs Improvement', 'PIP')
            ) * 100.0 / NULLIF(COUNT(*), 0),
            2
        ) AS low_performance_percentage
    FROM employees
    GROUP BY departmenttype
)
SELECT
    p.departmenttype,
    p.employee_count,
    p.low_performance_employees,
    p.low_performance_percentage,
    t.training_records,
    COALESCE(t.total_training_investment, 0) AS total_training_investment
FROM department_performance p
LEFT JOIN department_training t
    ON p.departmenttype = t.departmenttype
ORDER BY p.low_performance_percentage DESC;


'''D. Integrated engagement, training and workforce insights'''

-- I09: Compare training participation by employee satisfaction level
WITH employee_satisfaction AS (
    SELECT
        employee_id,
        AVG(satisfaction_score) AS avg_satisfaction_score
    FROM engagement_surveys
    GROUP BY employee_id
),
employee_training AS (
    SELECT
        employee_id,
        COUNT(*) AS training_records,
        COUNT(DISTINCT training_program_name) AS unique_training_programs
    FROM employee_training_cleaned
    GROUP BY employee_id
)
SELECT
    CASE
        WHEN s.avg_satisfaction_score < 3 THEN 'Low Satisfaction'
        WHEN s.avg_satisfaction_score < 4 THEN 'Moderate Satisfaction'
        ELSE 'High Satisfaction'
    END AS satisfaction_group,
    COUNT(*) AS employee_count,
    ROUND(AVG(COALESCE(t.training_records, 0))::NUMERIC, 2) AS avg_training_records,
    ROUND(AVG(COALESCE(t.unique_training_programs, 0))::NUMERIC, 2) AS avg_unique_training_programs
FROM employee_satisfaction s
LEFT JOIN employee_training t
    ON s.employee_id = t.employee_id
GROUP BY satisfaction_group
ORDER BY avg_training_records DESC;

-- I10: Build an integrated department-level workforce performance analysis
WITH department_engagement AS (
    SELECT
        e.departmenttype,
        ROUND(AVG(s.engagement_score)::NUMERIC, 2) AS avg_engagement_score,
        ROUND(AVG(s.satisfaction_score)::NUMERIC, 2) AS avg_satisfaction_score
    FROM employees e
    JOIN engagement_surveys s
        ON e.empid = s.employee_id
    GROUP BY e.departmenttype
),
department_performance AS (
    SELECT
        departmenttype,
        COUNT(*) AS employee_count,
        ROUND(AVG(current_employee_rating)::NUMERIC, 2) AS avg_employee_rating,
        COUNT(*) FILTER (
            WHERE performance_score = 'Exceeds'
        ) AS high_performers
    FROM employees
    GROUP BY departmenttype
),
department_training AS (
    SELECT
        e.departmenttype,
        COUNT(t.employee_id) AS training_records,
        ROUND(AVG(t.training_cost)::NUMERIC, 2) AS avg_training_cost,
        ROUND(
            COUNT(*) FILTER (
                WHERE t.training_outcome = 'Successful'
            ) * 100.0 / NULLIF(COUNT(t.employee_id), 0),
            2
        ) AS training_success_rate
    FROM employees e
    LEFT JOIN employee_training_cleaned t
        ON e.empid = t.employee_id
    GROUP BY e.departmenttype
)
SELECT
    p.departmenttype,
    p.employee_count,
    en.avg_engagement_score,
    en.avg_satisfaction_score,
    p.avg_employee_rating,
    p.high_performers,
    tr.training_records,
    tr.avg_training_cost,
    tr.training_success_rate
FROM department_performance p
LEFT JOIN department_engagement en
    ON p.departmenttype = en.departmenttype
LEFT JOIN department_training tr
    ON p.departmenttype = tr.departmenttype
ORDER BY
    en.avg_engagement_score DESC NULLS LAST,
    p.avg_employee_rating DESC NULLS LAST,
    tr.training_success_rate DESC NULLS LAST;

