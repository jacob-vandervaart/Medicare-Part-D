  -- Medicare Part D Drug spending 2018 - 2022 -- Jacob Van Der Vaart  
  -- exploring drug leaders FOR various metrics -- identify top drugs BY number OF beneficiaries 2022

SELECT
  Tot_Benes_2022 AS bens2022,
  Brnd_Name,
  Gnrc_Name,
  Mftr_Name
FROM
  `clean-hangar-449116-q8.CMS.medicare_part_d`
WHERE
  Mftr_Name = "Overall"
ORDER BY
  bens2022 DESC
LIMIT
  20; 
  
-- identify top drugs BY number OF prescriptions 2022
SELECT
  Tot_Clms_2022 AS claims2022,
  Brnd_Name,
  Gnrc_Name,
  Mftr_Name
FROM
  `clean-hangar-449116-q8.CMS.medicare_part_d`
WHERE
  Mftr_Name = "Overall"
ORDER BY
  claims2022 DESC
LIMIT
  20; 
  
-- identify top drugs BY cost OF drug 2022
SELECT
  Tot_Spndng_2022,
  Brnd_Name,
  Gnrc_Name,
  Mftr_Name,
  Avg_Spnd_Per_Clm_2022
FROM
  `clean-hangar-449116-q8.CMS.medicare_part_d`
WHERE
  Mftr_Name = "Overall"
ORDER BY
  Avg_Spnd_Per_Clm_2022 DESC
LIMIT
  20; 

-- Examen increases from 2018 TO 2022 
-- identify the drugs that had the largest increase IN number OF beneficiaries from 2018 TO 2022
SELECT
  Brnd_Name,
  Gnrc_Name,
  Mftr_Name,
  Tot_Benes_2018 AS bens2018,
  Tot_Benes_2022 AS bens2022,
  (Tot_Benes_2022 - Tot_Benes_2018) AS increase
FROM
  `clean-hangar-449116-q8.CMS.medicare_part_d`
WHERE
  Mftr_Name = "Overall"
ORDER BY
  increase DESC
LIMIT
  20; 
-- identify the drugs that had the largest percentage increase in number of beneficiaries from 2018 to 2022 
-- limiting to drugs with more than 100 beneficiaries in 2018 and 2022
SELECT
  Brnd_Name,
  Gnrc_Name,
  Mftr_Name,
  Tot_Benes_2018 AS bens2018,
  Tot_Benes_2022 AS bens2022,
  ((Tot_Benes_2022 - Tot_Benes_2018)/(Tot_Benes_2018)) AS pct_increase
FROM
  `clean-hangar-449116-q8.CMS.medicare_part_d`
WHERE
  Tot_Benes_2018 > 100
  AND Tot_Benes_2022 >100
  AND Mftr_Name = "Overall"
  AND Tot_Benes_2018 <> 0
ORDER BY
  pct_increase DESC
LIMIT
  20; 
  
-- identify the drugs that had the largest percentage increase in number of price from 2018 to 2022 
-- limiting to drugs with more than 1000 beneficiaries in 2018 AND 2022
SELECT
  Brnd_Name,
  Gnrc_Name,
  Mftr_Name,
  Avg_Spnd_Per_Clm_2018 AS cost2018,
  Avg_Spnd_Per_Clm_2022 AS cost2022,
  Tot_Mftr,
  (Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) AS increase,
  ((Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018)/(Avg_Spnd_Per_Clm_2018)) AS pct_increase
FROM
  `clean-hangar-449116-q8.CMS.medicare_part_d`
WHERE
  Tot_Benes_2018 > 1000
  AND Tot_Benes_2022 >1000
  AND Mftr_Name = "Overall"AND Avg_Spnd_Per_Bene_2018 <> 0
ORDER BY
  increase DESC; 
  
-- Answer question does having more manufaturers lead To lower cost increases or to a decreas in price
SELECT
  CASE
    WHEN Tot_Mftr = 1 THEN '1'
    WHEN Tot_Mftr < 10 THEN '1-9'
    ELSE '10+'
END
  AS mftr_group,
  COUNT(*) AS count,
  AVG(Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) AS avg_increase,
  AVG((Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018)/Avg_Spnd_Per_Clm_2018) AS avg_pct_increase
FROM
  `clean-hangar-449116-q8.CMS.medicare_part_d`
WHERE
  Avg_Spnd_Per_Clm_2018 <> 0
GROUP BY
  mftr_group; 

-- same analysis with a larger number of levels
SELECT
  CASE
    WHEN Tot_Mftr < 10 THEN CAST(Tot_Mftr AS STRING)
    ELSE "10+"
END
  AS mftr_group,
  COUNT(*) AS count,
  AVG(Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) AS avg_increase,
  AVG((Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018)/Avg_Spnd_Per_Clm_2018) AS avg_pct_increase
FROM
  `clean-hangar-449116-q8.CMS.medicare_part_d`
WHERE
  Avg_Spnd_Per_Clm_2018 <> 0
GROUP BY
  mftr_group
ORDER BY
  mftr_group; 
  
-- Analyze what type of drugs are increasing the most in terms of prescriptions and cost 

-- CTE to merge data and calculate price increase and percentage increase
WITH
  joined_data AS (
  SELECT
    Brnd_Name,
    Gnrc_Name,
    `Opioid Flag` AS is_opioid,
    `LA Opioid Flag` AS is_long_acting,
    `Antibiotic Flag` AS is_antibiotic,
    `Antipsychotic Flag` AS is_antipsychotic,
    (Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018) AS increase,
    ((Avg_Spnd_Per_Clm_2022 - Avg_Spnd_Per_Clm_2018)/(Avg_Spnd_Per_Clm_2018)) AS pct_increase
  FROM
    `clean-hangar-449116-q8.CMS.medicare_part_d` cost
  JOIN
    `clean-hangar-449116-q8.CMS.drug_descriptions` description
  ON
    UPPER(cost.Brnd_Name) = description.`Drug Name` -- need TO ADD upper becuase drug description has ALL caps
  WHERE
    Avg_Spnd_Per_Clm_2018 <> 0
    AND Avg_Spnd_Per_Clm_2022 <> 0
    AND Mftr_Name = 'Overall' ) 
    
-- Average for all categories
SELECT
  'Opioid' AS category,
  ROUND(AVG(increase),2) AS avg_cost_increase,
  ROUND(AVG(joined_data.pct_increase)*100,2) AS average_pct_increase
FROM
  joined_data
WHERE
  is_opioid = TRUE
UNION ALL
SELECT
  'Long-Acting Opioid',
  ROUND(AVG(increase),2) AS avg_cost_increase,
  ROUND(AVG(joined_data.pct_increase)*100,2) AS average_pct_increase
FROM
  joined_data
WHERE
  is_long_acting = TRUE
UNION ALL
SELECT
  'Antibiotic',
  ROUND(AVG(increase),2) AS avg_cost_increase,
  ROUND(AVG(joined_data.pct_increase)*100,2) AS average_pct_increase
FROM
  joined_data
WHERE
  is_antibiotic = TRUE
UNION ALL
SELECT
  'Antipsychotic',
  ROUND(AVG(increase),2) AS avg_cost_increase,
  ROUND(AVG(joined_data.pct_increase)*100,2) AS average_pct_increase
FROM
  joined_data
WHERE
  is_antipsychotic = TRUE;
