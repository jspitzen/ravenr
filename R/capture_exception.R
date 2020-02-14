#' Capture Exception
#'
#' \code{capture_exception} Captures an exception and sends it to Sentry
#'
#' @param object A Sentry client
#' @param exception exception to catch
#' @param extra set extra context
#' @param level set level, warning or error for example
#' @param tags named list of tags
#' @param include_session_info whether to send platform and package list, takes up to 1s or more
#'
#' @export
capture_exception <- function(exception, extra, level, tags, include_session_info) {
  response <- capture_text(
    text = exception$message, extra = extra, level = level, tags = tags,
    include_session_info = include_session_info
  )
}

#' Capture Exception
#'
#' \code{capture_exception.sentry} Captures an exception and sends it to Sentry
#'
#' @param object A Sentry client
#' @param exception exception to catch
#' @param extra set extra context
#' @param level set level, warning or error for example
#' @param tags named list of tags
#' @param include_session_info whether to send platform and package list, takes up to 1s or more
#'
#' @export
capture_exception.sentry <- function(exception, extra = NULL, level = "error", tags = NULL, include_session_info = TRUE
) {

  response <- capture_text(
    text = exception$message, extra = extra, level = level, tags = tags,
    include_session_info = include_session_info
  )

  return(response)
}
