Select * 
From Covid_Project..CovidDeaths$
order by 3,4 

--Select * 
--From Covid_Project..CovidVaccinations$
--order by 3,4 

-- Select the Data the I will be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From Covid_Project..CovidDeaths$
order by 1, 2 

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country. 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid_Project..CovidDeaths$
Where location like '%states%'
order by 1, 2 

-- Looking at the Total Cases vs Total Population
-- Shows the percentage of the population that contracted Covid

Select Location, date, total_cases, Population,(total_cases/Population)*100 as ContractionPercentage
From Covid_Project..CovidDeaths$
Where location like '%states%'
order by 1, 2 

-- Looking at countries with the highest infection rate compared to population

Select Location,Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/Population))*100 as ContractionPercentage
From Covid_Project..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by ContractionPercentage desc

--Showing the countries with the highest death count per population

Select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from Covid_Project..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Now we look at data by continent

-- Showing continents with the highest death count

Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from Covid_Project..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM Covid_Project..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2 


--Global Death percentage as of 2021-06-02

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM Covid_Project..CovidDeaths$
Where continent is not null
Order by 1,2 

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Project..CovidDeaths$ dea
Join Covid_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Project..CovidDeaths$ dea
Join Covid_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric, 
)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Project..CovidDeaths$ dea
Join Covid_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store later for Data Visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Project..CovidDeaths$ dea
Join Covid_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3