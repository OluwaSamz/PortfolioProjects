select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select the data we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

select location, max(convert(bigint,total_deaths)), sum(convert(bigint,new_deaths))
from PortfolioProject..CovidDeaths
where location = 'Afghanistan'
GROUP BY location

--total cases versus total deaths
--PercentageDeath shows the likelihood of dying if you have covid
select Location, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
from PortfolioProject..CovidDeaths
--where Location like '%states%'
order by 1,2

--total cases vs population
--shows the InfectedPopulation percentage
select Location, date, total_cases, population, new_cases, (total_cases/population)*100 as InfectedPopulation
from PortfolioProject..CovidDeaths
--where Location like '%kingdom%'
order by 1,2

--countries with highest infection rate compared to population

select Location, max(total_cases) as MaxTotalCases, population, max((total_cases/population))*100 as MaxInfectedPopulation
from PortfolioProject..CovidDeaths
--where population > '100000000'
group by Location, population
order by MaxInfectedPopulation desc

--countries with the highest death count

select Location, max(total_cases) as MaxTotalCases, max(cast(total_deaths as int)) as HighestDeathCount, population, max((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where population > '100000000'
where continent is not null
group by Location, population
order by HighestDeathCount desc


--showing continents with highest death
select continent, max(CAST(total_deaths as int)) as MaxDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by MaxDeath desc

-- looking at African countries Death rate
select continent,Location, max(CAST(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent = 'Africa'
group by continent, location
order by TotalDeath desc

-- Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(total_deaths as int))/sum(total_cases))* 100 as  DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null

------
select dea.location, sum(dea.new_cases) as total_cases, sum(cast(dea.new_deaths as int)) as total_deaths,(sum(cast(dea.total_deaths as int))/sum(dea.total_cases))* 100 as  DeathPercentage
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.location
order by 1


-- Looking at total vaccination vs total population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE

with PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select*, (RollingPeopleVaccinated/Population)*100 as PercentagePoepleVacccinated
from PopvsVac


-- TEMP TABLE
Drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*, (RollingPeopleVaccinated/Population)*100 as PercentagePoepleVacccinated
from #PercentPeopleVaccinated


-- creating views to store data visualizations
Create View PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPeopleVaccinated