                    
                    -- *** Tableau Tables Covid Data *** ---
                        
-- Tableau Table 1: Total Cases -- 

-- 1. 
SELECT 
    SUM(cast(new_cases as decimal)) AS Total_cases, 
    SUM(cast(new_deaths as decimal)) AS Total_deaths, 
 (SUM(CAST(new_deaths AS DECIMAL)) / NULLIF(SUM(CAST(New_cases AS DECIMAL)), 0)) * 100 AS DeathPercentage
FROM coviddeaths1
WHERE continent IS NOT NULL
ORDER BY  1,2;


-- Tableau table 2. Total Death Count by continent 

SELECT continent, 
       SUM(CAST(new_deaths AS DECIMAL)) AS TotalDeathCount
FROM coviddeaths1
WHERE continent IS NOT NULL  -- Include only valid continents
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- Tableau Table 3. Percent Population Infected (replace null to 0 in googlesheets)

SELECT 
    location,  
     population,
    MAX(CAST(total_cases AS DECIMAL))  as HighestInfectionCount, 
    MAX(CAST(total_cases AS DECIMAL))/NULLIF(CAST(population AS DECIMAL), 0) *100 as PercentPopulationInfected
FROM coviddeaths1 
Group by Location, Population,date
ORDER BY PercentPopulationInfected desc;


-- Tableau Table 4. Percent Population Infected (replace null to 0 in googlesheets)

SELECT 
    location,  
     population,
     date,
    MAX(CAST(total_cases AS DECIMAL))  as HighestInfectionCount, 
    MAX(CAST(total_cases AS DECIMAL))/NULLIF(CAST(population AS DECIMAL), 0) *100 as PercentPopulationInfected
FROM coviddeaths1 
Group by Location, Population, date
ORDER BY PercentPopulationInfected desc;

