# =============================================================================
# class-prLogistic.R
# S3 class and methods for prLogistic result objects.
# =============================================================================

# --------------------------------------------------------------------------- #
#  Constructor (internal)                                                      #
# --------------------------------------------------------------------------- #

.new_prLogistic <- function(table, conf, method, standardisation,
                             model_type, call) {
  structure(
    list(
      table           = table,           # numeric matrix [p x 3]: PR, lo, hi
      conf            = conf,
      method          = method,          # "delta" | "bootstrap"
      standardisation = standardisation, # "conditional" | "marginal"
      model_type      = model_type,      # "glm" | "glmer" | "geeglm" | "svyglm"
      call            = call
    ),
    class = "prLogistic"
  )
}

# --------------------------------------------------------------------------- #
#  print.prLogistic                                                            #
# --------------------------------------------------------------------------- #

#' Print a prLogistic object
#'
#' @param x A `prLogistic` object.
#' @param digits Number of significant digits (default 4).
#' @param ... Currently ignored.
#' @export
print.prLogistic <- function(x, digits = 4, ...) {
  conf_pct <- paste0(x$conf * 100, "%")
  cat("\n")
  cat("Prevalence Ratio Estimation via Logistic Regression\n")
  cat(rep("-", 52), "\n", sep = "")
  cat("  Model        :", x$model_type, "\n")
  cat("  Method       :", x$method, "\n")
  cat("  Standardis.  :", x$standardisation, "\n")
  cat("  Conf. level  :", conf_pct, "\n")
  cat(rep("-", 52), "\n", sep = "")
  cat("\n")

  # Build bootstrap sub-header if needed
  if (x$method == "bootstrap" && ncol(x$table) > 3) {
    cat("             ", sprintf("%12s", "Estimate"),
        sprintf("%12s", "Normal CI"),
        "  ",
        sprintf("%12s", "Percentile CI"),
        "\n")
  }

  print(round(x$table, digits))
  cat("\n")
  invisible(x)
}

# --------------------------------------------------------------------------- #
#  summary.prLogistic                                                          #
# --------------------------------------------------------------------------- #

#' Summarise a prLogistic object
#'
#' @param object A `prLogistic` object.
#' @param ... Currently ignored.
#' @export
summary.prLogistic <- function(object, ...) {
  cat("\nCall:\n")
  print(object$call)
  print(object)
  invisible(object)
}

# --------------------------------------------------------------------------- #
#  coef.prLogistic                                                             #
# --------------------------------------------------------------------------- #

#' Extract prevalence ratio point estimates
#'
#' @param object A `prLogistic` object.
#' @param ... Currently ignored.
#' @return Named numeric vector of PR estimates.
#' @export
coef.prLogistic <- function(object, ...) {
  out <- object$table[, "Estimate", drop = TRUE]
  out
}

# --------------------------------------------------------------------------- #
#  confint.prLogistic                                                          #
# --------------------------------------------------------------------------- #

#' Extract confidence intervals for prevalence ratios
#'
#' @param object A `prLogistic` object.
#' @param parm  Ignored (all parameters returned).
#' @param level Ignored (level is stored in the object).
#' @param type  For bootstrap objects: `"normal"` or `"percentile"`.
#' @param ... Currently ignored.
#' @return Numeric matrix with lower and upper bounds.
#' @export
confint.prLogistic <- function(object, parm, level, type = "percentile", ...) {
  tbl <- object$table
  if (object$method == "bootstrap" && ncol(tbl) == 5) {
    if (type == "normal") {
      return(tbl[, 2:3, drop = FALSE])
    } else {
      return(tbl[, 4:5, drop = FALSE])
    }
  }
  tbl[, 2:3, drop = FALSE]
}

# --------------------------------------------------------------------------- #
#  plot.prLogistic                                                             #
# --------------------------------------------------------------------------- #

#' Forest plot of prevalence ratios
#'
#' Produces a simple forest plot (no external dependencies beyond base R).
#'
#' @param x      A `prLogistic` object.
#' @param main   Plot title. If `NULL`, a default is used.
#' @param xlab   x-axis label.
#' @param col    Color for the point estimates.
#' @param ci_col Color for the CI lines.
#' @param ref_line Logical: draw a vertical reference line at PR = 1?
#' @param type   For bootstrap objects: `"normal"` or `"percentile"`.
#' @param ...    Further graphical parameters passed to `plot()`.
#' @export
plot.prLogistic <- function(x, main = NULL, xlab = "Prevalence Ratio",
                             col = "steelblue", ci_col = "steelblue",
                             ref_line = TRUE, type = "percentile", ...) {
  tbl <- x$table

  if (x$method == "bootstrap" && ncol(tbl) == 5) {
    if (type == "normal") {
      lo <- tbl[, 2]; hi <- tbl[, 3]
    } else {
      lo <- tbl[, 4]; hi <- tbl[, 5]
    }
  } else {
    lo <- tbl[, 2]; hi <- tbl[, 3]
  }

  pr  <- tbl[, 1]
  nms <- rownames(tbl)
  p   <- length(pr)

  if (is.null(main)) {
    main <- paste0(
      "Prevalence Ratios - ",
      x$standardisation, " / ", x$method,
      " (", x$conf * 100, "% CI)"
    )
  }

  xlim <- range(c(lo, hi, 1), na.rm = TRUE)
  xlim <- xlim + diff(xlim) * c(-0.05, 0.05)

  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par))
  graphics::par(mar = c(4, max(nchar(nms)) * 0.6 + 1, 3, 1))

  plot(
    pr, seq_len(p),
    xlim = xlim, ylim = c(0.5, p + 0.5),
    yaxt = "n", xlab = xlab, ylab = "",
    pch = 18, cex = 1.4, col = col,
    main = main, ...
  )

  graphics::axis(2, at = seq_len(p), labels = rev(nms), las = 1)

  # Reorder so first predictor is at the top
  y_pos <- rev(seq_len(p))
  graphics::segments(rev(lo), y_pos, rev(hi), y_pos,
                     col = ci_col, lwd = 2)
  graphics::points(rev(pr), y_pos, pch = 18, cex = 1.4, col = col)

  if (ref_line) {
    graphics::abline(v = 1, lty = 2, col = "grey50")
  }

  invisible(x)
}
