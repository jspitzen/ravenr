#' Custom tryCatch that catches erros and warnings in a try anc catch and sends them to sentry
#' code based on https://github.com/aryoda/tryCatchLog
#'
#' \code{try_catch_log} Catches errors and warnings and sends them to sentry
#'
#' @param expr function or expression that might generate the error
#' @param silent.warnings Boolean indicating wheter to print the warnings
#' @param silent.messages Boolean indicating wheter to print the messages
#' @param ... Extra input that has to be passed to other functions
#' @param extra Set extra context
#' @param messages.to.sentry Boolean indicating whether to send messages to Sentry
#' @param warnings.to.sentry Boolean indicating whether to send warnings to Sentry
#' @param errors.to.sentry Boolean indicating whether to send errors to Sentry
#' @param tags Named list of tags
try_catch_log <- function(expr,
                          ...,
                          silent.warnings = TRUE,
                          silent.messages = TRUE,
                          tags = list(),
                          extra = list(),
                          messages.to.sentry = TRUE,
                          warnings.to.sentry = TRUE,
                          errors.to.sentry = TRUE
) {
  # closure ---------------------------------------------------------------------------------------------------------
  cond.handler <- function(c, tags, extra, to_sentry = TRUE) {

    severity <- if (inherits(c, "error")) {
      "error"
    } else if (inherits(c, "warning")) {
      "warning"
    } else if (inherits(c, "message")) {
      "info"  # use info, as this is recognized by sentry and message is not
    } else {
      stop(sprintf("Unsupported condition class %s!", class(c)))
    }
    get.pretty.call.stack <- function(call.stack = sys.calls(), omit.last.items = 1, compact = FALSE) {
      if (is.null(call.stack))
        return("")

      # remove the last calls that shall be omitted
      if (length(call.stack) > omit.last.items)
        call.stack <- call.stack[1:(length(call.stack)
                                    - omit.last.items)]

      pretty.call.stack <- get_traceback(compact)

      return(pretty.call.stack)
    }
    # get call stack and add to sentry message
    # make pretty call stack global so it can be used by other (logging) functions
    # (this call stack function only works inside the trycatch, so generating it again after trycatch is not possible)
    # code based on https://github.com/aryoda/tryCatchLog
    pretty_call_stack <<- get.pretty.call.stack(omit.last.items = 1, compact = FALSE)
    extra <- c(extra, list("call_stack" = pretty_call_stack))

    # send exception to sentry
    if (to_sentry) {
      capture_exception(c, level = severity, tags = tags, extra = extra, include_session_info = FALSE)
    }

    # Suppresses the warning (logs it only)?
    if (silent.warnings & severity == "warning") {
      # flog.info("invoked restart")
      invokeRestart("muffleWarning")           # the warning will NOT bubble up now!
    } else {
      # The warning bubbles up and the execution resumes only if no warning handler is established
      # higher in the call stack via try or tryCatch
    }

    if (silent.messages & severity == "info") {
      invokeRestart("muffleMessage")            # the message will not bubble up now (logs it only)
    } else {
      # Just to make it clear here: The message bubbles up now
    }
  }

  tryCatch(
    withCallingHandlers(expr,
                        error   = function(c) {cond.handler(c, tags = tags, extra = extra, to_sentry = errors.to.sentry)},
                        warning = function(c) {cond.handler(c, tags = tags, extra = extra, to_sentry = warnings.to.sentry)},
                        message = function(c) {cond.handler(c, tags = tags, extra = extra, to_sentry = messages.to.sentry)}
    ),
    ...
  )
}
