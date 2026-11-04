'''A. Recruitment overview'''

-- R01: Calculate total applications received
SELECT
    COUNT(*) AS total_applications
FROM recruitment_data_cleaned;

-- R02: Analyze monthly application trends
SELECT
    DATE_TRUNC('month', application_date)::DATE AS application_month,
    COUNT(*) AS total_applications
FROM recruitment_data_cleaned
WHERE application_date IS NOT NULL
GROUP BY application_month
ORDER BY application_month;

-- R03: Rank job titles by application volume
SELECT
    job_title,
    COUNT(*) AS total_applicants
FROM recruitment_data_cleaned
GROUP BY job_title
ORDER BY total_applicants DESC;

-- R04: Analyze recruitment pipeline status distribution
SELECT
    status,
    COUNT(*) AS applicant_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS applicant_percentage
FROM recruitment_data_cleaned
GROUP BY status
ORDER BY applicant_count DESC;

-- R05: Identify cities and states with the highest applicant volume
SELECT
    state,
    city,
    COUNT(*) AS applicant_count
FROM recruitment_data_cleaned
GROUP BY state, city
ORDER BY applicant_count DESC;

'''B. Applicant profiling'''

-- R06: Analyze applicant distribution by education level
SELECT
    education_level,
    COUNT(*) AS applicant_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS applicant_percentage
FROM recruitment_data_cleaned
GROUP BY education_level
ORDER BY applicant_count DESC;

-- R07: Compare average applicant experience across job titles
SELECT
    job_title,
    ROUND(AVG(years_of_experience), 2) AS avg_years_experience,
    MIN(years_of_experience) AS min_experience,
    MAX(years_of_experience) AS max_experience,
    COUNT(*) AS applicant_count
FROM recruitment_data_cleaned
WHERE years_of_experience IS NOT NULL
GROUP BY job_title
ORDER BY avg_years_experience DESC;

-- R08: Analyze applicant distribution by gender
SELECT
    gender,
    COUNT(*) AS applicant_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS applicant_percentage
FROM recruitment_data_cleaned
GROUP BY gender
ORDER BY applicant_count DESC;

-- R09: Segment applicants into age groups
WITH applicant_age AS (
    SELECT
        CASE
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 20 THEN 'Below 20'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 20 AND 29 THEN '20-29'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 30 AND 39 THEN '30-39'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 40 AND 49 THEN '40-49'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END AS age_group
    FROM recruitment_data_cleaned
    WHERE date_of_birth IS NOT NULL
      AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 0
)
SELECT
    age_group,
    COUNT(*) AS applicant_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS applicant_percentage
FROM applicant_age
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN 'Below 20' THEN 1
        WHEN '20-29' THEN 2
        WHEN '30-39' THEN 3
        WHEN '40-49' THEN 4
        WHEN '50-59' THEN 5
        ELSE 6
    END;

-- R10: Rank education levels by applicant count
SELECT
    education_level,
    COUNT(*) AS applicant_count
FROM recruitment_data_cleaned
GROUP BY education_level
ORDER BY applicant_count DESC;

-- R11: Calculate average desired salary
SELECT
    ROUND(AVG(desired_salary)::NUMERIC, 2) AS avg_desired_salary,
    MIN(desired_salary) AS minimum_desired_salary,
    MAX(desired_salary) AS maximum_desired_salary
FROM recruitment_data_cleaned
WHERE desired_salary > 0;

-- R12: Compare desired salary across job titles
SELECT
    job_title,
    ROUND(AVG(desired_salary)::NUMERIC, 2) AS avg_desired_salary,
    ROUND(MIN(desired_salary)::NUMERIC, 2) AS min_desired_salary,
    ROUND(MAX(desired_salary)::NUMERIC, 2) AS max_desired_salary,
    COUNT(*) AS applicant_count
FROM recruitment_data_cleaned
WHERE desired_salary > 0
GROUP BY job_title
ORDER BY avg_desired_salary DESC;

-- R13: Measure correlation between experience and desired salary
SELECT
    ROUND(
        CORR(years_of_experience, desired_salary)::NUMERIC,
        3
    ) AS experience_salary_correlation
FROM recruitment_data_cleaned
WHERE years_of_experience IS NOT NULL
  AND desired_salary > 0;


-- R14: Rank job titles by applicant experience
SELECT
    job_title,
    ROUND(AVG(years_of_experience), 2) AS avg_years_experience,
    COUNT(*) AS applicant_count
FROM recruitment_data_cleaned
WHERE years_of_experience IS NOT NULL
GROUP BY job_title
ORDER BY avg_years_experience DESC;

'''D. Recruitment pipeline analysis'''

-- R15: Analyze recruitment status across experience and education groups
SELECT
    education_level,
    CASE
        WHEN years_of_experience = 0 THEN 'Fresher'
        WHEN years_of_experience BETWEEN 1 AND 2 THEN '1-2 Years'
        WHEN years_of_experience BETWEEN 3 AND 5 THEN '3-5 Years'
        WHEN years_of_experience BETWEEN 6 AND 10 THEN '6-10 Years'
        WHEN years_of_experience > 10 THEN '10+ Years'
        ELSE 'Unknown'
    END AS experience_group,
    status,
    COUNT(*) AS applicant_count
FROM recruitment_data_cleaned
GROUP BY
    education_level,
    experience_group,
    status
ORDER BY
    education_level,
    experience_group,
    applicant_count DESC;