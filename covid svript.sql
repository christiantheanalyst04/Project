use covid

select * 
from CovidDeaths
order by 3,4


--select * 
--from CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Percentage
from CovidDeaths
order by 1,2


--Total cases vs population


select location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected		
from CovidDeaths
order by 1,2


--Countries with highest infection  compared to population

select location, population, max (total_cases) as HighestInfectionCount, max ((total_cases/population)) * 100 as PercentPopulationInfected		
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Total Death per Country

select location, max (cast (total_deaths as int)) as TotalDeathcount		
from CovidDeaths
where continent is not null
group by location, population
order by TotalDeathcount desc

--Total Death per Continent

select continent, max (cast (total_deaths as int)) as TotalDeathcount		
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathcount desc

--Global Numbers
 

select sum(new_cases) as Total_Cases, Sum	(cast (new_deaths as int)) Total_Deaths, Sum	(cast (new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by DeathPercentage desc


--Total Population vs Vaccination

with popvsvac (Continent, Location, Date, Population, New_Vaccinations, RunningTotalVaccinated)

as

(
Select cd.continent, cd.location, cd.date, cd.population, CV.new_vaccinations,
sum (cast (CV.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date)
as RunningTotalVaccinated
from CovidDeaths CD
join CovidVaccinations CV
on cd.location = cv.location
and cd.date = CV.date
where cd.continent is not null
)


Select *, (RunningTotalVaccinated/population) * 100
from popvsvac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RunningTotalVaccinated numeric

)


insert into #PercentPopulationVaccinated


Select cd.continent, cd.location, cd.date, cd.population, CV.new_vaccinations,
sum (cast (CV.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date)
as RunningTotalVaccinated
from CovidDeaths CD
join CovidVaccinations CV
on cd.location = cv.location
and cd.date = CV.date
where cd.continent is not null


Select *, (RunningTotalVaccinated/population) * 100
from #PercentPopulationVaccinated

--Create View


Create View PercentPopulationVaccinated as 
Select cd.continent, cd.location, cd.date, cd.population, CV.new_vaccinations,
sum (cast (CV.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date)
as RunningTotalVaccinated
from CovidDeaths CD
join CovidVaccinations CV
on cd.location = cv.location
and cd.date = CV.date
where cd.continent is not null

select * 
from PercentPopulationVaccinated