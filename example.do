set trace off
clear all
discard
pr drop _all

sysuse auto

* Ensure ivreg2 works
ivreg2 price weight

* Ensure ivreg2hdfe works
ivreg2hdfe price weight

* Test replay works
ivreg2hdfe


* Test absorb()
ivreg2hdfe price weight, absorb(turn)
