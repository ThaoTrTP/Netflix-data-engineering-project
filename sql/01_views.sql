-- View 1: v_title_genres
create or replace view v_title_genres as
select
	t.show_id,
    t.type,
    t.title,
    t.release_year,
    t.year_added,
    t.month_added,
    t.duration_minutes,
    t.duration_seasons,
    t.decade,
    t.content_age,
    t.movie_length_cat,
    g.genre_name
from titles t
join title_genres tg on t.show_id = tg.show_id
join genres g on tg.genre_id = g.genre_id;

-- View 2: v_title_directors
create or replace view v_title_directors as
select
	t.show_id,
    t.type,
    t.title,
    t.release_year,
    t.year_added,
    d.director_name
from titles t
join title_directors td on t.show_id = td.show_id
join directors d on td.director_id = d.director_id;

-- View 3: v_title_cast
create or replace view v_title_cast as
select
	t.show_id,
    t.type,
    t.title,
    t.release_year,
    t.year_added,
    c.cast_name
from titles t
join title_cast tc on t.show_id = tc.show_id
join cast_members c on tc.cast_id = c.cast_id;

-- View 4: v_title_countries
create or replace view v_title_countries as
select
	t.show_id,
    t.type,
    t.title,
    t.release_year,
    t.year_added,
    c.country_name
from titles t
join title_countries tc on t.show_id = tc.show_id
join countries c on tc.country_id = c.country_id;

-- View 5: v_content_summary
create or replace view v_content_summary as
select
	t.show_id,
    t.type,
    t.title,
    t.release_year,
    t.year_added,
    t.rating,
    t.duration_minutes,
    t.duration_seasons,
    t.decade,
    t.content_age,
    t.movie_length_cat,
    t.days_to_add,
    -- Primary values
    min(d.director_name) as primary_director,
    min(c.country_name) as primary_country
from titles t
left join title_directors td on t.show_id = td.show_id
left join directors d on td.director_id = d.director_id
left join title_countries tc on t.show_id = tc.show_id
left join countries c on tc.country_id = c.country_id
group by
	t.show_id, t.type, t.title, t.release_year,
    t.year_added, t.month_added, t.rating,
    t.duration_minutes, t.duration_seasons,
    t.decade, t.content_age, t.movie_length_cat, t.days_to_add;
    
-- Verify how many rows are there on each view
select 'v_title_genres' as view_name, count(*) from v_title_genres
union all
select 'v_title_directors', count(*) from v_title_directors
union all
select 'v_title_cast', count(*) from v_title_cast
union all
select 'v_title_countries', count(*) from v_title_countries
union all
select 'v_content_summary', count(*) from v_content_summary;

-- Check views
select * from v_title_genres limit 5;
select * from v_title_cast limit 5;
select * from v_title_directors limit 5;
select * from v_title_countries limit 5;
select * from v_content_summary limit 5;
