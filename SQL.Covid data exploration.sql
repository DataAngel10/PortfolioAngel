
                                 -- Data explration covid data around de World--
                                 
                                          -- -- *** Covid Deaths *** -- --


select *
from coviddeaths1
where continent is not null
order by 3,4;

/* Select * 
from coviddeaths1 
 by 3,4; */ 



-- Select data that we are going to be using -- 

Select
location,
 date,
 total_cases,
 New_cases,
 total_deaths,
 population 
from coviddeaths1
order by 1,2;



-- Looking at Total Cases vs Total Deaths --
-- Shows likelihood of dying if you contract covid in Netherlands / Chile --

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS DECIMAL) / NULLIF(CAST(total_cases AS DECIMAL), 0)) * 100 AS Deathpercentage
FROM coviddeaths1
WHERE location IN ('Netherlands', 'Chile')  -- Filters for only Netherlands and Chile --
and continent is not null
ORDER BY 1,2;



-- Looking at Total Cases vs Population -- 
-- Shows what percentage of populations from Netherlands and Chile got covid--

SELECT 
    location, 
    date,  
     population,
     total_cases, 
    (CAST(total_cases AS DECIMAL) / NULLIF(CAST(population AS DECIMAL), 0)) * 100 AS PercentPopulationInfected
FROM coviddeaths1
ORDER BY location, date;



-- Looking at countries with highest infection rate compared to population --

SELECT 
    location,  
     population,
    MAX(CAST(total_cases AS DECIMAL))  as HighestInfectionCount, 
    MAX(CAST(total_cases AS DECIMAL))/NULLIF(CAST(population AS DECIMAL), 0) *100 as PercentPopulationInfected
FROM coviddeaths1 
Group by Location, Population
ORDER BY PercentPopulationInfected desc ;



-- Showing countries with Highest Death Count per Population -- 

SELECT location, MAX(CAST(Total_deaths AS decimal)) AS TotalDeathCount
FROM coviddeaths1 
where continent is not null
Group by location
order by TotalDeathCount DESC;



-- LET'S BREAK THINGS DOWN BY CONTINENT -- 
-- Showing the continent with the highest death count per population--

SELECT continent, MAX(CAST(Total_deaths AS DECIMAL)) AS TotalDeathCount
FROM coviddeaths1 
Where continent is not null
Group by continent
order by TotalDeathCount desc;


-- Global numbers __

SELECT 
    date, 
    SUM(cast(new_cases as decimal)) AS Total_cases, 
    SUM(cast(new_deaths as decimal)) AS Total_deaths, 
 (SUM(CAST(new_deaths AS DECIMAL)) / NULLIF(SUM(CAST(New_cases AS DECIMAL)), 0)) * 100 AS DeathPercentage
FROM coviddeaths1
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;




-- Total cases--
SELECT 
    SUM(cast(new_cases as decimal)) AS Total_cases, 
    SUM(cast(new_deaths as decimal)) AS Total_deaths, 
 (SUM(CAST(new_deaths AS DECIMAL)) / NULLIF(SUM(CAST(New_cases AS DECIMAL)), 0)) * 100 AS DeathPercentage
FROM coviddeaths1
WHERE continent IS NOT NULL
ORDER BY  1,2;



      
      --  --*** Covid Vaccinations ***-- --
-- Use CTE -- 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(cast(vac.new_vaccinations as decimal))
    OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths1 dea
JOIN covidvaccinations1 vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3; 
)

SELECT *, 
       (CAST(RollingPeopleVaccinated AS DECIMAL) / NULLIF(CAST(population AS DECIMAL), 0)) * 100 AS VaccinationPercentage
FROM PopvsVac;






                                    -- TEMP TABLE -- 
-- Assuming the temporary table PercentPopulationVaccinated is created:
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME, 
    Population DECIMAL(18,2),
    New_vaccinations DECIMAL(18,2),
    RollingPeopleVaccinated DECIMAL(18,2)
);

-- Insert data into the temporary table
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS DECIMAL(18,2))) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM coviddeaths1 dea
JOIN covidvaccinations1 vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--  order by 2,3

SELECT *, 
       (CAST(RollingPeopleVaccinated AS DECIMAL(18,2)) / NULLIF(CAST(population AS DECIMAL(18,2)), 0)) * 100 AS VaccinationPercentage
FROM PercentPopulationVaccinated;





-- Creating viewto store data for later visualization


CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS DECIMAL(18,2))) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM coviddeaths1 dea
JOIN covidvaccinations1 vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

Select * 
from PercentPopulationVaccinated




