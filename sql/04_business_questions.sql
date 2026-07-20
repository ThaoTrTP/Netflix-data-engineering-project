-- File: 04_business_questions
-- =====================================================================
use netflix_db;
-- BQ1 - Top 5 markets grow fastest in 2019-2021
with yearly_country as (
	select
		country_name,
        year_added,
        count(distinct show_id) as title_count
	from v_title_countries
    where year_added between 2019 and 2021
    group by country_name, year_added
),
pivoted as (
	select
		country_name,
        sum(case when year_added = 2019 then title_count else 0 end) as y2019,
        sum(case when year_added = 2020 then title_count else 0 end) as y2020,
        sum(case when year_added = 2021 then title_count else 0 end) as y2021
	from yearly_country
    group by country_name
    having y2019 > 10 -- if the base country type is too samll, the percentage will be meaningless
)
select
	country_name,
    y2019, y2020, y2021,
    round((y2021 - y2019)/y2019*100, 1) as growth_pct_19_to_21
from pivoted
order by growth_pct_19_to_21 desc
limit 10;
-- ===================================================================================
-- BQ2 — Does Netflix diversify its content? Average number of genres per title per year
with genre_per_title as (
	select
		t.show_id,
        t.year_added,
        count(tg.genre_id) as genre_count
	from titles t
    join title_genres tg on t.show_id = tg.show_id
    where t.year_added is not null
    group by t.show_id, t.year_added
)
select
	year_added,
    round(avg(genre_count), 2) as avg_genres_per_title,
    min(genre_count) as min_genres,
    max(genre_count) as max_genres,
    count(*) as total_titles
from genre_per_title
group by year_added
order by year_added;
-- ===================================================================================
-- BQ3 — Sweetspot length by rating
select
	rating,
    count(*) as movie_count,
    round(avg(duration_minutes), 1) as avg_duration,
    min(duration_minutes) as min_duration,
    max(duration_minutes) as max_duration,
    round(stddev(duration_minutes), 1) as std_duration
from titles
where type = 'Movie'
	and duration_minutes is not null
    and rating not in ('Unknown', 'UR', 'NR')
group by rating
having movie_count >= 10
order by avg_duration desc;

-- ===================================================================================
-- BQ4 — Most versatile director
select
	d.director_name,
    count(distinct t.show_id) as title_count,
    count(distinct g.genre_id) as genre_variety,
    group_concat(
		distinct g.genre_name
        order by g.genre_name
        separator ' | '
    ) as genres_worked
from directors d
join title_directors td on d.director_id = td.director_id
join titles t on td.show_id = t.show_id
join title_genres tg on t.show_id = tg.show_id
join genres g on tg.genre_id = g.genre_id
group by d.director_id, d.director_name
having title_count >= 5
order by genre_variety desc, title_count desc
limit 10;
-- ===================================================================================
-- BQ5 — Does Netflix acquire content faster over time?
with speed as (
	select
		t.year_added,
        c.country_name,
        t.days_to_add
	from titles t
    join title_countries tc on t.show_id = tc.show_id
    join countries c on tc.country_id = c.country_id
    where t.days_to_add > 0
		and t.days_to_add < 36500
        and t.year_added is not null
)
select
	year_added,
    count(*) as titles_analyzed,
    round(avg(days_to_add), 0) as avg_days_to_add,
    round(min(days_to_add), 0) as min_days,
    round(max(days_to_add), 0) as max_days
from speed
group by year_added
order by year_added;
-- ===================================================================================
-- BQ6 — Is there seasonality when adding content?
select
	month_added,
    count(*) as total_titles,
    sum(type ='Movie') as movies,
    sum(type = 'TV Show') as tv_shows,
    round(sum(type = 'Movie')/count(*)*100, 1) as movie_pct,
    round(count(*)/sum(count(*)) over () *100, 1) as pct_of_annual
from titles
where month_added is not null
group by month_added
order by month_added;

-- ================================================================
-- Insight 
-- 1. Turkey was the only emerging market to grow from 2019-2021
-- 2. Netflix diversified its genres from 2017, avergaeing 2.0+ genres/titles
-- 3. Children's films (TV-Y) are 2x shorter than teen films (TV-14)
-- 4. artin Scorses and Visal Bhardwaj are the most versatile directors
-- 5. Netflix is buying older catalogs over time (averaging 7.5 years in 2021).
-- 6. July and December are peak release months, February is the lowest.