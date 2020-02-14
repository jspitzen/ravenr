#' Custom stop function to intercept errors
#'
#' @export
#'
#' @examples
#' options(error = ravenr::capture_error)
#' log('a')
capture_error <- function() {
  error_message <- geterrmessage()
  exception <- list(
    "type" = sub("\\\n", "", sub("^Error in .* : ", "", error_message)),
    "value" = gsub("\\\"", "'", sub("\\\n", "", error_message))
  )
  capture_text(error_message, level = "error", include_session_info = FALSE, exception = exception)
}
