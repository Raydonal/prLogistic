## Resubmission

This is a resubmission. In response to CRAN feedback (Benjamin Altmann), I have:

* Added \value tags to the .Rd files of the exported methods print(),
  summary() and plot(), documenting the returned object (its class and
  structure) and the side effect of each method.
* Replaced \dontrun{} with \donttest{} in the examples.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a resubmission of a previously archived package. 'prLogistic'
  was archived on 2022-06-14; the earlier check problems were fixed in the
  2.0 rewrite. I am the original maintainer (Raydonal Ospina,
  raydonal@de.ufpe.br).

## Notes

* "New submission / Package was archived on CRAN" -- expected, as this is a
  resubmission of the archived package.
* "Possibly misspelled words in DESCRIPTION": Amorim and Ospina are author
  surnames; geeglm, geepack, glm, glmer, lme and svyglm are function/package
  names. All are spelled correctly.

## Test environments

* local: Ubuntu, R 4.6.0
* win-builder: R-devel

## Downstream dependencies

None.
