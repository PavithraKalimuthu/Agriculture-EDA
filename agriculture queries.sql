1.Year-wise Trend of Rice Production Across States (Top 3)
WITH ranked_production AS (
    SELECT 
        "Year",
        "State Name",
        SUM("RICE PRODUCTION (tons)") AS total_rice_production,
        RANK() OVER (PARTITION BY "Year" ORDER BY SUM("RICE PRODUCTION (tons)") DESC) AS rank
    FROM agri_cleaned
    GROUP BY "Year", "State Name"
)
SELECT *
FROM ranked_production
WHERE rank <= 3
ORDER BY "Year", total_rice_production DESC;
2.Top 5 Districts by Wheat Yield Increase Over the Last 5 Years
SELECT 
    "Dist Name",
    MAX("Year") AS latest_year,
    MAX("WHEAT YIELD (tons per ha)") AS latest_yield,
    MIN("Year") AS earliest_year,
    MIN("WHEAT YIELD (tons per ha)") AS earliest_yield,
    (MAX("WHEAT YIELD (tons per ha)") - MIN("WHEAT YIELD (tons per ha)")) AS yield_increase
FROM agri_cleaned
WHERE "Year" >= (SELECT MAX("Year") - 4 FROM agri_cleaned)
GROUP BY "Dist Name"
ORDER BY yield_increase DESC
LIMIT 5;
3.States with the Highest Growth in Oilseed Production (5-Year Growth Rate)
SELECT 
    "State Name",
    MIN("Year") AS start_year,
    MAX("Year") AS end_year,
    
    SUM(CASE 
            WHEN "Year" = (SELECT MIN("Year") FROM agri_cleaned WHERE "Year" >= (SELECT MAX("Year") - 4 FROM agri_cleaned)) 
            THEN "OILSEEDS PRODUCTION (tons)" 
            ELSE 0 
        END) AS production_start,

    SUM(CASE 
            WHEN "Year" = (SELECT MAX("Year") FROM agri_cleaned) 
            THEN "OILSEEDS PRODUCTION (tons)" 
            ELSE 0 
        END) AS production_end,

    ROUND(
        (SUM(CASE WHEN "Year" = (SELECT MAX("Year") FROM agri_cleaned) 
                  THEN "OILSEEDS PRODUCTION (tons)" ELSE 0 END) -
         SUM(CASE WHEN "Year" = (SELECT MIN("Year") FROM agri_cleaned WHERE "Year" >= (SELECT MAX("Year") - 4 FROM agri_cleaned)) 
                  THEN "OILSEEDS PRODUCTION (tons)" ELSE 0 END)
        )::numeric 
        / NULLIF(SUM(CASE WHEN "Year" = (SELECT MIN("Year") FROM agri_cleaned WHERE "Year" >= (SELECT MAX("Year") - 4 FROM agri_cleaned)) 
                          THEN "OILSEEDS PRODUCTION (tons)" ELSE 0 END)::numeric, 0) 
        * 100, 
        2
    ) AS growth_percentage

FROM agri_cleaned
WHERE "Year" >= (SELECT MAX("Year") - 4 FROM agri_cleaned)
GROUP BY "State Name"
ORDER BY growth_percentage DESC
LIMIT 5;
4.District-wise Correlation Between Area and Production for Major Crops (Rice, Wheat, and Maize)
SELECT 
    "Dist Name",
    "State Name",
    "Year",
    "RICE AREA (ha)",
    "RICE PRODUCTION (tons)",
    "WHEAT AREA (ha)",
    "WHEAT PRODUCTION (tons)",
    "MAIZE AREA (ha)",
    "MAIZE PRODUCTION (tons)"
FROM agri_cleaned
WHERE 
    "RICE AREA (ha)" IS NOT NULL AND "RICE PRODUCTION (tons)" IS NOT NULL AND
    "WHEAT AREA (ha)" IS NOT NULL AND "WHEAT PRODUCTION (tons)" IS NOT NULL AND
    "MAIZE AREA (ha)" IS NOT NULL AND "MAIZE PRODUCTION (tons)" IS NOT NULL
ORDER BY "Dist Name", "Year";
5.Yearly Production Growth of Cotton in Top 5 Cotton Producing States
--Top 5 states
SELECT "State Name", 
       SUM("COTTON PRODUCTION (tons)") AS total_production
FROM agri_cleaned
WHERE "COTTON PRODUCTION (tons)" IS NOT NULL
GROUP BY "State Name"
ORDER BY total_production DESC
LIMIT 5;
--yearly trends
SELECT 
    "Year",
    "State Name",
    SUM("COTTON PRODUCTION (tons)") AS total_cotton_production
FROM agri_cleaned
WHERE "State Name" IN ('Maharashtra', 'Gujarat', 'Telangana', 'Andhra Pradesh', 'Punjab')
  AND "COTTON PRODUCTION (tons)" IS NOT NULL
GROUP BY "Year", "State Name"
ORDER BY "Year", "State Name";

6.Districts with the Highest Groundnut Production in 2020
SELECT 
    "Dist Name",
    "State Name",
    "GROUNDNUT PRODUCTION (tons)"
FROM agri_cleaned
WHERE "Year" = 2020
  AND "GROUNDNUT PRODUCTION (tons)" IS NOT NULL
ORDER BY "GROUNDNUT PRODUCTION (tons)" DESC
LIMIT 10;
---> there is no groundnut production in the year 2020
7.Annual Average Maize Yield Across All States
SELECT 
    "Year",
    ROUND(AVG("MAIZE YIELD (tons per ha)")::numeric, 2) AS avg_maize_yield
FROM agri_cleaned
WHERE "MAIZE YIELD (tons per ha)" IS NOT NULL
GROUP BY "Year"
ORDER BY "Year";
8.Total Area Cultivated for Oilseeds in Each State
SELECT 
    "State Name",
    SUM("OILSEEDS AREA (ha)") AS total_oilseeds_area
FROM agri_cleaned
WHERE "OILSEEDS AREA (ha)" IS NOT NULL
GROUP BY "State Name"
ORDER BY total_oilseeds_area DESC;
9.Districts with the Highest Rice Yield
SELECT 
    "Dist Name",
    "State Name",
    MAX("RICE YIELD (tons per ha)") AS rice_yield
FROM agri_cleaned
WHERE "RICE YIELD (tons per ha)" IS NOT NULL
GROUP BY "Dist Name", "State Name"
ORDER BY rice_yield DESC
LIMIT 10;
10.Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years
-- Step 1: Identify top 5 rice producing states (based on total rice production)
WITH top_rice_states AS (
    SELECT "State Name"
    FROM agri_cleaned
    GROUP BY "State Name"
    ORDER BY SUM("RICE PRODUCTION (tons)") DESC
    LIMIT 5
)

-- Step 2: Compare yearly rice and wheat production for those states
SELECT 
    a."Year",
    a."State Name",
    SUM(a."RICE PRODUCTION (tons)") AS rice_production,
    SUM(a."WHEAT PRODUCTION (tons)") AS wheat_production
FROM agri_cleaned a
JOIN top_rice_states t ON a."State Name" = t."State Name"
WHERE a."RICE PRODUCTION (tons)" IS NOT NULL 
  AND a."WHEAT PRODUCTION (tons)" IS NOT NULL
GROUP BY a."Year", a."State Name"
ORDER BY a."Year", rice_production DESC;




