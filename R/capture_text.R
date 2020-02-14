#' Capture Text
#'
#' \code{capture_text} Captures text and sends it to Sentry
#'
#' @param object A Sentry client
#' @param text text to send
#' @param extra set extra context
#' @param level set level, warning or error for example
#' @param tags named list of tags
#' @param include_session_info whether to send platform and package list, takes up to 1s or more
#' @param exception list containing `type` and `value` describing the exception
#'
#' @export
capture_text <- function(text = NULL, extra = NULL, level = "error", tags = NULL, include_session_info = TRUE, exception = NULL) {
  object <-  get("sentry_client", envir = .sentry)
  if (is.null(text)) {
    if (!is.null(exception)) {
      text <- exception$value
    } else {
      text <- "unspecified"
    }
  }

  required_attributes <- list(
    timestamp = strftime(Sys.time() , "%Y-%m-%dT%H:%M:%S")
  )

  if (include_session_info) {
    required_attributes <- c(required_attributes, get_session_info())
  }

  user <- c(
    object$user,
    list(sysinfo = as.list(Sys.info()))
  )

  tags <- c(
    get("tags", envir = .sentry),
    tags
  )

  event_id <- generate_event_id()

  exception_context <- list(
    event_id = event_id,
    user = user,
    message = text,
    extra = c(required_attributes, extra),
    tags = tags,
    level = level
  )

  if (!is.null(exception)) {
    exception_context$exception <- exception
  }

  headers <- paste("Sentry", paste(sapply(names(object$auth), function(key) {
    paste0(key, "=", object$auth[[key]])
  }, USE.NAMES = FALSE), collapse = ", "))
  response <- httr::POST(url = object$url,
                         httr::add_headers('X-Sentry-Auth' = headers),
                         encode = "json",
                         body = exception_context)

  return(response)
}

# ---------------------------------------------------------------------
generate_event_id <- function() {
  paste(sample(c(0:9, letters[1:6]), 32, replace = TRUE), collapse = "")
}
