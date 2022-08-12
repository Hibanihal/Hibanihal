/* 
Covid 19 Data Exploration 

skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views,Converting Data Types

*/


SELECT *
FROM portfolio..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4



--selecting data that we are going to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;



-- Total cases vs Total deaths
-- shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM portfolio..CovidDeaths
WHERE location like '%emirates%'
AND continent is not null
ORDER BY 1,2;



--Total cases vs Population
--Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as percentage_population_infected
FROM portfolio..CovidDeaths
ORDER BY 1,2; 



--Countries with Highest Infection Rate compared to Population

SELECT location,max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as percentage_population_infected
FROM portfolio..CovidDeaths
GROUP BY location, population
ORDER BY percentage_population_infected DESC; 



--countries with highest Death count per population

SELECT location, max(cast(total_deaths as int)) AS TotalDeathCount
FROM portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;




-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent,max(cast(total_deaths AS int)) AS TotalDeathCount
FROM portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;



--GLOBAL NUMBERS

SELECT date, sum(new_cases) AS totalcases, sum(cast(new_deaths AS int)) AS totaldeaths, (sum(cast(new_deaths AS int))/sum(new_cases))*100 AS DeathPercentage
FROM portfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;



--overall death percentage

SELECT sum(new_cases) AS totalcases, sum(cast( new_deaths as int)) AS totaldeaths, (sum(cast(new_deaths AS int))/sum(new_cases))*100 AS DeathPercentage
FROM portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;
  


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) AS rolling_people_vaccinated
FROM portfolio..CovidDeaths AS d
JOIN portfolio..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null AND v.new_vaccinations is not null
ORDER BY 2,3



--Using CTE to perform calculation on partition by in previous query

WITH popvsvac (continent,location, date,population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
FROM portfolio..CovidDeaths AS d
JOIN portfolio..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null and v.new_vaccinations is not null
)
SELECT * , (rolling_people_vaccinated/population)*100 AS rolling_percentage
FROM popvsvac;



--Using TEMP Table to perform Calculation on Partition By in previous query

DROP table if exists percent_population_vaccinated
CREATE TABLE percent_population_vaccinated
( continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric )

INSERT into percent_population_vaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
FROM portfolio..CovidDeaths AS d
JOIN portfolio..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date

SELECT * , (rolling_people_vaccinated/population)*100 AS rolling_percentage
FROM percent_population_vaccinated;



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
FROM portfolio..CovidDeaths AS d
JOIN portfolio..CovidVaccinations as v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null AND v.new_vaccinations is not null

