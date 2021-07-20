##### DATA ENGINEERING

Data engineering is the development, operation, and maintenance of data infrastructure, either on-premises or in the   cloud (or hybrid or multi-cloud),comprising databases and pipelines to extract, transform, and load data.

At the lowest level, data engineering involves the movement of data from one system or
format to another system or format. 
Data engineers query data from a source (extract), they perform some modifications to the data (transform),and then they put that data in a location where users can access it and know that it is in production quality (load). 
The combination of extracting, loading, and transforming data is accomplished by the creation of a data pipeline.

Typical scenario why we need a data engineer

An online store eg Fenty beauty  has a website where you can purchase different shades of foundations . The
website is backed by a relational database. Every transaction is stored in the database. 
The site grows and running queries on the production database is no longer practical, and they are various database that records site purchases in different geographical location e.g Asia, Europe, Africa, North America etc

##### The executives or sales representatives could ask,

How many *PRO FILT'R HYDRATING LONGWEAR FOUNDATION in shade (#110, #490, #150, #160 , #255)* were sold in  the last quarter?


To answer the preceding question,a data engineer would create connections to all of the transactional databases for each region, extract the data, and load it into a data warehouse. 

From there, you could now count the number of PRO FILT'R HYDRATING LONGWEAR FOUNDATION in shade (#110, #490, #150, #160 , #255) that were sold and answer further questions such as
- Which geographical location sold the most foundation products.
- The peak times when these products are purchased in large volumes.
- How many users added these products to their cart and later removed them.


#### The three Vs of big data:
- Volume: The volume of data has grown substantially. Moving a thousand records from a database requires different tools and techniques than moving millions of rows or handling millions of transactions a minute.
- Variety: Data engineers need tools that handle a variety of data formats in different locations (databases, APIs, files).
- Velocity: The velocity of data is always increasing. Tracking the activity of millions of users on a social network or the purchases of users all over the world requires data engineers to operate often in near real time.


### Tools
1. Programming language : Python
2. Databases : MySQL and PostgresSQL
3. Databases for Data warehousing :   Amazon Redshift, Google BigQuery, Apache Cassandra,  Elasticsearch.
4. Data processing engines : allow data engineers to transform data whether it is in batches or streams. These engines allow the parallel execution of transformation tasks. The most popular engine is Apache Spark, Apache Kafka
5. Data pipelines :Combining a transactional database, a programming language, a processing engine, and a data warehouse results in a pipeline. 
Data pipelines need a scheduler to allow them to run at specified intervals. The simplest way to
accomplish this is by using crontab. Schedule a cron job for your Python file and sit back
and watch it run every X number of hours.
The most popular framework for building data engineering pipelines in Python is Apache
Airflow. Airflow is a workflow management platform built by Airbnb. Airflow is made
up of a web server, a scheduler, a metastore, a queueing system, and executors. You can
run Airflow as a single instance, or you can break it up into a cluster with many executor
nodes – this is most likely how you would run it in production. Airflow uses Directed Acyclic Graphs (DAGs)

    - A DAG is Python code that specifies tasks. A graph is a series of nodes connected by a
    relationship or dependency. In Airflow, they are directed because they flow in a direction
    with each task coming after its dependency.

    - Apache NiFi
    Apache NiFi is another framework for building data engineering pipelines, and it too
    utilizes DAGs. Apache NiFi was built by the National Security Agency and is used
    at several federal agencies. Apache NiFi is easier to set up and is useful for new data
    engineers. 


