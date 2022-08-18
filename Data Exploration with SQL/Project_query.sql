select *
from Project..Coviddeaths
order by 3,4

--select *
--from Project..Covidvaccinations
--order by 3,4



select * 
from Project..Coviddeaths
where continent is not null
order by 3,4

-----Selecting Data that is going to be used
select location,date,total_cases,new_cases,total_deaths,population
from Project..Coviddeaths
where continent is not null
order by 1,2

--Total cases vs total deaths
--shows likelihood of dying if infected by covid
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Project..Coviddeaths
where location like '%india%'
and continent is not null
order by 1,2 

--Total cases per population
--shows the percentage of population infected

select location,date,population,total_cases,total_deaths,(total_deaths/population)*100 as Populationinfected
from Project..Coviddeaths
where location like '%india%'
and continent is not null
order by 1,2 

--Countries with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as Populationinfected
from Project..Coviddeaths
group by location,population
order by Populationinfected DESC

--Countries with highest death count  
select location,max(cast(total_deaths as int)) as TotalDeathCount
from Project..Coviddeaths
where continent is not  null
group by location
order by TotalDeathCount DESC

--By continent 
--Continent with highest death count 
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from Project..Coviddeaths
where continent is  not null
group by continent 
order by TotalDeathCount DESC

--Global Numbers
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalDeathPercentage
From Project..CovidDeaths
where continent is not null 
--group by date
order by 1,2 
 
 --Joining covid deaths and covid vacinations


 select*
 from Project..Coviddeaths dea
 join Project..Covidvaccinations vac
      on dea.location =vac.location
	  and dea.date=vac.date
 --Total Population Vs Vaccination
select dea.continent,dea.location,dea.population,vac.new_vaccinations
from Project..Coviddeaths dea
join Project..Covidvaccinations vac
   on dea.location =vac.location
	  and dea.date=vac.date
where dea.continent is not null
order by 2,3

--

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date )as RollingPeopleVaccinated
from Project..Coviddeaths dea
join Project..Covidvaccinations vac
   on dea.location =vac.location
	  and dea.date=vac.date
where dea.continent is not null
order by 2,3


--CTE or Temp Table
--Use CTE
with PopvsVac (continent,date,population,location,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date )as RollingPeopleVaccinated
from Project..Coviddeaths dea
join Project..Covidvaccinations vac
   on dea.location =vac.location
	  and dea.date=vac.date
where dea.continent is not null

)
select *,(RollingPeopleVaccinated/convert(int,population))*100 as PopulationVaccinated
from PopvsVac


----Temp table
--drop table if exists #PercentPopulationVaccinated
--create table #PercentPopulationVaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population float,
--new_vaccinations numeric,
--RollingPeoplevaccinated numeric
--)
--insert into #PercentPopulationVaccinated
--select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
-- Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
-- dea.date )as RollingPeopleVaccinated
--from Project..Coviddeaths dea
--join Project..Covidvaccinations vac
--   on dea.location =vac.location
--	  and dea.date=vac.date
----where dea.continent is not null

--select *,(RollingPeopleVaccinated/population)*100 as PopulationVaccinated
--from #PercentPopulationVaccinated

--Creating view to store data for viualization
 

Create View PopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..Coviddeaths dea
Join Project..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
