SELECT *
FROM PracticeProject.dbo.CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PracticeProject.dbo.CovidVaccinations
--order by 3,4

-- Select data that I am going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PracticeProject.dbo.CovidDeaths
WHERE continent is not null
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PracticeProject.dbo.CovidDeaths
WHERE location like '%states%'
AND continent is not null
Order by 1, 2

-- Looking at Total cases vs Population
-- Shows what percentage of population has contracted COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PracticeProject.dbo.CovidDeaths
-- WHERE location = 'United States'
Order by 1, 2

-- Looking at Countries with Highest Infectioon Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PracticeProject.dbo.CovidDeaths
-- WHERE location = 'United States'
Group by location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PracticeProject.dbo.CovidDeaths
WHERE continent is not null
Group by location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing Continents with Highest Death Count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PracticeProject.dbo.CovidDeaths
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PracticeProject.dbo.CovidDeaths
WHERE continent is not null
--Group by date
Order by 1, 2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PracticeProject.dbo.CovidDeaths dea
JOIN  PracticeProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3


-- USE CTE

WITH PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PracticeProject.dbo.CovidDeaths dea
JOIN  PracticeProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PracticeProject.dbo.CovidDeaths dea
JOIN  PracticeProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is not null
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PracticeProject.dbo.CovidDeaths dea
JOIN  PracticeProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3


SELECT *
FROM PercentPopulationVaccinated