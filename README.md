This package integrates `reghdfe` into `ivreg2`, through an `absorb()` option. This allows IV/2SLS regressions with multiple levels of fixed effects.

## Comparison with other commands

As seen in the table below, `ivreghdfe` is recommended if you want to run IV/LIML/GMM2S regressions with fixed effects, or run OLS regressions with advanced standard errors (HAC, Kiefer, etc.)

| Command                   | regress | areg    | reghdfe   | ivreg2                               | ivreghdfe                            |
|---------------------------|---------|---------|-----------|--------------------------------------|--------------------------------------|
| Models:                   | OLS     | OLS     | OLS       | OLS, IV, LIML, GMM2S, CUE            | OLS, IV, LIML, GMM2S (not CUE!)      |
| Fixed effects?            | -       | One-way | Multi-way | -                                    | Multi-way                            |
| Cluster SE?               | One-way | One-way | Multi-way | Two-way                              | Two-way                              |
| Additional SEs:           | -       | -       | -         | AC, HAC, Kiefer, Driscol-Kraay, etc. | AC, HAC, Kiefer, Driscol-Kraay, etc. |
| (Speed) Time without FEs: | 1x      | -       | 2x        | 3.7x                                 | 4.3x                                 |
| (Speed) Time with one FE: | -       | 6.3x    | 2.1x      | -                                    | 4.6x                                 |

*([Benchmark](simple_benchmark.do) run on Stata 14-MP (4 cores), with a dataset of 4 regressors, 10mm obs., 100 clusters and 10,000 FEs)*

## Installation

`ivreghdfe` requires three packages: `ivreg2`, `reghdfe` (version 5.x) and `ftools`. Run the lines below to install everything you might possibly need:


```
* Install ftools (remove program if it existed previously)
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

* Install boottest (Stata 11 and 12)
if (c(version)<13) cap ado uninstall boottest
if (c(version)<13) ssc install boottest

* Install moremata (sometimes used by ftools but not needed for reghdfe)
cap ssc install moremata

* Install ivreg2, the core package
cap ado uninstall ivreg2
ssc install ivreg2

* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)
```

If you are in a server, you can also download the
[zipfile](https://codeload.github.com/sergiocorreia/ivreghdfe/zip/master) and
install it locally:

```
cap ado uninstall ivreghdfe
net install ivreghdfe, from(c:\git\ivreghdfe)
```

## Advice

This code just modifies `ivreg2` adding an `absorb()` option that uses
`reghdfe`s Mata functions (see [this link](https://www.diffchecker.com/tzvmpKis) for the line-by-line differences).
When used, `absorb()` will also activate the `small`, `noconstant` and `nopartialsmall`
options of `ivreg2` (basically to force small sample adjustments, which are
required as we might have a substantial number of fixed effects).

If you need to pass optimization options directly to `reghdfe`
(e.g. tolerance, choice of transform, etc.) you can do that as a suboption
of `absorb()`:

```stata
sysuse auto, clear
ivreghdfe price weight (length=gear), absorb(turn trunk, tol(1e-6) accel(sd))
```

This is gives the same result as using the old version of reghdfe (but slower):

```stata
reghdfe price weight (length=gear), absorb(turn trunk) tol(1e-6) accel(sd) old
```

### Residuals

To save residuals, do this:

```stata
sysuse auto
ivreghdfe price weight, absorb(trunk, resid(myresidname))
```

Notice the `resid()` option within absorb. If you call it without parenthesis,
residuals will be saved in the variable `_reghdfe_resid`.

You can also use the other predict options of `reghdfe`, such as `d`:

```stata
predict d, d
```
