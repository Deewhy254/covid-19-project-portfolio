
  select location, date, total_cases, new_cases, total_deaths, population
  from CovidDeaths
  order by 1,2

  ---looking at total cases vs total deaths
  ---shows likelihood of dying if you contact covid in united states

 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as deathpercentage
  from CovidDeaths
 WHERE location like '%states%'

 ----looking at total cases vs population
 -- shows what percentage of population get covid
  select location, date, total_cases, population, (total_cases/population)*100  as deathpercentage
  from CovidDeaths
-- WHERE location like '%states%'
 order by 1,2

 ---looking at countries with highest infection rate compared to population
 select location, population, max(cast(total_cases as int)) as highestinfection, max((total_cases/population))*100  as percentagepopulationaffected
  from CovidDeaths
--- WHERE location like '%states%
group by location, population
order by percentagepopulationaffected desc

---showing countries with the highest death count
 select location, MAX(cast(total_deaths as int))  as total_deathscount
  from CovidDeaths
  where continent is NULL
  group by location
  order by total_deathscount desc

  ----GLOBAL NUMBERS
   select sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum
   (new_cases)*100 as deathpercentage
  from CovidDeaths
--- WHERE location like '%states%
where continent is not null 
---group by date
order by 1,2
 
--looking at total population who received vacination

with popvsvac (continent, locacation, date, population, new_vaccinations, rollingvacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvacinated
from CovidDeaths dea
join  CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not NULL
  )
 select *, (rollingvacinated/population)*100
 from popvsvac 

 ---Temp table
 drop table if exists #pecentpooulationvaccinated
 create table #percentpopulationvacinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingvaccinated numeric
 )
 insert into #percentpopulationvacinated
with popvsvac (continent, locacation, date, population, new_vaccinations, rollingvacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvacinated
from CovidDeaths dea
join  CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not NULL
  )
 select *, (rollingvacinated/population)*100
 from #percentpopulationvacinated