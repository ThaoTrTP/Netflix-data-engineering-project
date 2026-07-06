-- =====================================================================
-- Netflix Data Engineering Project
-- File schema.sql
-- Description: Create database and all tables
-- Engine: MySQL 8.0+
-- Run this file before constraints.sql and migration.py

-- 0.Database
create database if not exists netflix_db
	character set utf8mb4
    collate utf8mb4_unicode_ci;
    
use netflix_db;

-- 1. Core entity tables
create table if not exists titles (
	show_id varchar(10) not null,
    type varchar(10) not null,  
    title varchar(255) not null,
    release_year smallint not null,
    date_added date null,
    year_added smallint null,
    month_added tinyint null,
    rating varchar(20) null,
    duration varchar(20) null,
    duration_minutes smallint null,
    duration_seasons tinyint null,
    description text null,
    decade smallint null,
    content_age varchar(30) null,
    movie_length_cat varchar(30) null,
    days_to_add int null,
    primary key (show_id)
);

create table if not exists genres (
	genre_id int not null auto_increment,
    genre_name varchar(100) not null,
    primary key (genre_id)
);

create table if not exists directors (
	director_id int not null auto_increment,
    director_name varchar(255) not null,
    primary key (director_id)
);

create table if not exists cast_members (
	cast_id int not null auto_increment,
    cast_name varchar(255) not null,
    primary key (cast_id)
);

create table if not exists countries (
	country_id int not null auto_increment,
    country_mame varchar(100) not null,
    primary key (country_id)
);

-- 2. Junction tables (many-to-many)
create table if not exists title_genres (
	show_id varchar(10) not null,
    genre_id int not null,
    primary key (show_id, genre_id)
);

create table if not exists title_directors (
	show_id varchar(10) not null,
    director_id int not null,
    primary key (show_id, director_id)
);

create table if not exists title_cast (
	show_id varchar(10) not null,
    cast_id int not null,
    primary key (show_id, cast_id)
);

create table if not exists title_countries (
	show_id varchar(10) not null,
    country_id int not null,
    primary key (show_id, country_id)
);