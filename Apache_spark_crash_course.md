There are many other big data tools and systems, each with its own use case. There are database system like
-  Apache Cassandra 
-  SQL query engines like Presto
- Spark which is still one of the most popular tools for analyzing large data sets.


Key hardware components.

- CPU (Central Processing Unit)
The CPU is the "brain" of the computer. Every process on your computer is eventually handled by your CPU. This includes calculations and also instructions for the other components of the compute.
A 2.5 Gigahertz CPU means that the CPU processes 2.5 billion operations per second. Let's say that for each operation, the CPU processes 8 bytes of data. How many bytes could this CPU process per second? (20 billion bytes per second)

- Memory (RAM)
When your program runs, data gets temporarily stored in memory before getting sent to the CPU. Memory is ephemeral storage - when your computer shuts down, the data in the memory is lost.

- Storage (SSD or Magnetic Disk)
Storage is used for keeping data over long periods of time. When a program runs, the CPU will direct the memory to temporarily load data from long-term storage.

- Network (LAN or the Internet)
Network is the gateway for anything that you need that isn't stored on your computer. The network could connect to other computers in the same room (a Local Area Network) or to a computer on the other side of the world, connected over the internet.

![Hardware!](/images/Hardware.png "Hardware")

#### HADOOP ECOSYSTEM

Hadoop - an ecosystem of tools for big data storage and data analysis. Hadoop is an older system than Spark but is still used by many companies. The major difference between Spark and Hadoop is how they use memory. Hadoop writes intermediate results to disk whereas Spark tries to keep data in memory whenever possible. This makes Spark faster for many use cases.


###### Components of Hadoop
- Hadoop MapReduce - a system for processing and analyzing large data sets in parallel.
MapReduce is a programming technique for manipulating large data sets. "Hadoop MapReduce" is a specific implementation of this programming technique.
The technique works by first dividing up a large dataset and distributing the data across a cluster. In the map step, each data is analyzed and converted into a (key, value) pair. Then these key-value pairs are shuffled across the cluster so that all keys are on the same machine. In the reduce step, the values with the same keys are combined together.
While Spark doesn't implement MapReduce, you can write Spark programs that behave in a similar way to the map-reduce paradigm. 

- Hadoop YARN - a resource manager that schedules jobs across a cluster. The manager keeps track of what computer resources are available and then assigns those resources to specific tasks.
- Hadoop Distributed File System (HDFS) - a big data storage system that splits data into chunks and stores the chunks across a cluster of computers.

As Hadoop matured, other tools were developed to make Hadoop easier to work with. These tools included:

    - Apache Pig - a SQL-like language that runs on top of Hadoop MapReduce
    - Apache Hive - another SQL-like interface that runs on top of Hadoop MapReduce

#### Why Spark instead of Hadoop
Spark contains libraries for data analysis, machine learning, graph analysis, and streaming live data. Spark is generally faster than Hadoop. This is because Hadoop writes intermediate results to disk whereas Spark tries to keep intermediate results in memory whenever possible.

The Hadoop ecosystem includes a distributed file storage system called HDFS (Hadoop Distributed File System). Spark, on the other hand, does not include a file storage system. You can use Spark on top of HDFS but you do not have to. Spark can read in data from other sources as well such as Amazon S3.

##### Streaming Data
Data streaming is a specialized topic in big data. The use case is when you want to store and analyze data in real-time such as Facebook posts or Twitter tweets.
Spark has a streaming library called Spark Streaming although it is not as popular and fast as some other streaming libraries. Other popular streaming libraries include Storm and Flink. 


#### Spark Mode
When you are working with Spark installed on your own laptop, you use local mode but on a cluster, you maybe be using Standalone, YARN, or Mesos
![Spark_mode!](/images/Spark_mode.png "Spark_mode")

#### Use cases for Spark
- Data Analytics
- Machine Learning
- Streaming
- Graph Analytics

#### When not to use Spark
Spark is meant for big data sets that cannot fit on one computer. But you don't need Spark if you are working on smaller data sets. In the cases of data sets that can fit on your local computer, there are many other options out there you can use to manipulate data such as:

- AWK - a command line tool for manipulating text files
- R - a programming language and software environment for statistical computing
- Python PyData Stack, which includes pandas, matplotlib, numpy, and scikit-learn among other libraries
Sometimes, you can still use pandas on a single, local machine even if your data set is only a little bit larger than memory. Pandas can read data in chunks. Depending on your use case, you can filter the data and write out the relevant parts to disk.

If the data is already stored in a relational database such as MySQL or Postgres, you can leverage SQL to extract, filter and aggregate the data. If you would like to leverage pandas and SQL simultaneously, you can use libraries such as SQLAlchemy, which provides an abstraction layer to manipulate SQL tables with generative Python expressions.

The most commonly used Python Machine Learning library is scikit-learn. It has a wide range of algorithms for classification, regression, and clustering, as well as utilities for preprocessing data, fine tuning model parameters and testing their results.


##### Spark's Limitations
Spark has some limitation.

- Spark Streaming’s latency is at least 500 milliseconds since it operates on micro-batches of records, instead of processing one record at a time. Native streaming tools such as Storm, Apex, or Flink can push down this latency value and might be more suitable for low-latency applications. Flink and Apex can be used for batch computation as well, so if you're already using them for stream processing, there's no need to add Spark to your stack of technologies.

- Another limitation of Spark is its selection of machine learning algorithms. Currently, Spark only supports algorithms that scale linearly with the input data size. In general, deep learning is not available either, though there are many projects integrate Spark with Tensorflow and other deep learning tools.


##### Data Wrangling with Spark
Under the hood, spark is written in a programming langauage called scala, other it is written in scala, you can use it in other language such as Python , R or Java
![Dag!](/images/Dag.png "Dag")



###### Sources
1. [Udacity Nanodegree for Data Engineering](https://www.udacity.com/course/data-engineer-nanodegree--nd027)
