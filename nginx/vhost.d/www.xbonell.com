# Redirect www to non-www canonical URLs in one hop

# Root URL: apply language redirect and canonical host at once
location = / {
    if ($http_accept_language ~* ^ca) {
        return 301 https://xbonell.com/ca/;
    }
    if ($http_accept_language ~* ^es) {
        return 301 https://xbonell.com/es/;
    }
    if ($http_accept_language ~* ^en) {
        return 301 https://xbonell.com/en/;
    }
    return 301 https://xbonell.com/es/;
}

# Add trailing slash for section-like URLs while switching to canonical host
# Excludes file-like URLs with an extension (e.g. .css, .png, .xml)
location ~ ^/.+[^/]$ {
    if ($uri !~ \.[^/]+$) {
        return 301 https://xbonell.com$uri/$is_args$args;
    }
    return 301 https://xbonell.com$uri$is_args$args;
}

# Fallback: canonicalize host for all remaining requests
location / {
    return 301 https://xbonell.com$request_uri;
}
