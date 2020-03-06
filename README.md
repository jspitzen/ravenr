# ravenr
[![Build Status](https://travis-ci.org/jspitzen/ravenr.svg?branch=master)](https://travis-ci.org/jspitzen/ravenr)

A Sentry client for R

## Introduction
Ravenr is a library which allows the user to log errors and warnings to Sentry and have a better overview of them. This package makes easier to log those errors and it only has to be setup in the beginnig of the project. This package doesn't work with logging errors which are within a TryCatch function. If the user does want to capture those errors, the user can use the function try_catch_log. 

## Installation
Install this package directly from GitHub using DevTools:
`devtools::install_github('jspitzen/ravenr')`

## Usage
To send your exceptions to Sentry, you'll need a DSN for your Sentry installation and then set up `ravenr` like this:

```
library(ravenr)
dsn <- '<< your DSN >>'
sentry_client(dsn)
non_existing_function(-1)
```

This will report 'Could not find "non_existing function"' to sentry, along with information about the system executing the code and installed packages.

In case there are multiple users in the project a user name can be added as a input in the function as:

```
sentry <- sentry_client(dsn, user = list('<<username>>'))
```

### Customizing tags
To group your error reports better, you can specify tags in your code as follows:

```
sentry_client(dsn)
set_tags(subgroup = "abc")
non_existing_function(-1)
```
### Log errors in a TryCatch
A standard TryCatch will not log the errors and warnings in Sentry. In the case the user does want to have those errors logged, the function try_catch_log can be used. This fucntion has the following structure:

```
try_catch_log({
  non_existing_function(-1)
  TRUE
}, error = function(e) {
  error_message <- paste0("in running function log: ", e$message)
  FALSE
},
tags = list("test_time" = 1)
)
```
This function does not print the error in the console, only sends it to Sentry. 
