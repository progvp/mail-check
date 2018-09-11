resource "aws_ses_active_receipt_rule_set" "active" {
  rule_set_name = "TF-ses-ruleset"
}

resource "aws_ses_receipt_rule_set" "main-ses-ruleset" {
  rule_set_name = "TF-ses-ruleset" 
}

resource "aws_ses_receipt_rule" "staging-aggregate-ses-rule" {
  name          = "TF-staging-aggregate-ses-rule"
  rule_set_name = "TF-ses-ruleset"
  enabled       = true
  scan_enabled  = true
  recipients    = [ 
    "dmarc-rua@${var.report-staging-receiving-domain}"
  ]

  s3_action {
    bucket_name = "dmarcdata-staging-aggregate-reports"
    position    = "1"
  }
}

resource "aws_ses_receipt_rule" "staging-forensic-ses-rule" {
  name          = "TF-staging-forensic-ses-rule"
  rule_set_name = "TF-ses-ruleset"
  enabled       = true
  scan_enabled  = true
  recipients    = [ 
    "dmarc-ruf@${var.report-staging-receiving-domain}"
  ]

  s3_action {
    bucket_name =  "dmarcdata-staging-forensic-reports"
    position    = "1"
  }
}

resource "aws_ses_receipt_rule" "aggregate-ses-rule" {
  name          = "TF-aggregate-ses-rule"
  rule_set_name = "TF-ses-ruleset"
  enabled       = true
  scan_enabled  = true
  recipients    = [ 
    "dmarc-rua@${var.report-1st-receiving-domain}",
    "dmarc-rua@${var.report-2nd-receiving-domain}"
    
  ]

  s3_action {
    bucket_name = "dmarcdata-aggregate-reports"
    position    = "1"
  }
  s3_action {
    bucket_name = "dmarcdata-staging-aggregate-reports"
    position    = "2"
  }
}

resource "aws_ses_receipt_rule" "forensic-ses-rule" {
  name          = "TF-forensic-ses-rule"
  rule_set_name = "TF-ses-ruleset"
  enabled       = true
  scan_enabled  = true
  recipients    = [ 
    "dmarc-ruf@${var.report-1st-receiving-domain}",
    "dmarc-ruf@${var.report-2nd-receiving-domain}"

  ]

  s3_action {
    bucket_name =  "dmarcdata-forensic-reports"
    position    = "1"
  }
  s3_action {
    bucket_name =  "dmarcdata-staging-forensic-reports"
    position    = "2"
  }
}

resource "aws_ses_receipt_rule" "admin-ses-rule" {
  name          = "TF-admin-ses-rule"
  rule_set_name = "TF-ses-ruleset"
  enabled       = true
  scan_enabled  = true
  recipients    = [ 
    "admin@${var.report-1st-receiving-domain}",
    "admin@${var.report-2nd-receiving-domain}",
    "admin@${var.report-staging-receiving-domain}"
  ]

  s3_action {
    bucket_name =  "dmarcdata-admin-emails"
    position    = "1"
  }
}


