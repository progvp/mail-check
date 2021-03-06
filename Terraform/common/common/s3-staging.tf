
resource "aws_s3_bucket" "staging-aggregate-bucket" {
  bucket = "dmarcdata-staging-aggregate-reports"
  acl    = "private"
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [{
        "Sid": "GiveSESPermissionToWritAggregate",
        "Effect": "Allow",
        "Principal": {
          "Service": "ses.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::dmarcdata-staging-aggregate-reports/*",
        "Condition": {
          "StringEquals": {
            "aws:Referer": "${var.aws-account-id}"
          }
        }
    }]
}
EOF
  tags {
    Name = "Aggregate report emails delivered by SES"
  }
}

resource "aws_s3_bucket" "staging-forensic-bucket" {
  bucket = "dmarcdata-staging-forensic-reports"
  acl    = "private"
  policy =  <<EOF
{
    "Version": "2008-10-17",
    "Statement": [{
        "Sid": "GiveSESPermissionToWriteForensic",
        "Effect": "Allow",
        "Principal": {
          "Service": "ses.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::dmarcdata-staging-forensic-reports/*",
        "Condition": {
          "StringEquals": {
            "aws:Referer": "${var.aws-account-id}"
          }
        }
    }]
}
EOF
  tags {
    Name = "Forensic report emails delivered by SES"
  }
}







