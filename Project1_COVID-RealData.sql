select * 
from PortfolioProject..CovidDeaths
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at the total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, round((cast(total_deaths as int)*100.00/total_cases),2)  as DeathPercent
--select *
from PortfolioProject..CovidDeaths
order by 1,2


-- looking at total cases vs population

select location, date, population, total_cases, round((cast(total_cases as int)*100.00/population),6) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2

-- looking at the highest infection rates

select location, population, max(total_cases) as HighestInfectionCount, round(cast(max(total_cases)as float)*100/population,5) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- LETS break things down by continents

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



-- showing the continents with the highest death counts per population

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select date, (sum(new_cases)) as NewCases , SUM((new_deaths)) as NewDeaths , case when sum(new_cases) <> 0 then cast(SUM(new_deaths)*100/SUM(new_cases) as float) else null end as DeathPercentage --as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- 1. 

select (sum(new_cases)) as NewCases , SUM((new_deaths)) as NewDeaths , case when sum(new_cases) <> 0 then cast(SUM(new_deaths)*100/SUM(new_cases) as float) else null end as DeathPercentage --as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- 2.

select location ,sum(cast(new_deaths as bigint)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is null
and location not in ('World','European Union','International','High Income','Upper Middle Income','Lower middle income','Low income')
group by location
order by TotalDeathCount desc


-- 3.

select location, population, max(total_cases) as HighestInfectionCount, round(cast(max(total_cases)as float)*100/population,5) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- 4.

select location, population, date,  max(total_cases) as HighestInfectionCount, round(cast(max(total_cases)as float)*100/population,5) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population, date
order by PercentPopulationInfected desc



--- Exploring COVID VACCINATIONS Table

select *
from PortfolioProject..CovidVaccinations;

-- joining the 2 tables
select *
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date;

select d.continent, d.location, d.date, d.population, v.new_vaccinations
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	order by 2,3;

-- China 's ultimate symmetry
select d.continent, d.location, d.date, d.population, v.new_vaccinations
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	where d.location like 'China'
	--where d.continent is not null
	order by 2,3; 

-- loooking at total population vs vaccinations

with popVSvac (continent, Location,Date , Population, New_Vaccinations, PeopleVaccinatedRolling)
as 
(
select d.continent, d.location, d.date, d.population, 
	v.new_vaccinations, 
	SUM(cast(v.new_vaccinations as float))	
		over (partition by d.location order by d.location, 
		d.date ) as PeopleVaccinatedRolling 
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	where d.continent is not null
)

select * from popVSvac;

with popVSvac (continent, Location,Date , Population, New_Vaccinations, PeopleVaccinatedRolling)
as 
(
select d.continent, d.location, d.date, d.population, 
	v.new_vaccinations, 
	SUM(cast(v.new_vaccinations as float))	
		over (partition by d.location order by d.location, 
		d.date ) as PeopleVaccinatedRolling 
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	where d.continent is not null
)

select *, (PeopleVaccinatedRolling/Population)*100
from popVSvac;

-- temp table

drop table if exists #PopulationVaccinated

create table #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinatedRolling numeric
)
Insert into #PopulationVaccinated
select d.continent, d.location, d.date, d.population, 
	v.new_vaccinations, 
	SUM(cast(v.new_vaccinations as float))	
		over (partition by d.location order by d.location, 
		d.date ) as PeopleVaccinatedRolling 
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	where d.continent is not null

select *, (PeopleVaccinatedRolling/population) * 100
from #PopulationVaccinated

create view PopulationVaccinated as 
select d.continent, d.location, d.date, d.population, 
	v.new_vaccinations, 
	SUM(cast(v.new_vaccinations as float))	
		over (partition by d.location order by d.location, 
		d.date ) as PeopleVaccinatedRolling 
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	--order by 2,3


select * from PopulationVaccinated