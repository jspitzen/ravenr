#' Custom stop function to intercept errors
#'
#' @export
#'
#' @examples
#' options(error = ravenr::capture_error)
#' log('a')
capture_error <- function() {
  error_message <- geterrmessage()
  capture_text(sentry, error_message, level = "error", include_session_info = FALSE)
}
