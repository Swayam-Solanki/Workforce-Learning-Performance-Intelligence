'''A. Training participation'''

-- T01: Calculate the total number of training records
SELECT
    COUNT(*) AS total_training_records
FROM employee_training_cleaned;

-- T02: Count unique employees who participated in training
SELECT
    COUNT(DISTINCT employee_id) AS unique_trained_employees
FROM employee_training_cleaned;

-- T03: Rank training programs by participation
SELECT
    training_program_name,
    COUNT(*) AS participation_count,
    COUNT(DISTINCT employee_id) AS unique_employees
FROM employee_training_cleaned
GROUP BY training_program_name
ORDER BY participation_count DESC;

-- T04: Analyze training participation by training type
SELECT
    training_type,
    COUNT(*) AS training_records,
    COUNT(DISTINCT employee_id) AS unique_employees
FROM employee_training_cleaned
GROUP BY training_type
ORDER BY training_records DESC;

-- T05: Analyze monthly training participation
SELECT
    DATE_TRUNC('month', training_date)::DATE AS training_month,
    COUNT(*) AS training_records,
    COUNT(DISTINCT employee_id) AS unique_employees
FROM employee_training_cleaned
WHERE training_date IS NOT NULL
GROUP BY training_month
ORDER BY training_month;

-- T06: Identify employees with multiple training records
SELECT
    employee_id,
    COUNT(*) AS total_training_records,
    COUNT(DISTINCT training_program_name) AS unique_training_programs
FROM employee_training_cleaned
GROUP BY employee_id
HAVING COUNT(*) > 1
ORDER BY total_training_records DESC;

-- T07: Identify employees without recorded training participation
SELECT
    e.empid,
    e.firstname,
    e.lastname,
    e.departmenttype,
    e.businessunit
FROM employees e
LEFT JOIN employee_training_cleaned t
    ON e.empid = t.employee_id
WHERE t.employee_id IS NULL
ORDER BY e.empid;

'''B. Training effectiveness'''

-- T08: Analyze the distribution of training outcomes
SELECT
    training_outcome,
    COUNT(*) AS outcome_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS outcome_percentage
FROM employee_training_cleaned
GROUP BY training_outcome
ORDER BY outcome_count DESC;

-- T09: Rank training programs by successful outcomes
SELECT
    training_program_name,
    COUNT(*) FILTER (
        WHERE training_outcome = 'Successful'
    ) AS successful_outcomes,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) FILTER (
            WHERE training_outcome = 'Successful'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS success_rate
FROM employee_training_cleaned
GROUP BY training_program_name
ORDER BY successful_outcomes DESC;

-- T10: Compare successful outcome rates across training types
SELECT
    training_type,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE training_outcome = 'Successful'
    ) AS successful_outcomes,
    ROUND(
        COUNT(*) FILTER (
            WHERE training_outcome = 'Successful'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS success_rate
FROM employee_training_cleaned
GROUP BY training_type
ORDER BY success_rate DESC;

-- T11: Rank trainers by successful training outcomes
SELECT
    trainer,
    COUNT(*) FILTER (
        WHERE training_outcome = 'Successful'
    ) AS successful_outcomes,
    COUNT(*) AS total_training_records,
    ROUND(
        COUNT(*) FILTER (
            WHERE training_outcome = 'Successful'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS success_rate
FROM employee_training_cleaned
GROUP BY trainer
ORDER BY successful_outcomes DESC;

-- T12: Compare training duration with outcome performance
SELECT
    training_outcome,
    ROUND(AVG(training_duration_days), 2) AS avg_training_duration,
    COUNT(*) AS training_records
FROM employee_training_cleaned
WHERE training_duration_days IS NOT NULL
GROUP BY training_outcome
ORDER BY avg_training_duration DESC;

-- T13: Compare training success rates across locations
SELECT
    location,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE training_outcome = 'Successful'
    ) AS successful_outcomes,
    ROUND(
        COUNT(*) FILTER (
            WHERE training_outcome = 'Successful'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS success_rate
FROM employee_training_cleaned
GROUP BY location
ORDER BY success_rate DESC;

-- T13: Compare training success rates across locations
SELECT
    location,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE training_outcome = 'Successful'
    ) AS successful_outcomes,
    ROUND(
        COUNT(*) FILTER (
            WHERE training_outcome = 'Successful'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS success_rate
FROM employee_training_cleaned
GROUP BY location
ORDER BY success_rate DESC;

'''C. Training investment and cost'''

-- T14: Calculate total training expenditure
SELECT
    ROUND(SUM(training_cost)::NUMERIC, 2) AS total_training_expenditure
FROM employee_training_cleaned;

-- T15: Calculate average cost per training record
SELECT
    ROUND(AVG(training_cost)::NUMERIC, 2) AS avg_training_cost
FROM employee_training_cleaned;

-- T16: Rank training programs by total expenditure
SELECT
    training_program_name,
    ROUND(SUM(training_cost)::NUMERIC, 2) AS total_expenditure,
    COUNT(*) AS training_records
FROM employee_training_cleaned
GROUP BY training_program_name
ORDER BY total_expenditure DESC;

-- T17: Compare average training expenditure by training type
SELECT
    training_type,
    ROUND(AVG(training_cost)::NUMERIC, 2) AS avg_training_cost,
    ROUND(SUM(training_cost)::NUMERIC, 2) AS total_expenditure,
    COUNT(*) AS training_records
FROM employee_training_cleaned
GROUP BY training_type
ORDER BY avg_training_cost DESC;

-- T18: Calculate average expenditure per successful training record
SELECT
    ROUND(
        SUM(training_cost) FILTER (
            WHERE training_outcome = 'Successful'
        )::NUMERIC
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE training_outcome = 'Successful'
            ),
            0
        ),
        2
    ) AS avg_cost_per_successful_outcome
FROM employee_training_cleaned;

-- T19: Compare training program success rates and cost efficiency
SELECT
    training_program_name,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE training_outcome = 'Successful'
    ) AS successful_outcomes,
    ROUND(
        COUNT(*) FILTER (
            WHERE training_outcome = 'Successful'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS success_rate,
    ROUND(
        SUM(training_cost)::NUMERIC,
        2
    ) AS total_cost,
    ROUND(
        SUM(training_cost) FILTER (
            WHERE training_outcome = 'Successful'
        )::NUMERIC
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE training_outcome = 'Successful'
            ),
            0
        ),
        2
    ) AS cost_per_successful_outcome
FROM employee_training_cleaned
GROUP BY training_program_name
ORDER BY cost_per_successful_outcome ASC NULLS LAST;

'''D. Training and employee performance'''

-- T20: Compare performance distribution between trained and untrained employees
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
    COUNT(*) AS employee_count
FROM employees e
LEFT JOIN training_participation t
    ON e.empid = t.employee_id
GROUP BY training_group, e.performance_score
ORDER BY training_group, employee_count DESC;

-- T21: Compare average employee ratings by training participation
WITH training_participation AS (
    SELECT DISTINCT employee_id
    FROM employee_training_cleaned
)
SELECT
    CASE
        WHEN t.employee_id IS NOT NULL THEN 'Trained'
        ELSE 'Not Trained'
    END AS training_group,
    ROUND(AVG(e.current_employee_rating)::NUMERIC, 2) AS avg_employee_rating,
    COUNT(*) AS employee_count
FROM employees e
LEFT JOIN training_participation t
    ON e.empid = t.employee_id
GROUP BY training_group
ORDER BY avg_employee_rating DESC;

-- T22: Analyze employee performance by number of training records
WITH employee_training_count AS (
    SELECT
        employee_id,
        COUNT(*) AS training_count
    FROM employee_training_cleaned
    GROUP BY employee_id
)
SELECT
    CASE
        WHEN COALESCE(t.training_count, 0) = 0 THEN 'No Training'
        WHEN t.training_count = 1 THEN '1 Training'
        WHEN t.training_count BETWEEN 2 AND 3 THEN '2-3 Trainings'
        ELSE '4+ Trainings'
    END AS training_group,
    e.performance_score,
    COUNT(*) AS employee_count,
    ROUND(AVG(e.current_employee_rating)::NUMERIC, 2) AS avg_employee_rating
FROM employees e
LEFT JOIN employee_training_count t
    ON e.empid = t.employee_id
GROUP BY training_group, e.performance_score
ORDER BY training_group, employee_count DESC;

-- T23: Examine training participation among employees needing improvement
SELECT
    e.performance_score,
    COUNT(DISTINCT e.empid) AS employee_count,
    COUNT(DISTINCT t.employee_id) AS trained_employees,
    COUNT(DISTINCT e.empid)
        - COUNT(DISTINCT t.employee_id) AS employees_without_training,
    ROUND(
        COUNT(DISTINCT t.employee_id) * 100.0
        / NULLIF(COUNT(DISTINCT e.empid), 0),
        2
    ) AS training_participation_percentage
FROM employees e
LEFT JOIN employee_training_cleaned t
    ON e.empid = t.employee_id
WHERE e.performance_score IN ('Needs Improvement', 'PIP')
GROUP BY e.performance_score
ORDER BY training_participation_percentage ASC;

-- T24: Analyze training expenditure across business units and departments
SELECT
    e.businessunit,
    e.departmenttype,
    COUNT(t.employee_id) AS training_records,
    COUNT(DISTINCT e.empid) AS employees,
    ROUND(SUM(t.training_cost)::NUMERIC, 2) AS total_training_expenditure,
    ROUND(AVG(t.training_cost)::NUMERIC, 2) AS avg_training_cost
FROM employees e
JOIN employee_training_cleaned t
    ON e.empid = t.employee_id
GROUP BY e.businessunit, e.departmenttype
ORDER BY total_training_expenditure DESC NULLS LAST;

-- T25: Compare employment status by training participation
WITH training_participation AS (
    SELECT DISTINCT employee_id
    FROM employee_training_cleaned
)
SELECT
    CASE
        WHEN t.employee_id IS NOT NULL THEN 'Trained'
        ELSE 'Not Trained'
    END AS training_group,
    e.employeestatus,
    COUNT(*) AS employee_count,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY
                CASE
                    WHEN t.employee_id IS NOT NULL THEN 'Trained'
                    ELSE 'Not Trained'
                END
        ),
        2
    ) AS status_percentage
FROM employees e
LEFT JOIN training_participation t
    ON e.empid = t.employee_id
GROUP BY training_group, e.employeestatus
ORDER BY training_group, employee_count DESC;
