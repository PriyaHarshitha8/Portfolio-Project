--selecting data for exploration
select continent,date,total_cases,new_cases,total_deaths,population 
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths 
--Chances of dying with covid in India

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio Project]..CovidDeaths
where location='India'
order by 1,2

--looking at total cases vs population
--Shows what percentage of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as PopulationPercentInfected
from [Portfolio Project]..CovidDeaths
where location='India'
order by 1,2

--countries with highest infection rates

select location,population,MAX(total_cases) as max_cases,MAX((total_cases/population)*100) as PopulationPercentInfected
from [Portfolio Project]..CovidDeaths
where continent is not null
GROUP BY location, population
order by 4 desc

--continents with highest death count
--DataType for new_deaths found varchar, convert to float

select continent,sum(cast(new_deaths AS int)) as deaths from [Portfolio Project]..CovidDeaths
WHERE continent is not null
group by continent
order by 2 desc

--Number of cases,deaths each day globally(look at the dataset if stuck)

	select date,SUM(cast(new_cases as int)) as global_cases,sum(cast(new_deaths as int)) global_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage from [Portfolio Project]..CovidDeaths
	WHERE continent is not null
	group by date
	order by 1

--	Aggregate global numbers
select SUM(cast(new_cases as int)) as global_cases,sum(cast(new_deaths as int)) global_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage from [Portfolio Project]..CovidDeaths
	WHERE continent is not null
--	group by date
	order by 1


--Exploring Vaccinations table
 select continent,location,date,total_vaccinations, new_vaccinations from [Portfolio Project]..CovidVaccination
 where continent is not null
 order by location

 --Joining CovidDeaths and covidVaccinations tables

 select * from [Portfolio Project]..CovidDeaths d
 join [Portfolio Project]..CovidVaccination v
 on d.location=v.location and d.date=v.date
 where d.continent is not null
 order by 2,3,4

 --- Total population vs Vaccinations

  select d.continent,d.location,d.date,d.population,v.new_vaccinations from [Portfolio Project]..CovidDeaths d
 join [Portfolio Project]..CovidVaccination v
 on d.location=v.location and d.date=v.date
 where d.continent is not null
 order by 2,3,4

 --location wise vaccinations

 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.date) as RollingPopVaccinated
  from [Portfolio Project]..CovidDeaths d
 join [Portfolio Project]..CovidVaccination v
 on d.location=v.location and d.date=v.date
 where d.continent is not null
 order by 2,3

 --Use CTE


  WITH CTE_Employee as

 (select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.date) as RollingPopVaccinated
  from [Portfolio Project]..CovidDeaths d
 join [Portfolio Project]..CovidVaccination v
 on d.location=v.location and d.date=v.date
 where d.continent is not null)
 --order by 2,3
 select *,(RollingPopVaccinated/population)*100 from CTE_Employee
 
 -- The above query is showing error values(percentage>100) as new_vaccinations full both first and second doses

 --Percentage Population Vaccinated

 with cte_percentpopvac as

 (select d.continent,d.location,d.date,d.population,v.people_vaccinated,
 max(CAST(v.people_vaccinated as int)) over (partition by d.location order by d.date) as RollingPopVaccinated
  from [Portfolio Project]..CovidDeaths d
 join [Portfolio Project]..CovidVaccination v
 on d.location=v.location and d.date=v.date
 where d.continent is not null)

 select *,(RollingPopVaccinated/Population)*100 from cte_percentpopvac

 --creating temp table
  DROP TABLE if exists #PercentPeopleVaccinated
  CREATE TABLE #PercentPeopleVaccinated
  (continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  People_vaccinated numeric,
  RollingPopVaccinated numeric)
  
  INSERT INTO #PercentPeopleVaccinated 
 select d.continent,d.location,d.date,d.population,v.people_vaccinated,
	max(CAST(v.people_vaccinated as int)) over (partition by d.location order by d.date) as RollingPopVaccinated
 from [Portfolio Project]..CovidDeaths d
	join [Portfolio Project]..CovidVaccination v
	on d.location=v.location and d.date=v.date
 where d.continent is not null

 select *,(RollingPopVaccinated/population)*100 as PercentagePopVaccinated from #PercentPeopleVaccinated

 -- Creating view for PercentPeopleVaccinated for further visualization purposes
 use [Portfolio Project] --inorder to show in views
 go
 CREATE VIEW PercentPopulationVaccinated
 as select d.continent,d.location,d.date,d.population,v.people_vaccinated,
	max(CAST(v.people_vaccinated as int)) over (partition by d.location order by d.date) as RollingPopVaccinated
 from [Portfolio Project]..CovidDeaths d
	join [Portfolio Project]..CovidVaccination v
	on d.location=v.location and d.date=v.date
 where d.continent is not null

 --order by 2,3 cant be used in views,cte

 select * from PercentPopulationVaccinated






