# Forest plot of prevalence ratios

Produces a simple forest plot (no external dependencies beyond base R).

## Usage

``` r
# S3 method for class 'prLogistic'
plot(
  x,
  main = NULL,
  xlab = "Prevalence Ratio",
  col = "steelblue",
  ci_col = "steelblue",
  ref_line = TRUE,
  type = "percentile",
  ...
)
```

## Arguments

- x:

  A `prLogistic` object.

- main:

  Plot title. If `NULL`, a default is used.

- xlab:

  x-axis label.

- col:

  Color for the point estimates.

- ci_col:

  Color for the CI lines.

- ref_line:

  Logical: draw a vertical reference line at PR = 1?

- type:

  For bootstrap objects: `"normal"` or `"percentile"`.

- ...:

  Further graphical parameters passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html).
