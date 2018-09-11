
resource "aws_s3_bucket" "aggregate-bucket" {
  bucket = "dmarcdata-aggregate-reports"
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
        "Resource": "arn:aws:s3:::dmarcdata-aggregate-reports/*",
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

resource "aws_s3_bucket" "forensic-bucket" {
  bucket = "dmarcdata-forensic-reports"
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
        "Resource": "arn:aws:s3:::dmarcdata-forensic-reports/*",
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

resource "aws_s3_bucket" "admin-bucket" {
  bucket = "dmarcdata-admin-emails"
  acl    = "private"
  policy =  <<EOF
{
    "Version": "2008-10-17",
    "Statement": [{
        "Sid": "GiveSESPermissionToWriteAdmin",
        "Effect": "Allow",
        "Principal": {
          "Service": "ses.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::dmarcdata-admin-emails/*",
        "Condition": {
          "StringEquals": {
            "aws:Referer": "${var.aws-account-id}"
          }
        }
    }]
}
EOF
  tags {
    Name = "Admin emails delivered by SES - domain validation"
  }
}






