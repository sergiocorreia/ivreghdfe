noi cscript "ivreg2 with absorb()" adofile reghdfe

* Setup
	sysuse auto
	replace turn = . in 1 // ensure we detect MVs in absorb()


* Test 1: ivreg2==ivreg2hdfe

	ivreg2 price weight (gear=length)
	storedresults save benchmark e()

	ivreg2hdfe price weight (gear=length)
	storedresults compare benchmark e(), exclude(macro: cmd cmdline ivreg2cmd)
	storedresults drop benchmark


* Test 2: ivreg2hdfe==ivreg+partial
	ivreg2 price weight i.turn , partial(i.turn) small
	storedresults save benchmark e()

	ivreg2hdfe price weight, absorb(turn, keepsingletons)
	assert e(df_m)==1
	loc excluded ///
		macro: cmd cmdline ivreg2cmd insts inexog partial partial1 partialcons df_m ///
		scalar: partialcons df_m
	storedresults compare benchmark e(), exclude(`excluded') tol(1e-12)
	storedresults drop benchmark


* Test 3: ivreg2hdfe==reghdfe
	reghdfe price weight, absorb(turn) keepsingletons
	loc bench_r2 = e(r2_within)
	storedresults save benchmark e()

	ivreg2hdfe price weight, absorb(turn, keepsingletons)
	assert e(rank)==.
	assert e(df_m)==1
	assert abs(e(r2) - `bench_r2') < 1e-8
	loc excluded ///
		macro: cmd cmdline vce indepvars title title2 footnote estat_cmd predict ///
		scalar: rank ic N_hdfe_extended redundant tss tss_within mss ll_0 r2_a_within ///
			r2_a r2_within r2
	storedresults compare benchmark e(), tol(1e-12) exclude(`excluded') 
	storedresults drop benchmark
	// why does mss differs??


* Test 4: ivreg2hdfe==reghdfe with TWFE and TWC
	reghdfe price weight, absorb(turn foreign) cluster(turn trunk) keepsingletons
	loc bench_r2 = e(r2_within)
	storedresults save benchmark e()

	ivreg2hdfe price weight, absorb(turn foreign, keepsingletons) cluster(turn trunk)
	assert e(rank)==.
	assert e(df_m)==1
	assert abs(e(r2) - `bench_r2') < 1e-8
	loc excluded ///
		macro: cmd cmdline vce indepvars title title2 footnote estat_cmd predict title3 ///
		scalar: rank ic N_hdfe_extended redundant tss tss_within mss ll_0 r2_a_within ///
			r2_a r2_within r2 rmse N_clustervars
	storedresults compare benchmark e(), tol(1e-12) exclude(`excluded') 
	storedresults drop benchmark
	// why does mss and rmse differ?

* Test 4b: as 4 but drop singletons
	reghdfe price weight, absorb(turn foreign) cluster(turn trunk)
	loc bench_r2 = e(r2_within)
	storedresults save benchmark e()

	ivreg2hdfe price weight, absorb(turn foreign) cluster(turn trunk)
	assert e(rank)==.
	assert e(df_m)==1
	assert abs(e(r2) - `bench_r2') < 1e-8
	loc excluded ///
		macro: cmd cmdline vce indepvars title title2 footnote estat_cmd predict title3 ///
		scalar: rank ic N_hdfe_extended redundant tss tss_within mss ll_0 r2_a_within ///
			r2_a r2_within r2 rmse N_clustervars
	storedresults compare benchmark e(), tol(1e-12) exclude(`excluded') 
	storedresults drop benchmark
	// why does mss and rmse differ?

* Test 5: ivreg2hdfe with IV
	reghdfe price weight (gear=length), absorb(turn) cluster(trunk) keepsingletons old
	loc bench_r2 = e(r2_within)
	storedresults save benchmark e()

	ivreg2hdfe price weight (gear=length), absorb(turn, keepsing) cluster(trunk)
	assert e(rank)==.
	assert e(df_m)==2
	assert abs(e(r2) - `bench_r2') < 1e-8
	* Have to add a bunch more because I' comparing against the old reghdfe
	loc excluded ///
		macro: cmd cmdline vce indepvars title title2 footnote estat_cmd predict title3 ///
			instruments endogvars vcesuite dofadjustments subcmd ivreg2cmd marginsok marginsnotok ///
		scalar: rank ic N_hdfe_extended redundant tss tss_within mss ll_0 r2_a_within ///
			r2_a r2_within r2 rmse N_clustervars partial_ct df_m savestages r2u r2c G1 M1_nested ///
			M1_exact K1 M1 unclustered_df_r partialcons M_due_to_nested mobility
	storedresults compare benchmark e(), tol(1e-12) exclude(`excluded') 
	storedresults drop benchmark
	// why does mss and rmse differ?

exit
