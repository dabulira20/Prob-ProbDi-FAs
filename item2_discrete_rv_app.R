# =============================================================================
# Item 2: Shiny front end for discrete random variables
# -----------------------------------------------------------------------------
# Tab 1  Univariate : enter values + probabilities -> mean, variance, PDF, CDF
# Tab 2  Bivariate  : enter x values, y values and a joint probability table ->
#                     marginals, conditionals, mean/variance of each, PDF/CDF plots
# Validity checks: probabilities numeric, each in [0, 1], and sum to one.
#
# Run:  install.packages("shiny")   # once
#       shiny::runApp("item2_discrete_rv_app.R")
# =============================================================================
library(shiny)

TOL <- 1e-8

# ------------------------------ helper functions ------------------------------
parse_nums <- function(txt) {
  parts <- strsplit(trimws(txt), "[,;[:space:]]+")[[1]]
  parts <- parts[parts != ""]
  v <- suppressWarnings(as.numeric(parts))
  if (length(parts) == 0 || any(is.na(v))) stop("Please enter numeric values only (separated by commas or spaces).")
  v
}

check_probs <- function(p, label = "Probabilities") {
  if (any(p < 0 | p > 1)) stop(sprintf("%s must all lie in [0, 1].", label))
  if (abs(sum(p) - 1) > 1e-6) stop(sprintf("%s must sum to 1 (they currently sum to %.6f).", label, sum(p)))
  invisible(TRUE)
}

# Build a validated pmf: sorted values, duplicates not allowed
make_pmf <- function(x, p, label = "Probabilities") {
  if (length(x) != length(p)) stop(sprintf("Number of values (%d) and number of probabilities (%d) differ.", length(x), length(p)))
  if (anyDuplicated(x)) stop("Values must be distinct.")
  check_probs(p, label)
  o <- order(x)
  list(x = x[o], p = p[o])
}

pmf_stats <- function(d) {
  m <- sum(d$x * d$p)
  v <- sum((d$x - m)^2 * d$p)
  list(mean = m, var = v, sd = sqrt(v))
}

plot_pmf <- function(d, main) {
  plot(d$x, d$p, type = "h", lwd = 4, col = "steelblue", ylim = c(0, max(d$p) * 1.1),
       xlab = "x", ylab = "P(X = x)", main = main)
  points(d$x, d$p, pch = 16, col = "steelblue")
}

plot_cdf <- function(d, main) {
  cp <- cumsum(d$p)
  plot(stepfun(d$x, c(0, cp)), verticals = FALSE, pch = 16, col = "firebrick",
       xlim = range(d$x) + c(-1, 1), ylim = c(0, 1), xlab = "x", ylab = "F(x)", main = main)
}

# Parse the joint table: one row per line (rows = X values), columns = Y values
parse_joint <- function(txt, nx, ny) {
  lines <- strsplit(trimws(txt), "\n")[[1]]
  lines <- lines[nzchar(trimws(lines))]
  rows <- lapply(lines, parse_nums)
  if (length(rows) != nx) stop(sprintf("Joint table needs %d rows (one per X value); found %d.", nx, length(rows)))
  if (any(vapply(rows, length, 1L) != ny)) stop(sprintf("Every row of the joint table needs %d entries (one per Y value).", ny))
  do.call(rbind, rows)
}

# ---------------------------------- UI ----------------------------------------
ui <- fluidPage(
  titlePanel("Discrete Random Variable Calculator"),
  tabsetPanel(
    tabPanel("Univariate",
      sidebarLayout(
        sidebarPanel(
          textInput("u_x", "Values of X (comma separated)", "1, 2, 3, 4"),
          textInput("u_p", "Probabilities (comma separated)", "0.1, 0.2, 0.3, 0.4"),
          helpText("Each probability must be in [0, 1] and they must sum to 1.")
        ),
        mainPanel(
          verbatimTextOutput("u_err"), tableOutput("u_table"), verbatimTextOutput("u_stats"),
          fluidRow(column(6, plotOutput("u_pdf")), column(6, plotOutput("u_cdf")))
        )
      )),
    tabPanel("Bivariate",
      sidebarLayout(
        sidebarPanel(
          textInput("b_x", "Values of X (rows)", "0, 1, 2"),
          textInput("b_y", "Values of Y (columns)", "0, 1"),
          textAreaInput("b_joint", "Joint probabilities P(X=x, Y=y)\n(one row per X value, entries separated by commas)",
                        "0.10, 0.20\n0.15, 0.25\n0.20, 0.10", rows = 6),
          uiOutput("cond_controls"),
          helpText("All entries must lie in [0, 1] and the whole table must sum to 1.")
        ),
        mainPanel(
          verbatimTextOutput("b_err"),
          h4("Joint distribution"), tableOutput("b_joint_tbl"),
          h4("Marginal distributions"),
          fluidRow(column(6, tableOutput("b_mx")), column(6, tableOutput("b_my"))),
          verbatimTextOutput("b_stats"),
          fluidRow(column(6, plotOutput("bx_pdf")), column(6, plotOutput("bx_cdf"))),
          fluidRow(column(6, plotOutput("by_pdf")), column(6, plotOutput("by_cdf"))),
          h4("Conditional distribution"), tableOutput("b_cond_tbl"), verbatimTextOutput("b_cond_stats"),
          fluidRow(column(6, plotOutput("c_pdf")), column(6, plotOutput("c_cdf")))
        )
      ))
  )
)

# -------------------------------- Server --------------------------------------
server <- function(input, output, session) {

  # ---------- univariate ----------
  u_dist <- reactive({
    tryCatch(make_pmf(parse_nums(input$u_x), parse_nums(input$u_p)),
             error = function(e) structure(list(msg = conditionMessage(e)), class = "bad"))
  })
  u_ok <- function() { d <- u_dist(); !inherits(d, "bad") }
  output$u_err <- renderText({ d <- u_dist(); if (inherits(d, "bad")) paste("Input error:", d$msg) else "" })
  output$u_table <- renderTable({ req(u_ok()); d <- u_dist(); data.frame(x = d$x, `P(X=x)` = d$p, `F(x)` = cumsum(d$p), check.names = FALSE) })
  output$u_stats <- renderText({
    req(u_ok()); s <- pmf_stats(u_dist())
    sprintf("Mean E[X] = %.4f\nVariance Var(X) = %.4f\nStd. deviation = %.4f", s$mean, s$var, s$sd)
  })
  output$u_pdf <- renderPlot({ req(u_ok()); plot_pmf(u_dist(), "PDF (probability mass function)") })
  output$u_cdf <- renderPlot({ req(u_ok()); plot_cdf(u_dist(), "CDF") })

  # ---------- bivariate ----------
  b_data <- reactive({
    tryCatch({
      x <- parse_nums(input$b_x); y <- parse_nums(input$b_y)
      if (anyDuplicated(x) || anyDuplicated(y)) stop("X values must be distinct, and Y values must be distinct.")
      J <- parse_joint(input$b_joint, length(x), length(y))
      check_probs(as.vector(J), "Joint probabilities")
      ox <- order(x); oy <- order(y)
      x <- x[ox]; y <- y[oy]; J <- J[ox, oy, drop = FALSE]
      dimnames(J) <- list(paste0("x=", x), paste0("y=", y))
      list(x = x, y = y, J = J,
           mx = list(x = x, p = rowSums(J)), my = list(x = y, p = colSums(J)))
    }, error = function(e) structure(list(msg = conditionMessage(e)), class = "bad"))
  })
  b_ok <- function() !inherits(b_data(), "bad")
  output$b_err <- renderText({ d <- b_data(); if (inherits(d, "bad")) paste("Input error:", d$msg) else "" })

  output$cond_controls <- renderUI({
    req(b_ok()); d <- b_data()
    tagList(
      radioButtons("cond_type", "Conditional distribution of:", c("X given Y = y" = "XgY", "Y given X = x" = "YgX")),
      selectInput("cond_val", "Conditioning value", choices = d$y)
    )
  })
  observeEvent(input$cond_type, {
    req(b_ok()); d <- b_data()
    updateSelectInput(session, "cond_val", choices = if (input$cond_type == "XgY") d$y else d$x)
  })

  output$b_joint_tbl <- renderTable({ req(b_ok()); b_data()$J }, rownames = TRUE, digits = 4)
  output$b_mx <- renderTable({ req(b_ok()); d <- b_data()$mx; data.frame(x = d$x, `P(X=x)` = d$p, check.names = FALSE) })
  output$b_my <- renderTable({ req(b_ok()); d <- b_data()$my; data.frame(y = d$x, `P(Y=y)` = d$p, check.names = FALSE) })
  output$b_stats <- renderText({
    req(b_ok()); d <- b_data(); sx <- pmf_stats(d$mx); sy <- pmf_stats(d$my)
    sprintf("X: mean = %.4f, variance = %.4f\nY: mean = %.4f, variance = %.4f", sx$mean, sx$var, sy$mean, sy$var)
  })
  output$bx_pdf <- renderPlot({ req(b_ok()); plot_pmf(b_data()$mx, "Marginal PDF of X") })
  output$bx_cdf <- renderPlot({ req(b_ok()); plot_cdf(b_data()$mx, "Marginal CDF of X") })
  output$by_pdf <- renderPlot({ req(b_ok()); plot_pmf(b_data()$my, "Marginal PDF of Y") })
  output$by_cdf <- renderPlot({ req(b_ok()); plot_cdf(b_data()$my, "Marginal CDF of Y") })

  cond_dist <- reactive({
    req(b_ok(), input$cond_val, input$cond_type); d <- b_data(); v <- as.numeric(input$cond_val)
    if (input$cond_type == "XgY") {
      j <- match(v, d$y); req(!is.na(j)); den <- d$my$p[j]
      validate(need(den > 0, "P(Y = y) = 0, so the conditional distribution is undefined."))
      list(dist = list(x = d$x, p = d$J[, j] / den), lab = sprintf("X | Y = %g", v))
    } else {
      i <- match(v, d$x); req(!is.na(i)); den <- d$mx$p[i]
      validate(need(den > 0, "P(X = x) = 0, so the conditional distribution is undefined."))
      list(dist = list(x = d$y, p = d$J[i, ] / den), lab = sprintf("Y | X = %g", v))
    }
  })
  output$b_cond_tbl <- renderTable({ cd <- cond_dist(); data.frame(value = cd$dist$x, probability = cd$dist$p, cumulative = cumsum(cd$dist$p)) })
  output$b_cond_stats <- renderText({ cd <- cond_dist(); s <- pmf_stats(cd$dist)
    sprintf("%s: mean = %.4f, variance = %.4f", cd$lab, s$mean, s$var) })
  output$c_pdf <- renderPlot({ cd <- cond_dist(); plot_pmf(cd$dist, paste("Conditional PDF:", cd$lab)) })
  output$c_cdf <- renderPlot({ cd <- cond_dist(); plot_cdf(cd$dist, paste("Conditional CDF:", cd$lab)) })
}

shinyApp(ui, server)
