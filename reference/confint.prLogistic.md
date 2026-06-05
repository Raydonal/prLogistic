# Extract confidence intervals for prevalence ratios

Extract confidence intervals for prevalence ratios

## Usage

``` r
# S3 method for class 'prLogistic'
confint(object, parm, level, type = "percentile", ...)
```

## Arguments

- object:

  A `prLogistic` object.

- parm:

  Ignored (all parameters returned).

- level:

  Ignored (level is stored in the object).

- type:

  For bootstrap objects: `"normal"` or `"percentile"`.

- ...:

  Currently ignored.

## Value

Numeric matrix with lower and upper bounds.
