/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
From PortfolioProject1..CovidDeaths
Where continent is not NULL
order by 3,4

/*
Altering table columns data types since they were incorrect in CSV file.
For CovidDeaths Table
*/

Alter Table CovidDeaths
Alter Column total_Deaths int

Alter Table CovidDeaths
Alter Column total_Cases float

Alter Table CovidDeaths
Alter Column population bigint 

update CovidDeaths
Set new_cases = NULL
Where new_cases = 0

update CovidDeaths
Set new_deaths = NULL
Where new_deaths = 0

Alter Table CovidDeaths
Alter Column new_cases int

Alter Table CovidDeaths
Alter Column new_deaths int

update CovidDeaths
Set total_cases = NULL
Where total_cases = 0

Alter Table CovidDeaths
Alter Column date datetime

update CovidDeaths
Set total_deaths = NULL
Where total_deaths = 0

update CovidDeaths
Set population = NULL
Where population = 0

update CovidDeaths
Set continent = NULL
Where continent = ''

/*
Altering CovidVaccinations Table: as data types are incorrect
*/

Alter Table CovidVaccinations
Alter Column  Date datetime

Alter Table CovidVaccinations
Alter Column  new_tests float


Alter Table CovidVaccinations
Alter Column  total_tests float


Alter Table CovidVaccinations
Alter Column new_vaccinations float

update CovidVaccinations
Set new_vaccinations = NULL
Where new_vaccinations = 0

--Select *
--From PortfolioProject1.dbo.CovidVaccinations
--order by 3,4

/*
-- Select Data that we are going to be starting with
*/
select location, continent,date,total_cases, new_cases,total_deaths,population
From PortfolioProject1..CovidDeaths
Where continent is not NULL
Order by 1


/*
Total cases vs total death analysis by date
*/


select location, continent,date,total_cases, total_deaths, ((total_deaths/total_cases)*100) as Death_Percentage
From PortfolioProject1..CovidDeaths
Where continent is not NULL
Order by 1,3


/*
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
*/


select location, continent,date,total_cases, total_deaths, ((total_deaths/total_cases)*100) as Death_Percentage
From PortfolioProject1..CovidDeaths
Where location like '%pakistan%' and continent is not NULL
Order by 1,2



--Looking at Total cases vs the population in our country
-- Shows what percentage of population got covid



select location, continent,date, population, total_cases, ((total_cases/population)*100) as PercentOfPopulationInfected
From PortfolioProject1..CovidDeaths
Where location like '%pakistan%' and continent is not NULL
Order by 1,2


/*
showing countries having highest infection rate compared to population
*/


select location,continent, population, Max(total_cases) as HighestInfectionCount, Max ((total_cases/population)*100) as PercentOfPopulationInfected
From PortfolioProject1..CovidDeaths
Where continent is not NULL
--Where location like '%pakistan%'
Group By location, population,continent
Order by PercentOfPopulationInfected DESC


-- showing countries with highest death count per population


select location,continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
where continent is not NULL
--Where location like '%pakistan%'
Group By location, continent
Order by TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with highest death count



select continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
where continent is not NULL
--Where location like '%pakistan%'
Group By continent
Order by TotalDeathCount DESC



-- GLOBAL NUMBERS: Total cases vs Deaths analysis by continent

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


/*
Using second table of database
*/

Select *
From PortfolioProject1.dbo.CovidVaccinations
Where continent is not null


/*
Joining Deaths and Vaccinations Table
*/

Select *
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


-- Total population vs vaccinations

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Adding a rolling count to find out overall people vaccianted

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations as float)) OVER (Partition By dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query:

With PopvsVac (CONTINENT, LOCATION, DATE, POPULATION,NEW_VACCINATIONS, ROLLINGPEOPLEVACCINATED)
as
(
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations as float)) OVER (Partition By dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (ROLLINGPEOPLEVACCINATED/POPULATION)*100
FROM PopvsVac



-- -- Using Temp Table to perform Calculation on Partition By in previous query


Drop table if exists #PercentPopVaccinated

create table #PercentPopVaccinated
(
CONTINENT nvarchar (255), LOCATION nvarchar (255), Date datetime,
Population numeric, New_vaccinations int, RollingPeopleVaccinated numeric
)
Insert into #PercentPopVaccinated

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations as float)) OVER (Partition By dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From #PercentPopVaccinated



-- Creating view to store data for later visualisations:



Create View PercentPeopleVaccinated
as
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations as float)) OVER (Partition By dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPeopleVaccinated

Create View DeathCountPerContinent
as
select continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
where continent is not NULL
--Where location like '%pakistan%'
Group By continent
--Order by TotalDeathCount DESC

Select *
From DeathCountPerContinent
