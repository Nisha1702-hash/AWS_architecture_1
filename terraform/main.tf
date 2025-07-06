resource "aws_sqs_queue" "main_queue_nisha" {
  name = "main-queue-nisha"
}

resource "aws_sqs_queue" "dlq_nisha" {
  name = "main-dlq-nisha"
}

resource "aws_sqs_queue_redrive_policy" "redrive_policy_nisha" {
  queue_url      = aws_sqs_queue.main_queue_nisha.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_nisha.arn
    maxReceiveCount     = 5
  })
}

// ...existing code...

# Additional SQS queues for fan-out
resource "aws_sqs_queue" "fanout_queue_1" {
  name = "fanout-queue-1-nisha"
}

resource "aws_sqs_queue" "fanout_queue_2" {
  name = "fanout-queue-2-nisha"
}

# Subscribe both new queues to the SNS topic
resource "aws_sns_topic_subscription" "sns_to_fanout_queue_1" {
  topic_arn = aws_sns_topic.notifications_nisha.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.fanout_queue_1.arn
}

resource "aws_sns_topic_subscription" "sns_to_fanout_queue_2" {
  topic_arn = aws_sns_topic.notifications_nisha.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.fanout_queue_2.arn
}

# (Optional) Lambda functions for each fan-out queue
resource "aws_lambda_function" "process_fanout_queue_1" {
  filename         = "../lambda.zip"
  function_name    = "process-fanout-queue-1-nisha"
  role             = aws_iam_role.lambda_role_nisha.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("../lambda.zip")
}

resource "aws_lambda_event_source_mapping" "lambda_fanout_queue_1" {
  event_source_arn = aws_sqs_queue.fanout_queue_1.arn
  function_name    = aws_lambda_function.process_fanout_queue_1.arn
  batch_size       = 5
}

resource "aws_lambda_function" "process_fanout_queue_2" {
  filename         = "../lambda.zip"
  function_name    = "process-fanout-queue-2-nisha"
  role             = aws_iam_role.lambda_role_nisha.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("../lambda.zip")
}

resource "aws_lambda_event_source_mapping" "lambda_fanout_queue_2" {
  event_source_arn = aws_sqs_queue.fanout_queue_2.arn
  function_name    = aws_lambda_function.process_fanout_queue_2.arn
  batch_size       = 5
}

// ...existing code...

resource "aws_sns_topic" "notifications_nisha" {
  name = "notifications-topic-nisha"
}

resource "aws_sns_topic_subscription" "sns_to_sqs_nisha" {
  topic_arn = aws_sns_topic.notifications_nisha.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.main_queue_nisha.arn
}

resource "aws_iam_role" "lambda_role_nisha" {
  name = "lambda-role-nisha"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_nisha" {
  role       = aws_iam_role.lambda_role_nisha.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sqs_access_nisha" {
  name = "lambda-sqs-access-nisha"
  role = aws_iam_role.lambda_role_nisha.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = [
          aws_sqs_queue.main_queue_nisha.arn,
          aws_sqs_queue.fanout_queue_1.arn,
          aws_sqs_queue.fanout_queue_2.arn
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "process_messages_nisha" {
  filename         = "../lambda.zip"
  function_name    = "process-messages-nisha"
  role             = aws_iam_role.lambda_role_nisha.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("../lambda.zip")
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_nisha" {
  event_source_arn = aws_sqs_queue.main_queue_nisha.arn
  function_name    = aws_lambda_function.process_messages_nisha.arn
  batch_size       = 5
}

resource "aws_lambda_permission" "allow_sns_nisha" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_messages_nisha.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.notifications_nisha.arn
}