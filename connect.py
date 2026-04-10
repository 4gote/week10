import psycopg2
from psycopg2 import sql, OperationalError
from config import DB_CONFIG

def get_connection():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = False
        return conn
    except OperationalError as e:
        print(f"Database connection error: {e}")
        return None

def close_connection(conn):
    if conn:
        conn.close()

def execute_sql_file(conn, filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            sql_script = f.read()
        
        with conn.cursor() as cur:
            cur.execute(sql_script)
        conn.commit()
        print(f"Successfully executed: {filepath}")
    except Exception as e:
        conn.rollback()
        print(f"Error executing {filepath}: {e}")
