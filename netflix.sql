-- Netflix project
drop table if exists netflix
create table netflix
(
	show_id	varchar(6),
	type varchar(10),
	title varchar(160),
	director varchar(250),	
	casts varchar(1000),	
	country	varchar(150),
	date_added varchar(50),
	release_year int,	
	rating varchar(20),
	duration varchar(50),
	listed_in varchar(150),
	description varchar(255)

);

-- 1. Count the number of Movies vs TV Shows
select type, count(*) as numbers 
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
with ranked_table as (
select 
	type, rating, count(*) as number, rank() over(partition by type order by count(*) desc) as ranks
from netflix
group by type, rating
order by number desc
)
select * from ranked_table where ranks = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select *
from netflix
where type = 'Movie' and release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
select * from netflix;

select 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS countryy, 
	count(*) from netflix
group by countryy
 order by count(*) desc
limit 5;

-- 5. Identify the longest movie
select * from netflix
where type = 'Movie'
and duration = (select max(duration) from netflix);

-- 6. Find content added in the last 5 years
--ALTER TABLE netflix
--ALTER COLUMN date_added TYPE date
--USING to_date(date_added, 'Month DD, YYYY');

select * from netflix 
where date_added >= current_date - INTERVAL '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from (
	select *, unnest(string_to_array(director, ',')) as director_names 
	from netflix )
where director_names = 'Rajiv Chilaka';

--8. List all TV shows with more than 5 seasons
select * from (
	select *, SPLIT_PART(duration, ' ', 1) as num, SPLIT_PART(duration, ' ', 2)as times from netflix
) as t
where type = 'TV Show' and num::int > 5 and times ilike '%season%';

--9. Count the number of content items in each genre
select gens, count(*) from (
	select *, unnest(string_to_array(listed_in, ',')) as gens from netflix
)
group by gens
order by count(*) desc;

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
with adj_netflix as (
	select * ,unnest(string_to_array(country, ',')) as countrys from netflix
)
select
	countrys, 
	release_year, 
	count (*),
	ROUND(count(*)::numeric / (select count(*) from netflix where 'India' = any(string_to_array(country, ','))) * 100, 2) AS avg_num
from adj_netflix
where countrys = 'India'
group by countrys, release_year
order by avg_num desc
limit 5;

--11. List all movies that are documentaries
select * from 
	(select *, unnest(string_to_array(listed_in, ',')) as genre from netflix)
where genre = 'Documentaries' and type = 'Movie';

--12. Find all content without a director
select * from netflix
where director is null;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * 
from netflix
where casts like '%Salman Khan%'
  and release_year > extract(year from current_date) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select castss, count(*) as amounts from 
(
	select 
		*,
		unnest(string_to_array(casts, ',')) as castss
	from netflix
)
where country = 'India'
group by 1
order by amounts desc
limit 10;
