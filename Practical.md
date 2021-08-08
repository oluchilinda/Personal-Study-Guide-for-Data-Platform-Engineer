### HANDS ON EXPERIENCE
```shell
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
touch secrets.conf
```
secrets.json contains all your secrets eg, aws acess keys, s3 bucket ARN , please do not commit it to version control
Create an AWS Account and do with following below with terraform 

- Create IAM role and select use case  Redshift - Customizable with Permissions (`AmazonS3FullAccess`) and keep Access key ID and Secret access key
- Create an IAM user (attached with IAM role created above) to access your Redshift cluster.
- Create a VPC group
- Create security group roles with inbound rules.
- Launch a Redshift Cluster with compute resources such as memory, ec2 instances
- Create an S3 bucket and upload your log data
- Create a PostgreSQL DB Instance using RDS and apply resource configuration setting
- Destroy all resources when no longer in use

### Provisioning Infrastructure
Policies are JSON documents that define explicit allow/deny privileges to specific resources or resource groups.

There are advantages to managing IAM policies in Terraform rather than manually in AWS. With Terraform, you can reuse your policy templates and ensure the principle of least privilege with resource interpolation.
In the step below, I will create an IAM user and an S3 bucket. Then, I will map permissions for that bucket with an IAM policy. 
In upcoming steps I will attach add more complex policies. The files responsible for infrastructure provisioning are in `Iac_terraform`folders
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}


resource "aws_iam_user" "new_user" {
  name = var.iam_user
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

data "aws_iam_policy_document" "example" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.bucket.arn]
  }
}


resource "aws_iam_policy" "policy" {
  name        = "${random_pet.pet_name.id}_policy"
  description = "My test policy for datawarehouse in cloud"

  policy = data.aws_iam_policy_document.example.json

}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.new_user.name
  policy_arn = aws_iam_policy.policy.arn
}

```
```shell
terraform -version
```
Output:
```shell
Terraform v0.13.5

Your version of Terraform is out of date! The latest version
is 1.0.4. You can update by downloading from https://www.terraform.io/downloads.html
```
Export your access keys 
```shell
$ export AWS_ACCESS_KEY_ID="AK***************"
$ export AWS_SECRET_ACCESS_KEY="con***********************"
$ terraform init
$ terraform plan
$ terraform plan
```

Output:
```shell
<= data "aws_iam_policy_document" "example"  {
      + id   = (known after apply)
      + json = (known after apply)

      + statement {
          + actions   = [
              + "s3:ListAllMyBuckets",
            ]
          + resources = [
              + "arn:aws:s3:::*",
            ]
        }
      + statement {
          + actions   = [
              + "s3:*",
            ]
          + resources = [
              + (known after apply),
            ]
        }
    }

  # aws_iam_policy.policy will be created
  + resource "aws_iam_policy" "policy" {
      + arn         = (known after apply)
      + description = "My test policy for datawarehouse in cloud"
      + id          = (known after apply)
      + name        = "s3Policy"
      + path        = "/"
      + policy      = (known after apply)
      + policy_id   = (known after apply)
      + tags_all    = (known after apply)
    }

  # aws_iam_user.new_user will be created
  + resource "aws_iam_user" "new_user" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "oluchipractise"
      + path          = "/"
      + tags_all      = (known after apply)
      + unique_id     = (known after apply)
    }

  # aws_iam_user_policy_attachment.attachment will be created
  + resource "aws_iam_user_policy_attachment" "attachment" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + user       = "oluchipractise"
    }

  # aws_s3_bucket.bucket will be created
  + resource "aws_s3_bucket" "bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "oluchi-bucket-practise"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "Dev"
          + "Name"        = "My bucket"
        }
      + tags_all                    = {
          + "Environment" = "Dev"
          + "Name"        = "My bucket"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

```shell
pply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

rendered_policy = {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::oluchi-bucket-practise"
    }
  ]
}
```
Visit your AWS console ( web service), click on the iam user and download the security credentials
![AWS console!](/images/aws_console_iam.png "AWS console")

### Extracting Data from a MySQL Database
Extracting data from a MySQL database can be done in two ways:
- Full or incremental extraction using SQL : Full or incremental extraction using SQL is far simpler to implement,
but also less scalable for large datasets with frequent changes.
- Binary Log (binlog) replication : Binary Log replication, though more complex to implement, is better
suited to cases where the data volume of changes in source tables is
high, or there is a need for more frequent data ingestions from the
MySQL source.


First, you can install MySQL on your local machine or Alternatively, you can create a fully managed Amazon RDS for MySQL instance in AWS.
It’s free to set up and run! Just remember to destroy the resources `terraform destroy`so you don't incur charges.
For the sake of this tutorial and financial cost, I would use my local system
I will populate it using the following example data available on MySQL (docs)[https://dev.mysql.com/doc/index-other.html]
```text
The Sakila sample database is made available by MySQL and is licensed via the New BSD license. Sakila contains data for a fictitious movie rental company and includes tables such as store, inventory, film, customer, and payment. 
```
#### Setting up mysql mac 
```shell
brew install mysql
mysql_secure_installation
brew services start mysql
mysql -u root -p
SOURCE /path_folder/Downloads/sakila-db/sakila-schema.sql;
SOURCE /path_folder/Downloads/sakila-db/sakila-data.sql;
USE sakila;
SHOW FULL TABLES;
```

Output:
```shell
mysql> SHOW FULL TABLES;
+----------------------------+------------+
| Tables_in_sakila           | Table_type |
+----------------------------+------------+
| actor                      | BASE TABLE |
| actor_info                 | VIEW       |
| address                    | BASE TABLE |
| category                   | BASE TABLE |
| city                       | BASE TABLE |
| country                    | BASE TABLE |
| customer                   | BASE TABLE |
| customer_list              | VIEW       |
| film                       | BASE TABLE |
| film_actor                 | BASE TABLE |
| film_category              | BASE TABLE |
| film_list                  | VIEW       |
| film_text                  | BASE TABLE |
| inventory                  | BASE TABLE |
| language                   | BASE TABLE |
| nicer_but_slower_film_list | VIEW       |
| payment                    | BASE TABLE |
| rental                     | BASE TABLE |
| sales_by_film_category     | VIEW       |
| sales_by_store             | VIEW       |
| staff                      | BASE TABLE |
| staff_list                 | VIEW       |
| store                      | BASE TABLE |
+----------------------------+------------+
```

```python

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

access_key = secret[ "root_AWSAccessKeyId"]
secret_key = secret[ "root_AWSSecretKey"]
bucket_name = secret["bucket_name"]

s3 = boto3.client('s3', aws_access_key_id=access_key, aws_secret_access_key=secret_key)

s3_file = local_filename

s3.upload_file(local_filename, bucket_name, s3_file)

```


<!-- Boto3 is the AWS SDK for Python would be installed with pip. -->