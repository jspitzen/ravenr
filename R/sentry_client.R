.sentry <- new.env()

#' Create Sentry Client
#'
#' \code{create_sentry_client} Creates a sentry client
#'
#' @param dsn set Data Source Name
#' @param user set user context
#' @param version protocol version
#' @param log_errors whether to send errors to sentry
#' @param log_warnings whether to send warnings to sentry
#'
#' @export
create_sentry_client <- function(dsn, user = NULL, version = NULL, log_errors = TRUE, log_warnings = TRUE) {
  if (is.null(version))
    version <- 7

  url <- httr::parse_url(dsn)

  client <- structure(
    list(
      dsn = dsn,
      auth = list(
        sentry_version = version,
        sentry_client = paste("ravenr", getNamespaceVersion("ravenr"), sep = "/"),
        sentry_timestamp = as.integer(Sys.time()),
        sentry_key = url$username,
        sentry_secret = url$password
      )
    ),
    class = "sentry"
  )

  if (!is.null(user))
    client$user <- user

  url$username <- NULL
  url$password <- NULL
  url$path <- file.path("api", url$path, "store")

  client$url <- httr::build_url(url)
  client$url <- paste0(client$url, "/")
  assign("sentry_client", client, envir = .sentry)

  if (log_errors) {
    options(error = quote({capture_error()}))
  }
  if (log_warnings) {
    options(warning.expression = quote({capture_warning()}))
  }
  # initialize empty list of tags
  assign("tags", list(), envir = .sentry)

  invisible(client)
}

#' Set tags for sentry, will be added to future sentry logs
#'
#' @param tags named arguments with key, value combinations of tags. existing tags will be overwritten
#'
#' @export
set_tags <- function(...) {
  tags <- get("tags", envir = .sentry)
  new_tags <- list(...)
  for (tag_key in names(new_tags)) {
    tags[[tag_key]] <- new_tags[[tag_key]]
  }
  assign("tags", tags, envir = .sentry)
}

