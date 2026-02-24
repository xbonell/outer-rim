# Redirect www to non-www (canonical domain)
# This prevents duplicate content issues and consolidates SEO value
# Using server-level if to redirect before location blocks are processed
if ($host = www.bgespecialitats.com) {
    return 301 https://bgespecialitats.com$request_uri;
}
