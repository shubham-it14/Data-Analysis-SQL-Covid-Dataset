-- Testing the data in the source tables
select top 10 * from covidData.[dbo].[covidDeaths] 
order by 3,4;
select top 10 * from covidData.[dbo].[covidVaccinations] 
order by 3,4;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in India
select [location],[date],total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from covidData.[dbo].[covidDeaths] 
where [location] like '%India%'
order by 1,2;

-- Looking at the Total Cases vs Population
-- Shows what percentage of Population got Covid
select [location],[date],population,total_cases, (total_cases/population)*100 as Case_Percentage
from covidData.[dbo].[covidDeaths] 
where [location] like '%India%'
order by 1,2;

-- Looking at countries with highest Infection Rate compared to population
select [location],population,max(total_cases) as Highest_Cases_Recorded, max((total_cases/population))*100 as Case_Percentage
from covidData.[dbo].[covidDeaths] 
Group by [location], population
order by Case_Percentage desc;

-- Countries with Highest Death Count percentage 
select [location],population,max(total_deaths) as Highest_Deaths_Recorded, max((total_deaths/population))*100 as Death_Percentage
from covidData.[dbo].[covidDeaths] 
where continent is not NULL
Group by [location], population
order by Death_Percentage desc;

-- Continents with Highest Death Count percentage 
select [continent],max(total_deaths) as Highest_Deaths_Recorded, max((total_deaths/population))*100 as Death_Percentage
from covidData.[dbo].[covidDeaths] 
where continent is Not NULL
Group by [continent]
order by Death_Percentage desc;

--Global Numbers
select [date], SUM(new_cases) as new_cases, SUM(new_deaths) as new_deaths, 
coalesce(SUM(new_deaths)/NullIF (SUM(new_cases),0),0)*100 as Death_Percenatge
from covidData.[dbo].[covidDeaths] 
where continent is Not NULL
Group By DATE
Order by Death_Percenatge desc;

-- Total Population Vs Vaccinations
--Joining the data
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location order by dea.location, dea.DATE) as Rolling_Vaccincations
from covidData.dbo.covidDeaths as dea 
JOIN covidData.dbo.covidVaccinations as vac 
on dea.location=vac.location 
and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Use CTE
WITH CTEUSE (continent,location,date,population,Vaccinations,Rolling_Vaccincations)
As
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location order by dea.location, dea.DATE) as Rolling_Vaccinations
from covidData.dbo.covidDeaths as dea 
JOIN covidData.dbo.covidVaccinations as vac 
on dea.location=vac.location 
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (Rolling_Vaccincations/Population)*100 
from CTEUSE

-- Creating Views for Data Visualization
Create VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location order by dea.location, dea.DATE) as Rolling_Vaccincations
from covidData.dbo.covidDeaths as dea 
JOIN covidData.dbo.covidVaccinations as vac 
on dea.location=vac.location 
and dea.date = vac.date
where dea.continent is not null

