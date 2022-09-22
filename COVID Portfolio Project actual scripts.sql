select * 
from PortfolioProject..covdeaths
order by 3,4

--go 

--select * 
--from PortfolioProject..covvaccinations
--order by 3,4

--Select data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covdeaths
order by 1,2

--Looking at total_cases vs total_deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covdeaths
where location like '%states%'
order by 1,2

--Looking at total_cases vs population; shows percentage of population that has gotten covid

select location, date, total_cases, population, (total_cases/population)*100 as percent_of_population_infected
from PortfolioProject..covdeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as
percent_of_population_infected
from PortfolioProject..covdeaths
--where location like '%states%'
group by location, population
order by percent_of_population_infected desc

--Showing countries with highest death count per population

select location, max(cast(total_deaths as bigint)) as total_death_count
from PortfolioProject..covdeaths
--where location like '%states%'
where continent is not null
group by location
order by total_death_count desc


--LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as bigint)) as total_death_count
from PortfolioProject..covdeaths
--where location like '%states%'
where continent is not null
group by continent
order by total_death_count desc


--GLOBAL NUMBERS

--Stats per day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, (sum(cast(new_deaths as bigint))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..covdeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--Stats total

select sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, (sum(cast(new_deaths as bigint))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..covdeaths
where continent is not null




--Looking at Total Population vs Vaccinations
  --gives us a rolling count of people vaccinated in each country by date
  --
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
--(rolling_vaccinated/population)*100 to get the amount of population vaccinated, but doesnt work because we just created 
--rolling_vaccinated, so we need to create a CTE or temp table.
from PortfolioProject..covDeaths as DEA
join PortfolioProject..covVaccinations as VAC
on DEA.location = VAC.location
and DEA.date = VAC.date
where dea.continent is not null
order by 2,3

--Option 1: CTE

with PopVsVac (continent, location, date, population, new_vaccinations, rolling_vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
--(rolling_vaccinated/population)*100 to get the amount of population vaccinated, but doesnt work because we just created 
--rolling_vaccinated, so we need to create a CTE or temp table.
from PortfolioProject..covDeaths as DEA
join PortfolioProject..covVaccinations as VAC
on DEA.location = VAC.location
and DEA.date = VAC.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_vaccinated/population)*100 as vacPopPercentage
from PopVsVac
order by 2,3

--Option 2: temp table

drop table if exists #percentpopluationvaccinated
create table #percentpopluationvaccinated
(
continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccinated numeric
)

insert into #percentpopluationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
--(rolling_vaccinated/population)*100 to get the amount of population vaccinated, but doesnt work because we just created 
--rolling_vaccinated, so we need to create a CTE or temp table.
from PortfolioProject..covDeaths as DEA
join PortfolioProject..covVaccinations as VAC
on DEA.location = VAC.location
and DEA.date = VAC.date
where dea.continent is not null
--order by 2,3

select *, (rolling_vaccinated/population)*100 as vacPopPercentage
from #percentpopluationvaccinated
order by 2,3



--Creating View to store data for later visualization

create view percent_popluation_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
--(rolling_vaccinated/population)*100 to get the amount of population vaccinated, but doesnt work because we just created 
--rolling_vaccinated, so we need to create a CTE or temp table.
from PortfolioProject..covDeaths as DEA
join PortfolioProject..covVaccinations as VAC
on DEA.location = VAC.location
and DEA.date = VAC.date
where dea.continent is not null
--order by 2,3


--Create more views to visualize later