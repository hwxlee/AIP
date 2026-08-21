/**************************************************************************
Pharmacology-informed AIP prediction
Sequential exposure construction

This script illustrates:
1. Calculation of pharmacologically weighted APD exposure in consecutive 30-day windows
2. Construction of window-level incident AIP labels
3. Post-event masking for sequential modeling
**************************************************************************/

/*=========================================================================
EXPECTED INPUTS

COHORT:
	jid					= patient identifier
	index_date	= index date
	dip				= incident aip indicator
	dip_date		= date of incident aip

APD:
	jid					= patient identifier
	med_start		= prescription start date
	med_end		= prescription end date
	pkr				= dopamine d2 receptor affinity metric
	bb				= blood-brain barrier penetration rate
	dddperday	= prescribed daily dose standardized by ddd
=========================================================================*/


%let n_windows = 12;


/*=========================================================================
 1. Calculate pharmacologically weighted exposure in each 30-day window
=========================================================================*/

proc sort data=cohort; by jid; run;
proc sort data=apd; by jid med_start; run;

data apd_exposure;
	merge
		cohort (in=a keep=jid index_date)
		apd	(keep=jid med_start med_end pkr bb dddperday);
	by jid;
	if a;
run;

data apd_sequence;
	set apd_exposure;
	by jid;

	array exposure_sum[&n_windows] _temporary_;

	if first.jid then do i = 1 to &n_windows;
		exposure_sum[i] = 0;
	end;

	do i = 1 to &n_windows;
		window_start = index_date + ((i - 1) * 30);
		window_end = index_date + (i * 30) - 1;
		if not missing(med_start) and
			not (med_end < window_start or med_start > window_end)
		then do;
			window_days = min(window_end, med_end) - max(window_start, med_start)	+ 1;
			exposure_sum[i] = 	exposure_sum[i] + (pkr * bb * dddperday * window_days);
		end;
	end;

	if last.jid then do i = 1 to &n_windows;
		window = i;
		window_start = index_date + ((i - 1) * 30);
		window_end = index_date + (i * 30) - 1;
		window_pkr_bb_ddd = exposure_sum[i];
		output;
	end;

	keep jid window window_start window_end window_pkr_bb_ddd;
	format window_start window_end date9.;
run;


/*=========================================================================
	2. Add window-level incident AIP outcome
=========================================================================*/

proc sort data=apd_sequence; by jid window; run;
proc sort data=cohort; by jid; run;

data aip_apd_sequence;
	merge
		apd_sequence (in=a)
		cohort (keep=jid dip dip_date);
	by jid;
	if a;

	outcome_dip = 0;
	if dip = 1
		and window_start <= dip_date
		and dip_date <= window_end
	then outcome_dip = 1;
run;


/*=========================================================================
	3. Create post-event mask
=========================================================================*/

data aip_apd_seq_mask;
	set aip_apd_sequence;
	by jid window;

	retain event_occurred;

	if first.jid then event_occurred = 0;
	if event_occurred = 0 then valid_mask = 1;
		else valid_mask = 0;
	if outcome_dip = 1 then event_occurred = 1;

	drop event_occurred dip dip_date;
run;
