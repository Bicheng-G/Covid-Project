USE PortfoilioProject;

SELECT *
FROM PortfoilioProject.coviddeaths
WHERE continent is not null
ORDER BY 3,4;

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfoilioProject.coviddeaths
WHERE location LIKE 'Singapore'
ORDER BY 1,2;

-- looking at total cases vs population
-- shows percentatge of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
FROM PortfoilioProject.coviddeaths
WHERE location LIKE 'Singapore'
ORDER BY 1,2;

-- looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases), population, MAX((total_cases/population)*100) as covid_percentage
FROM PortfoilioProject.coviddeaths
GROUP BY location,population
ORDER BY covid_percentage DESC;

-- show countries with highest death rate per population
SELECT location, MAX(total_deaths) as death_count, population, MAX((total_deaths/population)*100) as death_percentage
FROM PortfoilioProject.coviddeaths
GROUP BY location,population
ORDER BY death_percentage DESC;

-- Break things by continent
SELECT continent, MAX(total_deaths) as death_count
FROM PortfoilioProject.coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY death_count DESC;

-- global numbers
-- death percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as death_percentage
FROM PortfoilioProject.coviddeaths
WHERE continent is not null;

-- Joins
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER  (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingsumvaccinated
FROM PortfoilioProject.coviddeaths dea
JOIN PortfoilioProject.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- use CTE
WITH popvsvac (continent, location, date ,population, new_vaccinations, rollingsumvaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER  (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingsumvaccinated
FROM PortfoilioProject.coviddeaths dea
JOIN PortfoilioProject.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rollingsumvaccinated/population) *100 
FROM popvsvac
WHERE location = 'Singapore';


-- create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER  (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingsumvaccinated
FROM PortfoilioProject.coviddeaths dea
JOIN PortfoilioProject.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null;

