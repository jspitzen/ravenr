#' Custom stop function to intercept warnings
#'
#' @export
#'
#' @examples
#' options(warning.expression = quote({ravenr::capture_warning(restart)}))
#' log(-1)
capture_warning <- function(res) {
  # TODO get warning message from res object (hint: look at rlang::trace_back() functionality)
  capture_text(sentry, "unspecified warning", level = "warning", include_session_info = FALSE)
}
