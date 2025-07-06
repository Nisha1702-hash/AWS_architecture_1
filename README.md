# AWS Serverless Event-Driven Architecture

This project provisions a serverless event-driven architecture on AWS using Terraform. It sets up an SNS + SQS + Lambda ecosystem for scalable and decoupled message processing.

---

## 🚀 Architecture Overview

             +-------------------+
             |    SNS Topic      |
             +---------+---------+
                       |
   +-------------------+-------------------+
   |                   |                   |
+---------------+ +---------------+ +---------------+
| Main SQS | | Fanout SQS 1 | | Fanout SQS 2 |
| Queue | | | | |
+-------+-------+ +-------+-------+ +-------+-------+
| | |
+-------v-------+ +-------v-------+ +-------v-------+
| Main Lambda | | Lambda Fanout | | Lambda Fanout |
| Processor | | Processor 1 | | Processor 2 |
+---------------+ +---------------+ +---------------+
|
+-------------------+
| Dead Letter Queue |
+-------------------+


### 📚 Key Components
- **SNS Topic:** Publishes notifications to multiple subscribers.
- **Main SQS Queue:** Receives messages from SNS, with a DLQ for failures.
- **Fanout SQS Queues:** Two additional queues subscribed to SNS for parallel processing.
- **Lambda Functions:** Process messages from each SQS queue.
- **IAM Roles & Policies:** Grant Lambda functions necessary permissions.

---

## 🏗 Resources Created

| Resource                            | Description                                 |
|-------------------------------------|---------------------------------------------|
| `aws_sns_topic`                     | Notification topic to publish events        |
| `aws_sqs_queue`                     | Main queue + fanout queues + DLQ            |
| `aws_sqs_queue_redrive_policy`      | Configures DLQ for the main queue           |
| `aws_sns_topic_subscription`        | Links SNS to all SQS queues                 |
| `aws_lambda_function`               | Processes messages from each queue         |
| `aws_lambda_event_source_mapping`   | Connects SQS queues to Lambda triggers     |
| `aws_iam_role` & `policy`           | Lambda execution & SQS permissions          |

---

## ⚙ Usage

### 1️⃣ Prerequisites
- [Terraform](https://www.terraform.io/downloads) >= 1.3
- AWS CLI configured with appropriate credentials (`aws configure`)
- An S3 bucket (optional) if you want to store Terraform state remotely.

### 2️⃣ Initialize Terraform
```bash
terraform init
