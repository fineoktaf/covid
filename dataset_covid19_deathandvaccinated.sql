/* 1.SELECT continent location, population, date, total_cases, total_deaths, 
	new_cases,new_deaths, total vaccine, people_fully_vaccinated,
	 from covid_death
2. Death percentage for all continent (new death / new cases) from covid table
3. daliy infection rate per location (find highest) (total cases/population)
4. infection rate per continent (find highest)
5. 

*/

-- dateset covid_death and covid_vaccination
SELECT
	dea.continent,
	dea.location, 
	dea.population,
	dea.date, 
	dea.total_cases, 
	dea.total_deaths,
	dea.new_cases, 
	dea.new_deaths, 
	dea.total_cases,
	vac.total_vaccinations, 
	vac.people_fully_vaccinated,
	(NULLIF(dea.new_deaths,0)/NULLIF(dea.new_cases,0)) * 100 as DeathPercentage,
	(NULLIF(dea.total_cases,0)/NULLIF(dea.population,0)) * 100 as Infection_rate
FROM Covid_Death dea
Join Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Group by
	dea.continent,
	dea.location, 
	dea.population,
	dea.date, 
	dea.total_cases, 
	dea.total_deaths,
	dea.new_cases, 
	dea.new_deaths, 
	dea.total_cases,
	vac.total_vaccinations, 
	vac.people_fully_vaccinated

