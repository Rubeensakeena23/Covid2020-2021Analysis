SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT 
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at total cases vs total deaths

SELECT 
	Location,
	date,
	total_cases,
	total_deaths,
	ROUND((total_deaths/total_cases) * 100, 3) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE 'India'
ORDER BY 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got covid

SELECT 
	Location,
	date,
	total_cases,
	population,
	ROUND((total_cases/population) * 100, 3) AS CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE 'India'
ORDER BY 1,2

-- Looking for Countries with Highest Infection Rate compared to Population


SELECT 
	Location,
	population,
	MAX(total_cases) highest_infection_count,
	ROUND(MAX((total_cases/population) * 100), 3) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY
	location, population
ORDER BY PercentPopulationInfected DESC


-- Showing the countries with the highest death count per population

SELECT 
	Location,
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
	location
ORDER BY total_death_count DESC


-- Lets break it down by continent

-- Showing the continent with the highest death count

SELECT 
	continent,
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
	continent
ORDER BY total_death_count DESC

-- Global numbers


SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2




-- Looking at total population vs vaccination


SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM
PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
	SELECT 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) RollingPeopleVaccinated
	FROM
	PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--DER BY 2,3
) 
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS PercentagePopulationVaccinated
FROM PopvsVac


-- Creating View to store data for later visualtions

DROP VIEW IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	--DER BY 2,3


SELECT *
FROM PercentPopulationVaccinated
