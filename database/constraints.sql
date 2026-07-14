-- =============================================================
-- Netflix Data Engineering Project
-- File: constraints.sql
-- Description: Add constraints and indexes
-- Run AFTER schema.sql and migration.py
-- =============================================================
use netflix_db;

-- =============================================================
-- PHASE 1: Check the duplicated before add unique constraint
-- Run each block SELECt, check result first then continue
-- The results must be empty tables, then run Phase 2
-- =============================================================
-- 1.1 Check the duplicated in genres
select genre_name, count(*) as count
from genres
group by genre_name
having count(*) > 1
order by count desc;
-- Expected result: empty

-- 1.2 Check the duplicated in directors
select director_name, count(*) as count
from directors
group by director_name
having count(*) > 1
order by count desc;
-- Expected result: empty

-- 1.3 Check the duplicated in cast_members
select cast_name, count(*) as count
from cast_members
group by cast_name
having count(*) > 1
order by count desc;
-- Expected result: empty

-- 1.4 Check the duplicated in countries
select country_name, count(*) as count
from countries
group by country_name
having count(*) > 1
order by count desc;
-- =============================================================
-- PHASE 1B: Handle the duplicated if any (in PHASE 1)
-- Delete row which have id greater (insert later on), keep the first row
-- =============================================================
set sql_safe_updates = 0;

-- Delete the duplicated directors (if 1.2 is not an empty table)
delete from directors
where director_id in (
	select delete_id from (
		select max(director_id) as delete_id
        from directors
        group by director_name
        having count(*) > 1
    ) tmp
);

-- Run again and again if have any name appear more than 3 times
delete from directors
where director_id in (
	select delete_id from (
		select max(director_id) as delete_id
        from directors
        group by director_name
        having count(*) > 1
    ) tmp
);

-- Delete the duplicated cast_members (if 1.3 is not an empty table)
delete from cast_members
where cast_id in (
	select delete_id from (
		select max(cast_id) as delete_id
        from cast_members
        group by cast_name
        having count(*) > 1
        ) tmp
);
-- Run again and again if have any name appear more than 3 times
delete from cast_members
where cast_id in (
	select delete_id from (
		select max(cast_id) as delete_id
        from cast_members
        group by cast_name
        having count(*) > 1
        ) tmp
);

set sql_safe_updates = 1;

-- =============================================================
-- PHASE 1C: Process orphna records in junction tables
-- After delete duplicate lookup, junction tables can contain
-- cast_id/ director_id aren't existed anymore -> need to clear up before add FK
-- =============================================================
-- Check orphan
select count(*) as orphan_cast
from title_cast tc
left join cast_members cm on tc.cast_id = cm.cast_id
where cm.cast_id is null;

select count(*) as orphan_director
from title_directors td
left join directors d on td.director_id = d.director_id
where d.director_id is null;

-- delete orphan if existed
set sql_safe_updates = 0;

delete from title_cast
where cast_id not in (select cast_id from cast_members);

delete from title_directors
where director_id not in (select director_id from directors);

set sql_safe_updates = 1;
-- =============================================================
-- PHASE 2: Unique constraints on lookup tables
-- =============================================================

alter table genres
	add constraint uq_genre_name
		unique (genre_name);

alter table directors
	 add constraint uq_director_name
		unique (director_name);

alter table cast_members
	add constraint uq_cast_name
		unique (cast_name);
        
alter table countries
	add constraint uq_country_name
		unique (country_name);
        
-- =============================================================
-- PHASE 3: Check constraint on titles
-- =============================================================

alter table titles
	add constraint chk_type
		check (type in ('Movie', 'TV Show')),
	
    add constraint chk_release_year
		check (release_year between 1900 and 2030),
	
    add constraint chk_month_added
		check (month_added between 1 and 12 
			or month_added is null),
	
    add constraint chk_duration_minutes
		check (duration_minutes > 0
			or duration_minutes is null),
            
	add constraint chk_duration_seasons
		check (duration_seasons > 0
			or duration_seasons is null);
            
-- =============================================================
-- PHASE 4: Foreign key constraint
-- =============================================================

alter table title_genres
	add constraint fk_tg_show
		foreign key (show_id) references titles(show_id)
        on delete cascade on update cascade,
	add constraint fk_tg_genre
		foreign key (genre_id) references genres(genre_id)
        on delete cascade on update cascade;
        
alter table title_directors
	add constraint fk_td_show
		foreign key (show_id) references titles(show_id)
        on delete cascade on update cascade,
	add constraint fk_td_director
		foreign key (director_id) references directors(director_id)
        on delete cascade on update cascade;
        
alter table title_cast
	add constraint fk_tc_show
		foreign key (show_id) references titles(show_id)
        on delete cascade on update cascade,
	add constraint fk_tc_cast
		foreign key (cast_id) references cast_members(cast_id)
        on delete cascade on update cascade;
        
alter table title_countries
	add constraint fk_tcn_show
		foreign key (show_id) references titles(show_id)
        on delete cascade on update cascade,
	add constraint fk_tcn_country
		foreign key (country_id) references countries(country_id)
        on delete cascade on update cascade;
        
-- =============================================================
-- PHASE 5: Indexes
-- =============================================================

create index idx_titles_type on titles(type);
create index idx_titles_year on titles(release_year);
create index idx_titles_year_added on titles(year_added);
create index idx_titles_rating on titles(rating);
create index idx_titles_decade on titles(decade);
-- =============================================================
-- PHASE 6: Verify 
-- =============================================================
-- 6.1 All created constraints
select
	constraint_name,
    constraint_type,
    table_name
from information_schema.table_constraints
where table_schema = 'netflix_db'
	and constraint_type != 'primary key'
order by table_name, constraint_type;

-- 6.2 FK relationships
select
	table_name,
    constraint_name,
    referenced_table_name
from information_schema.referential_constraints
where constraint_schema = 'netflix_db'
order by table_name;

-- 6.3 Indexes
select
	table_name,
    index_name,
    column_name
from information_schema.statistics
where table_schema = 'netflix_db'
	and index_name != 'primary'
order by table_name, index_name;

-- 6.4 Row counts
select 'titles' as table_name, count(*) as row_count from titles
union all
select 'genres', count(*) from genres
union all
select 'directors', count(*) from directors
union all
select 'cast_members', count(*) from cast_members
union all
select 'countries', count(*) from countries
union all
select 'title_genres', count(*) from title_genres
union all
select 'title_directors', count(*) from title_directors
union all
select 'title_cast', count(*) from title_cast
union all
select 'title_countries', count(*) from title_countries;
