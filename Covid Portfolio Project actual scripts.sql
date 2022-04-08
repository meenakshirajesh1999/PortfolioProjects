select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2



--Looking total cases vs Population
--Shows what percentage of population got covid
select Location,date,total_cases,population,(total_cases/population)*100 as PercentPopuletionInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
order by 1,2

--Looking at countries with Highest Infection rate compared to Population
select Location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc


--showing countries with highest death count per population
select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT


--Showing continents with highest death count
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


--Looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac(Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac




-- TEMP TABLE
drop table if exists #PercentPopultaionVaccinate
create table #PercentPopulationVaccinate
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date datetime,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinate
select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date 
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinate


--Creating View to store data for later visualisations

create view PercentPopulationVaccinated as

select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated