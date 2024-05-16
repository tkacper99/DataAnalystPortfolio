-- Number of infected people vs. number of infected deaths (Europe)
-- Probability of death
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPertencage
FROM CovidPortfolio..CovidDeaths
WHERE location like '%Europe%'
ORDER BY 1,2

-- Number of infected people vs population (Europe)
-- Percentage of disease
SELECT 
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 AS InfectionPertencage
FROM CovidPortfolio..CovidDeaths
WHERE location like '%Europe%'
ORDER BY 1,2

-- Countries with the highest percentage of cases
SELECT 
	location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 AS InfectionPertencage
FROM CovidPortfolio..CovidDeaths
GROUP BY location, population
ORDER BY InfectionPertencage DESC

-- Countries with the most deaths 
SELECT 
	location, 
	MAX(total_deaths) AS TotalDeathCount
FROM CovidPortfolio..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with the highest percentage of cases
SELECT 
	continent, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 AS InfectionPertencage
FROM CovidPortfolio..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY InfectionPertencage DESC

-- Continents with the most deaths 
SELECT 
	continent, 
	MAX(total_deaths) AS TotalDeathCount
FROM CovidPortfolio..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global statistics per day
SELECT 
	date, 
	SUM(new_cases) AS SumOfNewCases, 
	SUM(new_deaths) AS SumOfNewDeaths, 
	SUM(new_deaths)/SUM(new_cases)*100 AS DeathPertencage
FROM CovidPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) <> 0 AND SUM(new_deaths) <> 0
ORDER BY date, SumOfNewCases;

-- Global total statistics
CREATE VIEW GlobalStatistics AS
SELECT 
	SUM(new_cases) AS TotalCases, 
	SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths)/SUM(new_cases)*100 AS DeathPertencage
FROM CovidPortfolio..CovidDeaths
WHERE continent IS NOT NULL

-- Population vs percentage vaccinated (CTE)
CREATE VIEW ViewOfPopVsVac AS
WITH PopVsVac(continent, location, date, population,new_vaccinations, PeopleVaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM CovidPortfolio..CovidDeaths AS dea
JOIN CovidPortfolio..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (PeopleVaccinated/population)*100 AS PertencageOfPeopleVaccinated
FROM PopVsVac;