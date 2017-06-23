This package package adds an `absorb()` option to `ivreg2`, so we can run IV regressions
with multiple fixed effects, as with `reghdfe`.


## Installation steps

`ivreghdfe` requires three packages: `ivreg2`, `reghdfe` (version 4.x) and `ftools`. Run the lines below to install everything you might possibly need:


```
* Install ftools (remove program if it existed previously)
cap ado uninstall moresyntax
cap ado uninstall ftools
net install ftools, from("https://github.com/sergiocorreia/ftools/raw/master/src/")

* Install reghdfe 4.x
cap ado uninstall reghdfe
net install reghdfe, from("https://github.com/sergiocorreia/reghdfe/raw/master/src/")

* Install boottest for Stata 11 and 12
if (c(version)<13) cap ado uninstall boottest
if (c(version)<13) ssc install boottest

* Install moremata (sometimes used by ftools but not needed for reghdfe)
cap ssc install moremata

* Install ivreg2, the core package
ssc install ivreg2

* Finally, install this package
cap ado uninstall ivreg2hdfe
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://github.com/sergiocorreia/ivreg2_demo/raw/master/)
```

If you are in a server, you can also download the
[zipfile](https://github.com/sergiocorreia/ivreg2_demo/archive/master.zip) and
install it locally:

```
cap ado uninstall ivreghdfe
net install ivreghdfe, from(c:\git\ivreg2_demo)
```

## Advice

This code just modifies `ivreg2` adding an `absorb()` option that uses
`reghdfe`s Mata functions.
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
