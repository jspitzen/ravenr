#' Get traceback as a list of strings
#'
#' @param compact
#'
#' @return
#' @export
#'
#' @examples
get_traceback <- function(compact = TRUE) {
  calls <- sys.calls()

  srcrefs <- sapply(calls, function(v) {
    srcref <- attr(v, "srcref")
    if (!is.null(srcref)) {
      srcfile <- attr(srcref, "srcfile")
      paste0(basename(srcfile$filename), "#", srcref[1L], ": ")
    } else {
      ""
    }
  })

  value <- lapply(as.character(calls), function(x) strsplit(x, "\n")[[1]][1])
  value <- as.list(value)
  names(value) <- srcrefs
  # combine source references with the call stack
  if (compact == TRUE) {
    # only keep lines with linenumbers
    value <- value[names(value) != ""]
  } else {
    # remove specific lines containing confusing pipe/trycatch/logging code
    value <- value[value != "withVisible(eval(quote(`_fseq`(`_lhs`)), env, env))"]
    value <- value[value != "eval(quote(`_fseq`(`_lhs`)), env, env)"]
    value <- value[value != "freduce(value, `_function_list`)"]
    value <- value[value != "function_list[[k]](value)"]
    value <- value[value != "withVisible(function_list[[k]](value))"]
    value <- value[value != "`_fseq`(`_lhs`)"]
    value <- value[value != "tryCatchOne(expr, names, parentenv, handlers[[1]])"]
    value <- value[value != "doTryCatch(return(expr), name, parentenv, handler)"]
    value <- value[value != "tryCatchList(expr, classes, parentenv, handlers)"]
    value <- value[value != "withRestarts({"]
    value <- value[value != "withOneRestart(expr, restarts[[1]])"]
    value <- value[value != "doWithOneRestart(return(expr), restart)"]
    value <- value[value != "(function (c) "]
    value <- value[value != "tryCatch(withCallingHandlers(expr, error = function(c) {"]
    value <- value[value != "withCallingHandlers(expr, error = function(c) {"]
    value <- value[value != ".handleSimpleError(function (c) "]
    value <- value[value != "h(simpleError(msg, call))"]
    value <- value[value != "try_catch_log({"]
    value <- value[value != "tryCatchOne(tryCatchList(expr, names[-nh], parentenv, handlers[-nh]), names[nh], parentenv, handlers[[nh]])"]
    value <- value[value != "tryCatchList(expr, names[-nh], parentenv, handlers[-nh])"]
    value <- value[value != "cond.handler(c, tags = tags, extra = extra, to_sentry = errors.to.sentry)"]
  }
  # add rownumbers to stack trace list (prevent automatic sorting)
  rownumbers <- formatC(seq(length(value)), width = 2, format = "d", flag = "0")
  names(value) <- paste(rownumbers, names(value), sep = ". ")

  return(value)
}

#' Get warning message from call stack (when warning itself is not available)
#'
#' @return
#' @export
#'
#' @examples
get_warning_exception <- function() {
  calls <- sys.calls()
  # detect warnings
  warnings <- sapply(calls, function(x) grepl("SimpleWarning", x[[1]])[1])
  if (any(warnings)) {
    warning_message <- as.character(calls[[which(warnings)]])
    exception <- list(
      "type" = warning_message[2],
      "value" = paste(
        "Warning in",
        sub("\\)$", "", sub("base::quote\\(", "", warning_message[3])),
        ":",
        warning_message[2]
      )
    )
  } else {
    exception <- list(
      "type" = "unspecified warning",
      "value" = "unspecified warning"
    )
  }
  return(exception)
}
