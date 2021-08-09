
import csv
import os

import boto3
import pymysql
import json

f = open('secrets.json')
secret = json.load(f)


hostname = secret["sql_hostname"]
port = secret["sql_port"]
username = secret["sql_username"]
dbname = secret["sql_database"]
password = secret["sql_password"]

conn = pymysql.connect(host=hostname,
        user=username,
        password=password,
        db=dbname,
        port=int(port))

if conn is None:
  print("Error connecting to the MySQL database")
else:
  print("MySQL connection established!")

# Calculate the total revenues generated from PG-rated film rentals where the cast includes an actor whose last name starts with S. 
m_query = """ 
    WITH actors_s AS
 (SELECT actor_id, first_name, last_name
 FROM actor
 WHERE last_name LIKE 'S%'
 ),
 actors_s_pg AS
 (SELECT s.actor_id, s.first_name, s.last_name,
 f.film_id, f.title
 FROM actors_s s
 INNER JOIN film_actor fa
 ON s.actor_id = fa.actor_id
 INNER JOIN film f
 ON f.film_id = fa.film_id
 WHERE f.rating = 'PG'
 ),
 actors_s_pg_revenue AS
 (SELECT spg.first_name, spg.last_name, p.amount
 FROM actors_s_pg spg
 INNER JOIN inventory i
 ON i.film_id = spg.film_id
 INNER JOIN rental r
 ON i.inventory_id = r.inventory_id
 INNER JOIN payment p
 ON r.rental_id = p.rental_id
 ) -- end of With clause
 SELECT spg_rev.first_name, spg_rev.last_name,
 sum(spg_rev.amount) tot_revenue
 FROM actors_s_pg_revenue spg_rev
 GROUP BY spg_rev.first_name, spg_rev.last_name
 ORDER BY 3 desc;
"""


local_filename = "total_revenue_PG.csv"


m_cursor = conn.cursor()
m_cursor.execute(m_query)
results = m_cursor.fetchall()

with open(local_filename, 'w') as fp:
  csv_w = csv.writer(fp, delimiter='|')
  csv_w.writerows(results)

fp.close()
m_cursor.close()
conn.close()

# load the aws_boto_credentials values

access_key = secret[ "access_keys"]
secret_key = secret[ "secret_keys"]
bucket_name = secret["bucket_name"]

s3 = boto3.client('s3', aws_access_key_id=access_key, aws_secret_access_key=secret_key)

s3_file = local_filename

s3.upload_file(local_filename, bucket_name, s3_file)

