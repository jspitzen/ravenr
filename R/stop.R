#' Custom stop function to intercept errors
#'
#' @param ... other arguments
#' @param call. call
#' @param domain domain
#'
#' @export
#'
stop <- function(..., call. = TRUE, domain = NULL) {
  error_message <- geterrmessage()
  capture_text(sentry, error_message, level = "error", include_session_info = FALSE)
  invisible()
}
