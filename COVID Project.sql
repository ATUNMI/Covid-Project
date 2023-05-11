SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3, 4

SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
-- Probability of death if covid is contacted in Nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM CovidProject..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1, 2

-- Proportion of Total Cases to Population
-- Shows percentage of population that contacted Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationInfectedPercent
FROM CovidProject..CovidDeaths
ORDER BY 1, 2

--Countries wih highest infection rate compared to population
SELECT location, max(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100 AS PopulationInfectedPercent
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectedPercent DESC

-- Countries with highest death count
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL -- to remove the continents listed as countries
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with highest death count
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NULL -- to remove the continents listed as countries
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
		SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL

WITH PopVsVac AS (
SELECT D.continent, D.location, D.date,D.population, V.new_vaccinations
		, SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, 
		D.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths AS D
JOIN CovidProject..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- TEMP TABLE
DROP TABLE IF exists #PercentPoplationVaccinated
CREATE TABLE #PercentPoplationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPoplationVaccinated
SELECT D.continent, D.location, D.date,D.population, V.new_vaccinations
		, SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, 
		D.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths AS D
JOIN CovidProject..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPoplationVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPoplationVaccinated AS
SELECT D.continent, D.location, D.date,D.population, V.new_vaccinations
		, SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, 
		D.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths AS D
JOIN CovidProject..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *
FROM PercentPoplationVaccinated