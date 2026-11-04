''' A. Workforce composition'''

-- E01: Calculate total employee headcount

SELECT COUNT(*) AS total_employees
FROM employees;

-- E02: Analyze employee distribution by employment status

SELECT
    employeestatus,
    COUNT(*) AS employee_count
FROM employees
GROUP BY employeestatus
ORDER BY employee_count DESC;

-- E03: Identify workforce concentration across business units

SELECT
    businessunit,
    COUNT(*) AS employee_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS workforce_percentage
FROM employees
GROUP BY businessunit
ORDER BY employee_count DESC;

-- E04: Analyze workforce distribution by department and division

SELECT
    departmenttype,
    division,
    COUNT(*) AS employee_count
FROM employees
GROUP BY departmenttype, division
ORDER BY employee_count DESC;

-- E05: Analyze employee distribution by employment type

SELECT
    employeetype,
    COUNT(*) AS employee_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS workforce_percentage
FROM employees
GROUP BY employeetype
ORDER BY employee_count DESC;

-- E06: Analyze workforce distribution by pay zone and classification

SELECT
    payzone,
    employeeclassificationtype,
    COUNT(*) AS employee_count
FROM employees
GROUP BY payzone, employeeclassificationtype
ORDER BY payzone, employee_count DESC;

-- E07: Analyze workforce demographics by gender and marital status

SELECT
    gendercode,
    maritaldesc,
    COUNT(*) AS employee_count
FROM employees
GROUP BY gendercode, maritaldesc
ORDER BY employee_count DESC;

'''B. Employee lifecycle and retention'''

-- E08: Calculate total employees who have exited the organization

SELECT
    COUNT(*) AS total_exited_employees
FROM employees
WHERE employeestatus IN (
    'Voluntarily Terminated',
    'Terminated for Cause'
);

-- E09: Identify the most common employee termination types

SELECT
    terminationtype,
    COUNT(*) AS termination_count
FROM employees
WHERE employeestatus IN (
    'Voluntarily Terminated',
    'Terminated for Cause'
)
GROUP BY terminationtype
ORDER BY termination_count DESC;

-- E10: Identify departments with the highest employee exits

SELECT
    departmenttype,
    COUNT(*) AS employee_exits
FROM employees
WHERE employeestatus IN (
    'Voluntarily Terminated',
    'Terminated for Cause'
)
GROUP BY departmenttype
ORDER BY employee_exits DESC;

-- E11: Analyze voluntary terminations across business units

SELECT
    businessunit,
    COUNT(*) AS voluntary_terminations
FROM employees
WHERE employeestatus = 'Voluntarily Terminated'
GROUP BY businessunit
ORDER BY voluntary_terminations DESC;

-- E12: Analyze employee exits by year and month

SELECT
    DATE_TRUNC('month', exitdate)::DATE AS exit_month,
    COUNT(*) AS employee_exits
FROM employees
WHERE exitdate IS NOT NULL
GROUP BY exit_month
ORDER BY exit_month;

-- E13: Compare average organizational tenure across employee groups

SELECT
    employeetype,
    ROUND(
        AVG(
            (COALESCE(exitdate, CURRENT_DATE) - startdate)::NUMERIC / 365.25
        ), 2
    ) AS avg_tenure_years,
    COUNT(*) AS employee_count
FROM employees
GROUP BY employeetype
ORDER BY avg_tenure_years ASC;

-- E14: Identify supervisors with the highest employee exits

SELECT
    supervisor,
    COUNT(*) AS employee_exits
FROM employees
WHERE employeestatus IN (
    'Voluntarily Terminated',
    'Terminated for Cause'
)
GROUP BY supervisor
ORDER BY employee_exits DESC;

'''C. Employee performance'''

-- E15: Analyze employee performance score distribution

SELECT
    performance_score,
    COUNT(*) AS employee_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS percentage
FROM employees
GROUP BY performance_score
ORDER BY employee_count DESC;

-- E16: Calculate high-performing employee percentage by department

SELECT
    departmenttype,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (
        WHERE performance_score = 'Exceeds'
    ) AS high_performers,
    ROUND(
        COUNT(*) FILTER (
            WHERE performance_score = 'Exceeds'
        ) * 100.0 / COUNT(*), 2
    ) AS high_performer_percentage
FROM employees
GROUP BY departmenttype
ORDER BY high_performer_percentage DESC;

-- E17: Analyze performance distribution across business units

SELECT
    businessunit,
    performance_score,
    COUNT(*) AS employee_count
FROM employees
GROUP BY businessunit, performance_score
ORDER BY businessunit, employee_count DESC;

-- E18: Analyze current employee rating distribution

SELECT
    current_employee_rating,
    COUNT(*) AS employee_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS percentage
FROM employees
GROUP BY current_employee_rating
ORDER BY current_employee_rating;

-- E19: Compare performance scores across employment statuses

SELECT
    employeestatus,
    performance_score,
    COUNT(*) AS employee_count
FROM employees
WHERE employeestatus IN (
    'Active',
    'Voluntarily Terminated',
    'Terminated for Cause'
)
GROUP BY employeestatus, performance_score
ORDER BY employeestatus, employee_count DESC;