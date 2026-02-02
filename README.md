# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/olayinka14/netflix-analysis/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select type, count(*) as numbers 
from netflix
group by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
with ranked_table as (
select 
	type, rating, count(*) as number, rank() over(partition by type order by count(*) desc) as ranks
from netflix
group by type, rating
order by number desc
)
select * from ranked_table where ranks = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select *
from netflix
where type = 'Movie' and release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
select * from netflix;

select 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS countryy, 
	count(*) from netflix
group by countryy
 order by count(*) desc
limit 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
select * from netflix
where type = 'Movie'
and duration = (select max(duration) from netflix);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
select * from netflix 
where date_added >= current_date - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select * from (
	select *, unnest(string_to_array(director, ',')) as director_names 
	from netflix )
where director_names = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
select * from (
	select *, SPLIT_PART(duration, ' ', 1) as num, SPLIT_PART(duration, ' ', 2)as times from netflix
) as t
where type = 'TV Show' and num::int > 5 and times ilike '%season%';
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select gens, count(*) from (
	select *, unnest(string_to_array(listed_in, ',')) as gens from netflix
)
group by gens
order by count(*) desc;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select * from 
	(select *, unnest(string_to_array(listed_in, ',')) as genre from netflix)
where genre = 'Documentaries' and type = 'Movie';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select * from netflix
where director is null;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select * 
from netflix
where casts like '%Salman Khan%'
  and release_year > extract(year from current_date) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.
