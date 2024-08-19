-- All relevant Columns from CovidDeaths
Select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Projekt_Covid..CovidDeaths
order by 1,2

-- Lethalityrate when contracted with corona in Germany
Select Location, date, total_cases, total_deaths, total_deaths/total_cases * 100 AS Lethality
from Portfolio_Projekt_Covid..CovidDeaths
where location like 'germany'
order by 1,2


-- Infectionrate in Germany
Select Location, date, total_cases, population, total_cases/population * 100 AS Infectionrate
from Portfolio_Projekt_Covid..CovidDeaths
where location like 'germany'
order by 1,2

-- Total Infectionrate per Country
Select Location, Max(total_cases) as MaxTotalCases, population, Max((total_cases/population) * 100) AS MaxInfectionrate
from Portfolio_Projekt_Covid..CovidDeaths
group by Location, population
Order by 4 desc

-- Total Deathrate per Country
Select Location, population, Max(total_deaths) as MaxDeathCases, Max((total_deaths/population) * 100) AS MaxLethalityrate
from Portfolio_Projekt_Covid..CovidDeaths
where continent is NULL
group by Location, population
Order by 3 desc


-- Global Numbers
-- Total Deathpercentage for the world
Select Sum(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths,
	(Sum(new_deaths)/sum(new_cases)*100) as Deathpercentage
from Portfolio_Projekt_Covid..CovidDeaths
where continent is not null
order by 1,2

-- Joined Table CovidDeaths and CovidVaccinations 
-- Table shows new Vaccinations and the sum of the total Vaccinations for that date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Projekt_Covid..CovidDeaths dea
Join Portfolio_Projekt_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Creating a CTE for Convinience

With PopVSVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, cast(dea.population as int), vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) 
	over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Projekt_Covid..CovidDeaths dea
Join Portfolio_Projekt_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
-- Selection shows the Vaccinated Percentage of a Country per Date
Select *, (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100 as VaccinatedPercent
From PopVSVac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, cast(dea.population as int), vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) 
	over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Projekt_Covid..CovidDeaths dea
Join Portfolio_Projekt_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


-- Total Percent Vaccination per Country
Select Location, Population, Max(RollingPeopleVaccinated) as MaxVaccination, 
	MAX((cast(RollingPeopleVaccinated as float)/cast(Population as float))*100) as VaccinatedPercent
From #PercentPopulationVaccinated
group by Location, Population
order by 4 desc


-- Creating a View
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, cast(dea.population as int) as Population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) 
	over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Projekt_Covid..CovidDeaths dea
Join Portfolio_Projekt_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

-- View for the Infectionrate per Country (without Continents)

Create View InfectionrateCountry as
Select Location, Max(total_cases) as MaxTotalCases, population, Max((total_cases/population) * 100) AS MaxInfectionrate
from Portfolio_Projekt_Covid..CovidDeaths
Where continent is not null
group by Location, population

Select *
From InfectionrateCountry
Order by 4 desc