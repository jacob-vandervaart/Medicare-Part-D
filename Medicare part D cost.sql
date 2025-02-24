/*
Jacob Van Der Vaart
Medicare Part D drug prices 2018 - 2022
*/

-- Find the top 20 most prescribed drugs and their cost increases

SELECT
  Tot_Clms_2022 AS claims2022,
  Brnd_Name,
  Gnrc_Name,
  Avg_Spnd_Per_Clm_2018,
  Avg_Spnd_Per_Clm_2022,
  Avg_Spnd_Per_Bene_2022 - Avg_Spnd_Per_Clm_2018 AS price_increase,
  (Avg_Spnd_Per_Bene_2022 - Avg_Spnd_Per_Clm_2018)/Avg_Spnd_Per_Clm_2018 AS pct_increase
FROM
  `CMS.medicare_part_d`
WHERE
  Mftr_Name = "Overall" AND
  Avg_Spnd_Per_Clm_2018 <>0 AND 
  Avg_Spnd_Per_Clm_2018 IS NOT NULL AND
  Avg_Spnd_Per_Clm_2022 IS NOT NULL
ORDER BY
  claims2022 DESC
LIMIT
  20; 

-- identify the drugs that had the largest absolute increase in price from 2018 to 2022 
-- limiting to drugs with more than 200 beneficiaries in 2018 AND 2022
SELECT
  Brnd_Name,
  Gnrc_Name,
  Tot_Benes_2022,
  Avg_Spnd_Per_Clm_2018 AS cost2018,
  Avg_Spnd_Per_Clm_2022 AS cost2022,
  Tot_Mftr,
  (Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) AS price_change,
  ((Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018)/(Avg_Spnd_Per_Clm_2018))*100 AS pct_change
FROM
  `CMS.medicare_part_d`
WHERE
  Tot_Benes_2018 > 200
  AND Tot_Benes_2022 > 200
  AND Mftr_Name = "Overall"AND 
  Avg_Spnd_Per_Bene_2018 <> 0 AND 
  Avg_Spnd_Per_Clm_2018 IS NOT NULL AND
  Avg_Spnd_Per_Clm_2022 IS NOT NULL
ORDER BY
  price_change DESC
LIMIT
  10; 

-- Drugs with high cost increase all have high overall price and high percentage increase


-- identify the drugs that had the largest percentage increase in price from 2018 to 2022 
-- limiting to drugs with more than 200 beneficiaries in 2018 AND 2022
SELECT
  Brnd_Name,
  Gnrc_Name,
  Tot_Benes_2022,
  Avg_Spnd_Per_Clm_2018 AS cost2018,
  Avg_Spnd_Per_Clm_2022 AS cost2022,
  Tot_Mftr,
  (Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) AS increase,
  ((Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018)/(Avg_Spnd_Per_Clm_2018))*100 AS pct_increase
FROM
  `CMS.medicare_part_d`
WHERE
  Tot_Benes_2018 > 200
  AND Tot_Benes_2022 > 200
  AND Mftr_Name = "Overall"AND 
  Avg_Spnd_Per_Bene_2018 <> 0 AND 
  Avg_Spnd_Per_Clm_2018 IS NOT NULL AND
  Avg_Spnd_Per_Clm_2022 IS NOT NULL
ORDER BY
  pct_increase DESC
LIMIT
  20;

-- Answer question does having more manufaturers lead to higher price increases
SELECT
  CASE
    WHEN Tot_Mftr < 5 THEN CAST(Tot_Mftr AS STRING)
    WHEN Tot_Mftr >5 AND Tot_Mftr < 10 THEN "5-9"
    ELSE "10+"
  END AS mftr_group,
  COUNT(*) AS count,
  AVG(Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) AS avg_price_change,
  SUM(Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) / SUM(Avg_Spnd_Per_Clm_2018)*100 AS avg_pct_change
FROM
  `CMS.medicare_part_d`
WHERE
  Avg_Spnd_Per_Clm_2018 <> 0 AND 
  Avg_Spnd_Per_Clm_2018 IS NOT NULL AND
  Avg_Spnd_Per_Clm_2022 IS NOT NULL
GROUP BY
  mftr_group
ORDER BY
  mftr_group; 
-- drugs with more than 4 manufatureres showed price decreases while all others showed increases in price


-- Analyze what type of drugs are increasing the most in cost 
-- Use CTE to merge data and calculate price increase and percentage increase
WITH
  joined_data AS (
  SELECT
    Brnd_Name,
    Gnrc_Name,
    `Opioid Flag` AS is_opioid,
    `LA Opioid Flag` AS is_long_acting,
    `Antibiotic Flag` AS is_antibiotic,
    `Antipsychotic Flag` AS is_antipsychotic,
    Avg_Spnd_Per_Clm_2018,
    Avg_Spnd_Per_Clm_2022,
    (Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) AS price_change,
    (Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018)/(Avg_Spnd_Per_Clm_2018)*100 AS pct_change
  FROM
    `CMS.medicare_part_d` cost
  JOIN
    `CMS.drug_descriptions` description
  ON
    UPPER(cost.Brnd_Name) = description.`Drug Name` -- need to add upper becuase drug description has drug name in all caps
  WHERE
    Avg_Spnd_Per_Clm_2018 <> 0
    AND Avg_Spnd_Per_Clm_2022 <> 0 AND 
    Avg_Spnd_Per_Clm_2018 IS NOT NULL AND
    Avg_Spnd_Per_Clm_2022 IS NOT NULL
    AND Mftr_Name = 'Overall' )

  SELECT
  'Opioid' AS category,
  AVG(Avg_Spnd_Per_Clm_2018) AS avg_cost_2018,
  AVG(Avg_Spnd_Per_Clm_2022) AS avg_cost_2022,
  ROUND(AVG(price_change),2) AS avg_price_change,
  ROUND(AVG(pct_change),2) AS average_pct_change
FROM
  joined_data
WHERE
  is_opioid = TRUE
UNION ALL
SELECT
  'Long-Acting Opioid',
  AVG(Avg_Spnd_Per_Clm_2018) AS avg_cost_2018,
  AVG(Avg_Spnd_Per_Clm_2022) AS avg_cost_2022,
  ROUND(AVG(price_change),2) AS avg_price_change,
  ROUND(AVG(pct_change),2) AS average_pct_change
FROM
  joined_data
WHERE
  is_long_acting = TRUE
UNION ALL
SELECT
  'Antibiotic',
  AVG(Avg_Spnd_Per_Clm_2018) AS avg_cost_2018,
  AVG(Avg_Spnd_Per_Clm_2022) AS avg_cost_2022,
  ROUND(AVG(price_change),2) AS avg_price_change,
  ROUND(AVG(pct_change),2) AS average_pct_change
FROM
  joined_data
WHERE
  is_antibiotic = TRUE
UNION ALL
SELECT
  'Antipsychotic',
  AVG(Avg_Spnd_Per_Clm_2018) AS avg_cost_2018,
  AVG(Avg_Spnd_Per_Clm_2022) AS avg_cost_2022,
  ROUND(AVG(price_change),2) AS avg_price_change,
  ROUND(AVG(pct_change),2) AS average_pct_change
FROM
  joined_data
WHERE
  is_antipsychotic = TRUE;



-- Find percentage change in price per claim from 2018
-- only take the top 20 drugs in terms of total spending in 2018
SELECT 
  Brnd_Name,
  Gnrc_Name,
  cost, 
  RIGHT(year,4) AS year 
FROM (
  SELECT *,
  1.0 AS pct_change_2018,
  Avg_Spnd_Per_Clm_2019/Avg_Spnd_Per_Clm_2018 AS pct_change_2019,
  Avg_Spnd_Per_Clm_2020/Avg_Spnd_Per_Clm_2018 AS pct_change_2020,
  Avg_Spnd_Per_Clm_2021/Avg_Spnd_Per_Clm_2018 AS pct_change_2021,
  Avg_Spnd_Per_Clm_2022/Avg_Spnd_Per_Clm_2018 AS pct_change_2022,
  FROM `CMS.medicare_part_d`
  WHERE Mftr_Name = "Overall" AND
  Avg_Spnd_Per_Clm_2018 <>0 
  ORDER BY Tot_Spndng_2018 DESC
  LIMIT 20 
)
UNPIVOT (cost FOR year IN (pct_change_2018,pct_change_2019, pct_change_2020, pct_change_2021, pct_change_2022)) as unpivot
ORDER BY Brnd_Name, year;
