select *
from PortfolioProject..Covid_Deaths
where continent is not null

alter table PortfolioProject..Covid_Deaths
ALTER column total_cases float;

alter table PortfolioProject..Covid_Deaths
ALTER column total_deaths float;

alter table PortfolioProject..Covid_Deaths
ALTER column new_deaths float;

select location,
date,
total_cases,
new_cases,
total_deaths,
population
from PortfolioProject..Covid_Deaths
where continent is not null
ORDER BY 1,2

select location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..Covid_Deaths
where location like 'vietnam'
and continent is not null
ORDER BY 1,2

select location,
date,
population,
total_cases,
(total_cases/population)*100 as population_infect_percentage
from PortfolioProject..Covid_Deaths
where location like 'vietnam'
and continent is not null
ORDER BY 1,2

select location,
population,
max(total_cases) as highest_infection_count,
(max(total_cases)/population)*100 as highest_totalcase_percentage
from PortfolioProject..Covid_Deaths
where continent is not null
group by location, population
ORDER BY 4 desc

select location, max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..Covid_Deaths
where continent is not null
group by location
ORDER BY 2 desc

select continent, max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..Covid_Deaths
where continent is not null
group by continent
ORDER BY 2 desc

select date,
sum(new_cases) as total_new_cases,
sum(new_deaths) as total_new_deaths,
sum(new_deaths)/sum(new_cases)*100 as death_percentage
from PortfolioProject..Covid_Deaths
where continent is not null
and new_cases > 0
group by date
order by 1,2

-- cte
with popvsvac (continent,
	location,
	date,
	population,
	new_vaccination,
	rolling_ppl_vaccinated)
as
(
select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations))
	over (partition by dea.location
	order by dea.location, dea.date)
	as rolling_ppl_vaccinated
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, rolling_ppl_vaccinated/population*100
from popvsvac

-- temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_ppl_vaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations))
	over (partition by dea.location
	order by dea.location, dea.date)
	as rolling_ppl_vaccinated
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *, rolling_ppl_vaccinated/population*100
from #PercentPopulationVaccinated

-- create view to store data for visualization

use PortfolioProject
go
create view PercentPopulationVaccinated as
select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations))
	over (partition by dea.location
	order by dea.location, dea.date)
	as rolling_ppl_vaccinated
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
