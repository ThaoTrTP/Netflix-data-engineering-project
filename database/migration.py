"""
Netflix Data Engineering Project
File: migration.py
Description: Load cleaned_netflix.csv into MySQL (netflix_db)
Run after schema.sql, before constraints.sql

Usage:
    cd database/
    python migration.py
"""
import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from urllib.parse import quote_plus
import unicodedata
# 0. Config

load_dotenv() # Read variants from file .env

DB_HOST = os.getenv('DB_HOST', '127.0.0.1')
DB_PORT = os.getenv('DB_PORT', '3306')
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = quote_plus(os.getenv('DB_PASSWORD', ''))
DB_NAME = os.getenv('DB_NAME', 'netflix_db')

DATABASE_URL = f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
DATA_PATH = "../data/processed/featured_netflix.csv"

# 1. Load CSV
def load_csv(path: str) -> pd.DataFrame:
    print(f"Loading CSV from {path}...")
    df = pd.read_csv(path, parse_dates=['date_added'])
    print(f"Loaded: {df.shape[0]:,} rows x {df.shape[1]} columns")
    return df

# 2. Insert title table
def insert_titles(df:pd.DataFrame, engine) -> None:
    print("\n[1/9] Inserting titles...")
    titles_cols = ['show_id', 'type', 'title', 'release_year', 'date_added',
                  'year_added', 'month_added', 'rating', 'duration', 'duration_minutes',
                  'duration_seasons', 'description', 'decade', 'content_age',
                  'movie_length_cat', 'days_to_add']

    titles_df = df[titles_cols].copy()
    titles_df.to_sql('titles', engine, if_exists='append', index=False, chunksize=500)
    print(f"Inserted: {len(titles_df):,} rows into titles")

# 3. Helper: insert lookup table & return name->id dict
def insert_lookup(values: pd.Series, table: str, id_col:str, name_col: str, engine) -> dict:
    """
    Slpit multi-value, deduplicate, insert into lookup table.
    Return a dict {name:id} using for insert into junctionn table.
    """
    # Split multi-value and get unique values
    unique_values = (
        values.dropna()
        .str.split(',')
        .explode()
        .str.strip()
        .apply(lambda x: unicodedata.normalize('NFC', x)) #Deduplicate'
        .str.title()
        .unique()
    )

    lookup_df = pd.DataFrame({name_col: unique_values})
    lookup_df.to_sql(table, engine, if_exists='append', index=False, chunksize=500)

    #Reread to get id that already created by AUTO_INCREMENT
    with engine.connect() as conn:
        result = conn.execute(text(f"SELECT {id_col}, {name_col} FROM {table}"))
        return {row[1] :row[0] for row in result}

# 4. Helper: insert junction table
def insert_junction(df:pd.DataFrame, source_col: str,
                    table: str, show_col: str, id_col: str,
                    name_to_id: dict, engine) -> None:
    """
    Create table from multi-value table and dict name-> id
    """
    rows = []
    for _, row in df[['show_id', source_col]].iterrows():
        if pd.isna(row[source_col]):
            continue
        for name in row[source_col].split(','):
            name = name.strip()
            if name in name_to_id:
                rows.append({
                    show_col : row['show_id'],
                    id_col : name_to_id[name]
                })
    
    junction_df = pd.DataFrame(rows).drop_duplicates()
    junction_df.to_sql(table, engine, if_exists='append', index=False, chunksize=500)
    print(f"Inserted: {len(junction_df):,} rows into {table}")

def truncate_tables(engine) -> None:
    """ Clear old data before rerun"""
    tables = [
        'title_genres', 'title_directors',
        'title_cast', 'title_countries',
        'titles', 'genres', 'directors',
        'cast_members', 'countries'
    ]
    print("\nTruncating existing data...")
    with engine.connect() as conn:
        conn.execute(text("SET FOREIGN_KEY_CHECKS = 0"))
        for table in tables:
            conn.execute(text(f"TRUNCATE TABLE {table}"))
            print(f" Cleared: {table}")
        conn.execute(text("SET FOREIGN_KEY_CHECKS = 1"))
        conn.commit()
# 5. Main

def main():
    print("="*50)
    print("Netflix Migration Script")
    print("="*50)

    # Connect to database
    engine = create_engine(DATABASE_URL, echo=False)
    print(f"\nConnected to: {DB_HOST}:{DB_PORT}/{DB_NAME}")
    truncate_tables(engine)
    # Load CSV
    df = load_csv(DATA_PATH)

    #[1] titles
    insert_titles(df, engine)

    #[2] genres + title_genres
    print("\n[2/9] Inserting genres...")
    genre_map = insert_lookup(df['listed_in'], 'genres', 'genre_id', 'genre_name', engine)
    print(f"  Inserted: {len(genre_map):,} unique genres")

    print("\n[3/9] Inserting title_genres...")
    insert_junction(df, 'listed_in', 'title_genres', 'show_id', 'genre_id', genre_map, engine)

    # [3] directors + title_directors
    print("\n[4/9] Inserting directors...")
    director_map = insert_lookup(df['director'], 'directors', 'director_id', 'director_name', engine)
    print(f"  Inserted: {len(director_map):,} unique directors")

    print("\n[5/9] Inserting title_directors...")
    insert_junction(df, 'director', 'title_directors', 'show_id', 'director_id', director_map, engine)

    # [4] cast_members + title_cast
    print("\n[6/9] Inserting cast_members...")
    cast_map = insert_lookup(df['cast'], 'cast_members', 'cast_id', 'cast_name', engine)
    print(f"  Inserted: {len(cast_map):,} unique cast members")

    print("\n[7/9] Inserting title_cast...")
    insert_junction(df, 'cast', 'title_cast', 'show_id', 'cast_id', cast_map, engine)

    # [5] countries + title_countries
    print("\n[8/9] Inserting countries...")
    country_map = insert_lookup(df['country'], 'countries', 'country_id', 'country_name', engine)
    print(f"  Inserted: {len(country_map):,} unique countries")

    print("\n[9/9] Inserting title_countries...")
    insert_junction(df, 'country', 'title_countries', 'show_id', 'country_id', country_map, engine)

    print("\n" + "=" * 50)
    print("Migration completed successfully!")
    print("Next step: run constraints.sql in MySQL Workbench")
    print("=" * 50)

if __name__ == "__main__":
    main()


