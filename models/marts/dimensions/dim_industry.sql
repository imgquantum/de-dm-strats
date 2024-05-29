{{ config(materialized='table', schema='model_strats') }}

SELECT DISTINCT Industry AS industry_name
FROM {{ source('stg_tape', 'tape_general') }}
WHERE Industry IS NOT NULL
AND Industry NOT IN (
    SELECT industry_name FROM {{ this }}
)
ORDER BY Industry