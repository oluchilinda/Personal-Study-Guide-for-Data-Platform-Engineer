Cloud computing: the practice of using a network of remote servers hosted on the Internet to store, manage, and process data, rather than a local server or a personal computer.
Amazon Web Services is one of the largest providers in the cloud computing industry, and their services can be accessed in three different ways: 
1.the AWS Management Console, 
2. the Command Line Interface (CLI)
3. Software Development Kits (SDKs)

Provisioning Resources, basics steps
-  Create an AWS Account
The following steps below would be done with terraform
    - Create IAM role and select use case  Redshift - Customizable with Permissions (`AmazonS3ReadOnlyAccess`,
    `AmazonS3ReadOnlyAccess.`) and keep Access key ID and Secret access key
    - Create an IAM user (attached with IAM role created above) to access your Redshift cluster.
    - Create a VPC group
    - Create security group roles with inbound rules.
    - Launch a Redshift Cluster with compute resources such as memory, ec2 instances
    - Create an S3 bucket and upload your log data
    - Create a PostgreSQL DB Instance using RDS and apply resource configuration setting
    - Destroy all resources when no longer in use

Red Shift is SQL based , columnar and highly Massively parallel Processing(MPP)(parallelize the query on multi cpu nodes)
Each slice in a Redshift cluster is At least 1 CPU with dedicated storage and memory for the slice.
The total number of nodes in a Redshift cluster is equal to the number of AWS EC2 instances used in the cluster

![ETL AWS!](/images/ETL_cloud.png "ETL AWS")

A more advance and complex step 
![ETL AWS!](/images/ETL_advanced.png "ETL AWS")
