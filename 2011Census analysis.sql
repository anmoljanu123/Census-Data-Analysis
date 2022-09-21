--2011 census analysis


--===============
--part1
-- ==============


use project_1;
select * from dbo.Data1;
select * from dbo.Data2;


--counting no. of records
select count(*) as number_OF_ROWS from project_1..data1;

--display records of specific states
select * from project_1..data1 where state in ('jharkhand', 'bihar');

--total population of country
select sum(population) as total_population from project_1.dbo.Data2;

--average growth
select avg(growth)*100 as average_growth from project_1.dbo.Data1;

--average growth statewise
select state,avg(growth)*100 as average_growth from project_1.dbo.Data1 group by state;

--average sex ratio statewise in deceasing order
select state,round(avg(Sex_Ratio),0) as average_sexratio from project_1.dbo.Data1 group by state order by average_sexratio desc;

--average literacy ratio statewise in decreasing order
select state,round(avg(Literacy),0) as average_literacy_rate from project_1.dbo.Data1 group by state order by average_literacy_rate desc;

--average literacy ratio statewise followed by condition in decreasing order 
select state,round(avg(Literacy),0) as average_literacy_rate from project_1.dbo.Data1 group by state having round(avg(Literacy),0)>90 order by average_literacy_rate desc;

--top 3 states showing highest growth ratio
select top 3 state,avg(growth)*100 as average_growth from project_1.dbo.Data1 group by state order by average_growth desc;

--bottom 3 states showing lowest growth ratio
select top 3 state,avg(growth)*100 as average_growth from project_1.dbo.Data1 group by state order by average_growth;

--top and bottom 3 states in literacy rate(concept use: temporary tables and union)
drop table if exists temp_topstate;
create table temp_topstate(State nvarchar(255),literacy_ratio float)

insert into temp_topstate
select state,round(avg(Literacy),0) as average_literacy_ratio from project_1.dbo.Data1 group by state order by
average_literacy_ratio desc;
select top 3 * from temp_topstate order by literacy_ratio desc;

drop table if exists temp_bottomstate;
create table temp_bottomstate(State nvarchar(255),literacy_ratio float)

insert into temp_bottomstate
select state,round(avg(Literacy),0) as average_literacy_ratio from project_1.dbo.Data1 group by state order by
average_literacy_ratio desc;
select top 3 * from temp_bottomstate order by literacy_ratio asc;

--union operator(merge top and bottom states according to literacy rate
select * from(
select top 3 * from temp_topstate order by literacy_ratio desc)a
union
select * from(
select top 3 * from temp_bottomstate order by literacy_ratio asc)b
order by literacy_ratio desc ;


--states starting with letter a
select distinct state from project_1.dbo.Data1 where state like 'a%' or state like 'b%'; 

--states starting with letter a and end with d
select distinct state from project_1.dbo.Data1 where state like 'a%m' ; 


-- =============
--part2 (advance)
--==============


--joining tables
select a.district ,a.state ,a.sex_ratio/1000 as sex_ratio, b.population from dbo.Data1 a join dbo.Data2 b on a.district=b.district;

--no. of males and females in district
select district ,state, round((population/(sex_ratio+1)),0) as males,round(population*(sex_ratio/(sex_ratio+1)),0) as females ,population
from 
(select a.district ,a.state ,a.sex_ratio/1000 as sex_ratio, b.population from dbo.Data1 a join dbo.Data2 b on a.district=b.district) temp;

--no. of males and females in state
select temp2.state,sum(males) total_males,sum(females) total_females from
(select district ,state, round((population/(sex_ratio+1)),0) as males,round(population*(sex_ratio/(sex_ratio+1)),0) as females ,population
from 
(select a.district ,a.state ,a.sex_ratio/1000 as sex_ratio, b.population from dbo.Data1 a join dbo.Data2 b on a.district=b.district) temp1) temp2 group by temp2.state;


--literacy rate
select a.district ,a.state ,a.literacy, b.population from dbo.Data1 a join dbo.Data2 b on a.district=b.district;

--no. of illiterate and literate people
select t1.district, t1.state,round((t1.literacy/100)*t1.population,0) as literate_people,round(t1.population-((t1.literacy/100)*t1.population),0) as illiterate_people from
(select a.district ,a.state ,a.literacy, b.population from dbo.Data1 a join dbo.Data2 b on a.district=b.district) t1;

--no. of illiterate and literate people by state
select t2.state,sum(t2.literate_people) literate_people,sum(t2.illiterate_people) illiterate_people from
(select t1.district, t1.state,round((t1.literacy/100)*t1.population,0) literate_people,round(t1.population-((t1.literacy/100)*t1.population),0) illiterate_people from
(select a.district ,a.state ,a.literacy, b.population from dbo.Data1 a join dbo.Data2 b on a.district=b.district) t1)t2 
group by state;

--population in previous census
select a.district,a.state,round(b.population/(1+a.growth),0) prev_population from dbo.data1 a join dbo.data2 b on a.district=b.district;

--population in previous census(by state)
select c.state,sum(c.prev_population) prev_population from
(select a.district,a.state,round(b.population/(1+a.growth),0) prev_population from dbo.data1 a join dbo.data2 b on a.district=b.district) c 
group by state;

--total population of india in previous and currnt census
select sum(c.prev_population) total_prev_population,sum(c.population) total_current_population from
(select a.district,a.state,round(b.population/(1+a.growth),0) prev_population ,population from dbo.data1 a join dbo.data2 b on a.district=b.district) c ;


--population per unitsquare area
select d.total_prev_population/d.total_area as prev_population_perunit_area,d.total_current_population/d.total_area as current_population_perunit_area 
from
(select sum(c.prev_population) total_prev_population,sum(c.population) total_current_population,sum(c.Area_km2) as total_area from
(select a.district,a.state,round(b.population/(1+a.growth),0) prev_population ,population,Area_km2 from dbo.data1 a join dbo.data2 b on a.district=b.district) c) d;


---ranking top3 district literacy wise in each state
select * from 
(select district,state,rank() over (partition by state order by literacy desc) rrank from data1) temp where temp.rrank<=3 ;