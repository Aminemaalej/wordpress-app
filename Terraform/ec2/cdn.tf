resource "aws_wafv2_web_acl" "waf_acl" {
  provider    = aws.useast1
  name        = "wordpress-waf-acl"
  scope       = "CLOUDFRONT"
  description = "Wordpress WAF ACL"

  default_action {
    allow {}
  }

  rule {
    name     = "GeoRestrictionRule"
    priority = 1

    statement {
      geo_match_statement {
        country_codes = ["US", "CA", "IE", "SG"] # Allow traffic only from the US, Canada, Ireland and Singapore
      }
    }

    action {
      block {}
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "geo-restriction-metric"
    }
  }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-wordpress-acl"
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_lb.wordpress_lb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "IE", "SG"] # Allow only the US, Canada, Ireland, and Singapore
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = aws_wafv2_web_acl.waf_acl.arn
}