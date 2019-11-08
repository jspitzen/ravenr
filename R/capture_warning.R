#' Custom stop function to intercept warnings
#'
#' @export
#'
#' @examples
#' options(warning.expression = quote({ravenr::capture_warning(restart)}))
#' log(-1)
capture_warning <- function(res) {
  exception <- get_warning_exception()
  sentry <- get("sentry_client", envir = .sentry)
  capture_text(sentry, level = "warning", include_session_info = FALSE, exception = exception)
  message(exception$value)
}
