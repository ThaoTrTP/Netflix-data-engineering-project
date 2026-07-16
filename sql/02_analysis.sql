-- Descriptive Analysis
use netflix_db;
-- Query 1: Dataset overview
-- Total number of titles, movies, and TV shows
select
	count(*) as total_titles,
    sum(type = 'Movie') as total_movies,
    sum(type = 'TV Show') as total_tv_shows,
    round(sum(type = 'Movie')/count(*)*100, 1) as movie_pct,
    round(sum(type = 'TV Show')/count(*)*100, 1) as tvshow_pct
from titles;
-- Query 2: Year_added Distribution
select
	year_added,
    count(*) as total_titles,
    sum(type = 'Movie') as movies,
    sum(type = 'Tv Show') as tv_shows
from titles
where year_added is not null
group by year_added
order by year_added;
-- Query 3: Top 10 popular genres
select
	genre_name,
    count(distinct show_id) as title_count,
    round(count(distinct show_id)/
		(select count(*) from titles) *100, 1) as pct_of_catalog
from v_title_genres
group by genre_name
order by title_count desc
limit 10;
-- Query 4: Top 10 countries producing the most
select
	country_name,
    count(distinct show_id) as title_count,
    sum(type = 'Movie') as movies,
    sum(type = 'TV Show') as tv_shows
from v_title_countries
group by country_name
order by title_count desc
limit 10;
-- Query 5: Top 10 director with the most title
select
	director_name,
    count(distinct show_id) as title_count,
    count(distinct type) as type_variety,
    min(release_year) as first_title_year,
    max(release_year) as latest_title_year
from v_title_directors
group by director_name
order by title_count desc
limit 10;
-- Query 6: Top 10 most frequently appearing actors
select
	cast_name,
    count(distinct show_id) as title_count,
    sum(type = 'Movie') as movies,
    sum(type = 'TV Show') as tv_shows
from v_title_cast
group by cast_name
order by title_count desc
limit 10;
-- Query 7: Movie length statistics
select
	round(avg(duration_minutes), 1) as avg_duration,
    min(duration_minutes) as min_duration,
    max(duration_minutes) as max_duration,
    round(stddev(duration_minutes), 1) as std_duration
from titles
where type = 'Movie'
	and duration_minutes is not null;
-- Min: 3 mins, Max: 312 mins -> Show title
select title, duration_minutes, type, release_year
from titles
where duration_minutes in (
    (select min(duration_minutes) from titles where type = 'Movie'),
    (select max(duration_minutes) from titles where type = 'Movie')
);
-- Query 8: Rating distribution
select
	rating,
    count(*) as title_count,
    round(count(*) / 
		(select count(*) from titles where rating is not null)*100, 1) as pct
from titles
where rating is not null
	and rating !='Unkown'
group by rating
order by title_count desc;