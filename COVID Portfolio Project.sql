
-- Query on COVID Cases and Deaths

SELECT
	*
FROM
	PortfolioProject..CovidDeaths
ORDER BY 3,4

--Select data to be used

SELECT
	Location, date, total_cases, new_cases, total_deaths, population
FROM
	PortfolioProject..CovidDeaths
ORDER BY
	1,2


-- Viewing Total Cases vs Total Deaths with percentage of Death for Nigeria

SELECT
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPecentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	location = 'Nigeria'
ORDER BY
	1,2;


SELECT
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPecentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	location LIKE '%state%' -- WildCard
ORDER BY
	1,2;


-- Viewing Total Cases vs Population
-- Percentage of population infected with COVID
SELECT
	Location, date, population, total_cases, (total_cases/population)*100 PercentInfectedPopulation
FROM
	PortfolioProject..CovidDeaths
WHERE
	location = 'Nigeria'
ORDER BY
	1,2;

-- Countries with Highest Infection Rate to Population
SELECT
	Location, population, MAX(total_cases), MAX((total_cases/population))*100 PecentageInfectedPopulation
FROM
	PortfolioProject..CovidDeaths
GROUP BY
	location, population
ORDER BY
	4 DESC;

-- Countries with Highest Death Count per Population
SELECT
	Location, MAX(CAST(total_deaths AS int)) TotalDeathCount -- Converted varchar column to int
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL  -- Filtered Null Values from Country column
GROUP BY
	location
ORDER BY
	2 DESC;

-- Continent Breakdown
SELECT
	continent, MAX(CAST(total_deaths AS int)) TotalDeathCount -- Converted varchar column to int
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL  -- Filtered Null Values from Country column
GROUP BY
	continent
ORDER BY
	2 DESC;


-- Global Numbers
SELECT
	 SUM(new_cases) total_cases, SUM(CAST(new_deaths AS int)) total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
--GROUP BY
--	date
ORDER BY
	1,2 DESC;



-- Query on COVID Vaccinations

/*Merging tables together on Location and Date columns
  Total Population vs Vaccinations*/
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingVaccinations
FROM
	PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
AS
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingVaccinations
FROM
	PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
)
SELECT
	*, (RollingVaccinations/Population)*100 PercentageRollingVaccinatedPopulations
FROM
	PopvsVac



-- Using TempTable
DROP TABLE IF EXISTS #PercentVaccinatedPopulation
CREATE TABLE #PercentVaccinatedPopulation
(
Continent varchar(255),
Location varchar(255),
Data datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)

INSERT INTO #PercentVaccinatedPopulation
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingVaccinations
FROM
	PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

SELECT
	*, (RollingVaccinations/Population)*100 PercentageRollingVaccinatedPopulations
FROM
	#PercentVaccinatedPopulation



-- Creating view to store data for visualisation

CREATE VIEW PercentVaccinatedPopulation
AS
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingVaccinations
FROM
	PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	dea.continent IS NOT NULL


SELECT *
FROM PercentVaccinatedPopulation