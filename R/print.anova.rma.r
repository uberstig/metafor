print.anova.rma <- function(x, digits, ...) {

   mstyle <- .get.mstyle("crayon" %in% .packages())

   if (!inherits(x, "anova.rma"))
      stop(mstyle$stop("Argument 'x' must be an object of class \"anova.rma\"."))

   if (missing(digits))
      digits <- x$digits

   if (!exists(".rmspace"))
      cat("\n")

   if (x$type == "Wald.b") {

      cat(mstyle$section(paste0("Test of Moderators (coefficient", ifelse(x$m == 1, " ", "s "), .format.btt(x$btt),"):")))
      cat("\n")
      if (is.element(x$test, c("knha","adhoc","t"))) {
         cat(mstyle$result(paste0("F(df1 = ", x$m, ", df2 = ", x$dfs, ") = ", formatC(x$QM, digits=digits, format="f"), ", p-val ", .pval(x$QMp, digits=digits, showeq=TRUE, sep=" "))))
      } else {
         cat(mstyle$result(paste0("QM(df = ", x$m, ") = ", formatC(x$QM, digits=digits, format="f"), ", p-val ", .pval(x$QMp, digits=digits, showeq=TRUE, sep=" "))))
      }
      cat("\n")

   }

   if (x$type == "Wald.L") {

      if (x$m == 1) {
         cat(mstyle$section("Hypothesis:"))
      } else {
         cat(mstyle$section("Hypotheses:"))
      }

      tmp <- capture.output(print(x$hyp))
      .print.output(tmp, mstyle$text)

      cat("\n")
      cat(mstyle$section("Results:"))
      cat("\n")

      res.table <- cbind(estimate=c(x$Lb), se=x$se, zval=x$zval, pval=x$pval)
      if (is.element(x$test, c("knha","adhoc","t")))
         colnames(res.table)[3] <- "tval"
      rownames(res.table) <- paste0(seq_len(x$m), ":")
      res.table <- formatC(res.table, digits=digits, format="f")
      res.table[,4] <- .pval(x$pval, digits=digits)
      tmp <- capture.output(print(res.table, quote=FALSE, right=TRUE))
      .print.table(tmp, mstyle)

      cat("\n")

      if (!is.na(x$QM)) {
         if (x$m == 1) {
            cat(mstyle$section("Test of Hypothesis:"))
         } else {
            cat(mstyle$section("Omnibus Test of Hypotheses:"))
         }
         cat("\n")
         if (is.element(x$test, c("knha","adhoc","t"))) {
            cat(mstyle$result(paste0("F(df1 = ", x$m, ", df2 = ", x$dfs, ") = ", formatC(x$QM, digits=digits, format="f"), ", p-val ", .pval(x$QMp, digits=digits, showeq=TRUE, sep=" "))))
         } else {
            cat(mstyle$result(paste0("QM(df = ", x$m, ") = ", formatC(x$QM, digits=digits, format="f"), ", p-val ", .pval(x$QMp, digits=digits, showeq=TRUE, sep=" "))))
         }
         cat("\n")
      }

   }

   if (x$type == "LRT") {

      res.table <- rbind(
         c(x$p.f, x$fit.stats.f["AIC"], x$fit.stats.f["BIC"], x$fit.stats.f["AICc"], x$fit.stats.f["ll"], NA,    NA,     x$QE.f, x$tau2.f, NA),
         c(x$p.r, x$fit.stats.r["AIC"], x$fit.stats.r["BIC"], x$fit.stats.r["AICc"], x$fit.stats.r["ll"], x$LRT, x$pval, x$QE.r, x$tau2.r, NA)
      )

      res.table[,seq.int(from=2, to=10)] <- formatC(res.table[,seq.int(from=2, to=10)], digits=digits, format="f")
      colnames(res.table) <- c("df", "AIC", "BIC", "AICc", "logLik", "LRT", "pval", "QE", "tau^2", "R^2")
      rownames(res.table) <- c("Full", "Reduced")

      res.table["Reduced","pval"] <- .pval(x$pval, digits=digits)

      res.table["Full",c("LRT","pval")] <- ""
      res.table["Full","R^2"] <- ""
      res.table["Reduced","R^2"] <- paste0(ifelse(is.na(x$R2), NA, formatC(x$R2, format="f", digits=2)), "%")

      ### remove tau^2 and R^2 columns if full model is FE or if dealing with rma.mv models

      if (x$method == "FE" || is.element("rma.mv", x$class.f))
         res.table <- res.table[,seq_len(8)]

      tmp <- capture.output(print(res.table, quote=FALSE, right=TRUE))
      .print.table(tmp, mstyle)

   }

   if (!exists(".rmspace"))
      cat("\n")

   invisible()

}
