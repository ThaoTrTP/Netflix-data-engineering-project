-- File: 03_window_functions.sql
-- Answer these questions:
-- 1. Ranking of the most popular genres by year
-- 2. Running total: total accumulated titles by year
-- 3. YoY Growth: % growth compared to previous year
-- 4. National rankings by number of titles in each decade
-- 5. Percentile: the film's position in terms of length
-- =========================================================
use netflix_db;
-- Query 1: Ranking of the most popular genres by year
select
	year_added,
    genre_name,
    count(distinct show_id) as title_count,
    rank() over (
		partition by year_added
        order by count(distinct show_id) desc
    ) as genre_ranks
from v_title_genres
where year_added is not null
group by year_added, genre_name
order by year_added desc, genre_ranks;

-- Query 2: Running total: total accumulated titles by year
select
	year_added,
    count(*) as titles_added,
    sum(count(*)) over (
		order by year_added
        rows between unbounded preceding and current row
    ) as cumulative_total
from titles
where year_added is not null
group by year_added
order by year_added;
-- Query 3: YoY growth: % growth compare to the previous year
with yearly as (
	select
		year_added,
        count(*) as titles_added
	from titles
    where year_added is not null
    group by year_added
)
select
	year_added,
    titles_added,
    lag(titles_added) over (order by year_added) as prev_year,
    round(
		(titles_added - lag(titles_added) over (order by year_added)) -- lag(col) take value in the previou row, lead(col) in constrast
        / lag(titles_added) over (order by year_added) *100, 1   
    ) as yoy_growth_pct
from yearly
order by year_added;

-- Query 4: National ranking by number of titles in each decade
with country_decade as (
	select
		c.country_name,
        t.decade,
        count(distinct t.show_id) as title_count
	from titles t
    join title_countries tc on t.show_id = tc.show_id
    join countries c  on tc.country_id = c.country_id
    where t.decade is not null
    group by c.country_name, t.decade
)
select
	country_name,
    decade,
    title_count,
    rank() over(
		partition by decade
        order by title_count desc
    ) as country_rank
from country_decade
order by decade desc, country_rank
limit 30;

-- Query 5: Percentile: the film's position in terms ò length
select
	title,
    duration_minutes,
    round(percent_rank() over(
		order by duration_minutes
    )*100, 1) as percentile
from titles
where type = 'Movie'
	and duration_minutes is not null
order by duration_minutes desc
limit 20;

-- Insight: Netflix experienced explosive growth from 2016-2019 (+423% - +22%)
-- Absolute growth peak was in 2019 with 2016 new titles added
-- 2020-2021 decline: a combination of COVID and an incomplete 2021 dataset
-- CAVEAT: YoY 2008- 2013 is not statistically significant due to a small base (< 30 titles/year)