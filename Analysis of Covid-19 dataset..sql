/*

Title = Covid-19 Data Exploration using SQL 

overview= 
Analyis of covid-19 scenario through analyis of data available using SQL.
*/


--1) Dataset used for this project.
Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


--2) Selecting specific data to work with.
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2
--Specific data used in this project is location, date, total_cases, new_cases, total_deaths , population.


--3) Total Cases vs Total Deaths & Death Percentage
-- Analysis of Covid-19 (cases/per day) in specific region (here-United States).
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

--4) Total Cases vs Total Population 
-- Analysis of percentage of population infected with Covid-19 (location and date wise)
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2

--5) Analysis of Countries with Highest Infection Rate compared to its Population (orderd in highest to lowest). 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc
--Result- Andorra has the highest infection cases with  17.12% of its population , followed by Montenegro with 15.50% , Czechia with 15.22%.

--6)Analysis of Countries with Death Count orderd by highest to lowest.
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc
--Result- United states has the highest total death count followed by Brazil, Mexico, India.

-- 7)Analysis of Continents
--Analyis of continents with the highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc
--result- North america has highest Total death count followed by south america, Asia, Europe.

--8) Analyis of Total cases , Total deaths , Total death percentage of the world.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2
--result- total cases - 150574977 , total deaths- 3180206   ,total death percentage - 2.11204149810363

-- 9.0) Analyis of Total Population vs Total Vaccinations
-- Analysis of Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--9.1) Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentage
From PopvsVac


--9.2) Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as percentage
From #PercentPopulationVaccinated



/*
Concluison =
- If we compare countries with its percentage of total poulation affected then Andorra has the highest infection cases with  17.12% of its total population , followed by Montenegro with 15.50% , Czechia with 15.22%.
- Country wise United states has the highest total death count followed by Brazil, Mexico, India.
- Continent wise North america has highest Total death count followed by south america, Asia, Europe.
- overview of the world :- total cases - 150574977 , total deaths- 3180206   ,total death percentage - 2.11204149810363
*/


