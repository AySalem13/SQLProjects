select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4



select *
from PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using

--Select Location, date, total_cases, new_cases,total_deaths,population
--from PortfolioProject..CovidDeaths
--order by location,date

-- Looking at Total Cases vs Total Deaths


Select Location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location = 'Egypt'
order by 1,2

-- Looking at Total Cases vs Population 
-- Shows percentage of population that got covid
Select Location, date, total_cases,population, (total_cases/population) * 100 as InfectionPercentage
from PortfolioProject..CovidDeaths
Where location = 'Egypt'
order by 1,2


-- Looking at Countries with highest infection rate compared to population

Select Location,population, Max(total_cases) as HighestInfectionCount
,Max((total_cases/population) * 100) as InfectionPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by InfectionPercentage desc

-- Showing countries with highest death count per population

select location,max(total_deaths) as Total_deaths
,max(total_deaths/population * 100) as DeathPercentage
from PortfolioProject..CovidDeaths
--where total_deaths <> 0
where continent is not null
group by location 
order by DeathPercentage desc

-- Let's break this down by continents 
--Showing the continents with the highest death count

select continent,max(total_deaths) as Total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent 
order by Total_deaths desc

-- Global Numbers

Select date, sum(new_cases)as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths
, sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total world death percentage
Select sum(new_cases)as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths
, sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Population vs Vaccinations for each continent
select deaths.continent, max(population) as Population, max(total_vaccinations) TotalVaccinations
,  max(total_vaccinations)/max(population) * 100 as PercentVacccinated
from PortfolioProject..CovidDeaths as Deaths
join PortfolioProject..CovidVaccinations as Vac
	on Deaths.location = vac.location 
	and Deaths.date = vac.date
where deaths.continent is not null
group by deaths.continent;

-- Looking at Total Population vs Vaccinations daily using CTE

with CleanData (continent,location,date,population,new_vaccinations)
as 
(
select DISTINCT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    from PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccinations vac
         on dea.location = vac.location AND dea.date = vac.date
    where dea.continent IS NOT NULL
)
SELECT *, SUM(new_vaccinations) OVER (partition by location order by date) AS RollingVaccinations

FROM CleanData
ORDER BY location, date

--- Looking for Percantage of vaccinations daily


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaccinated/Population)*100 as PercentVaccinationDaily
From PopvsVac

-- TEMP table 

DROP Table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2

Select *, (RollingVaccinated/Population)*100 as PercentVaccinationDaily
From #PercentPopVaccinated


-- Creating view to store data for later visualizations

create View PercentPopVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2

select *
from PercentPopVaccinated

-- Second view 

create View Continent_Deaths as

select continent,max(total_deaths) as Total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent 

select *
from Continent_Deaths
