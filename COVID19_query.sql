CREATE DATABASE COVID19_CASES
USE COVID19_CASES

SELECT*
FROM Covid_Death
ORDER BY 3,4

SELECT* 
FROM Covid_Vaccination
ORDER BY 3,4

SELECT*
FROM COVID19_CASES..CovidVaccination
ORDER BY 3,4

-- change the data type
alter table Covid_Death alter column total_deaths int null
alter table Covid_Death alter column total_cases_per_million float null
alter table Covid_Death alter column total_deaths_per_million float null
alter table Covid_Death alter column reproduction_rate float null
alter table Covid_Death alter column icu_patients float null
alter table Covid_Death alter column hosp_patients_per_million float null 
alter table Covid_Death alter column icu_patients_per_million float null 
alter table Covid_Death alter column hosp_patients float null 
alter table Covid_Death alter column weekly_icu_admissions float null
alter table Covid_Death alter column weekly_icu_admissions_per_million float null 
alter table Covid_Death alter column weekly_hosp_admissions float null
alter table Covid_Death alter column weekly_hosp_admissions_per_million float null

--Select data what we want
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Death
ORDER BY 1,2

-- Comparation between new_cases and new_deaths (NULLIF to solve zero error sql)

SELECT date, location,new_cases, new_deaths,(NULLIF(new_deaths,0)/NULLIF(new_cases,0)) * 100 as DeathPercentage 
FROM Covid_Death
ORDER BY 1,2

--percentage of covid deaths rate in United States every day

SELECT date, location,total_cases, total_deaths,population, (NULLIF(total_cases,0)/NULLIF(total_deaths,0)) * 100 as DeathPercentage
FROM Covid_Death
WHERE location LIKE '%states%'
Order by location,date

-- to know percentage of people who contract covid in the United States 
SELECT location, date ,total_cases,population, (NULLIF(total_cases,0)/NULLIF(population,0)) * 100 as Infection_rate
FROM Covid_Death
WHERE location LIKE '%states'
ORDER BY location, date

--country has the highest infection rate
SELECT location, population,
	MAX(total_cases) AS Highest_infection_count,
	MAX(total_cases/population)*100 as highest_infection_rate
FROM Covid_Death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

-- highest total_deaths per each country

SELECT location,
	MAX(total_deaths) AS Highest_deaths_count
FROM Covid_Death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--highest deaths by each continent

SELECT continent,
	MAX(total_deaths) AS Highest_deaths_count
FROM Covid_Death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- calculate the worldwide covid death rate for each day

SELECT date, SUM(NULLIF(new_cases,0)) as total_newcase, SUM(NULLIF(new_deaths,0)) as total_newdeaths, (SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0)))*100 AS death_rate
FROM Covid_Death 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 4 DESC

--join covid_deaths table and covid_vaccination table

SELECT*
FROM Covid_Death dea
Join Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date


-- comparation between population and vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Covid_Death dea
Join Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- join two tables and calculate the rolling count of new vaccinations

 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination
--, (RollingPeopleVaccinated/population)*100
FROM Covid_Death dea
JOIN Covid_Vaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination
--, (RollingPeopleVaccinated/population)*100
FROM Covid_Death dea
JOIN Covid_Vaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)

Select*, (RollingPeopleVaccinated/population)*100 AS RollingVaccination_rate
From PopvsVac


-- Temp Table

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinatied
--, (RollingPeopleVaccinated/population)*100
FROM Covid_Death dea
JOIN Covid_Vaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated
 

 -- Creating view to store data for later visualizations

Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinatied
--, (RollingPeopleVaccinated/population)*100
FROM Covid_Death dea
JOIN Covid_Vaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

Select * from PercentagePopulationVaccinated