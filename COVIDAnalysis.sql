select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths (percentage of people who died from Covid)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' 
order by 1,2

--Looking at Total Cases vs Population, shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%' 
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected, MAX((total_deaths/population))*100 as DeathRate
From PortfolioProject..CovidDeaths
Group by Location, population
order by PercentofPopulationInfected desc

--Shows Countries with Highest Death Count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Continents

--Continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


--Joining the Two Tables together
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--Looking at Population and Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsRolling
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinationsRolling)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsRolling
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select*, (TotalVaccinationsRolling/Population)*100 as PercentPopulationVaccinated
From PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinationsRolling numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsRolling
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select*, (TotalVaccinationsRolling/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated



--Creating View for data visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsRolling
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null



Select*
From PercentPopulationVaccinated
