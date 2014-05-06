/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query2: Identify cases needing their definitive fixation forms


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */



%macro run_report2_q2(baseData=, errorData=, sourceDate=);


/* process the error flags */
/* note: none at this time */



data report2_q2(keep=id
                     monthlyReportId 
                     monthlyReportFacility 
                     monthlyReportCurrentFacility 
                     orTripDate 
                     explanation);
set redcapData(where=(redcap_event_name="baseline_arm_1"));
id                          =input(study_id, $4.);
monthlyReportId             ='FIX-' || input(facilitycode, $3.) || '-' || id;
monthlyReportFacility       =input(facilitycode, $3.);
monthlyReportCurrentFacility=upcase(input(redcap_data_access_group, $3.));
array orTripDates[20] ssort01_date_start ssort02_date_start ssort03_date_start ssort04_date_start
                      ssort05_date_start ssort06_date_start ssort07_date_start ssort08_date_start
                      ssort09_date_start ssort10_date_start ssort11_date_start ssort12_date_start
                      ssort13_date_start ssort14_date_start ssort15_date_start ssort16_date_start
                      ssort17_date_start ssort18_date_start ssort19_date_start ssort20_date_start
					  ;
array defFix     [20] ssort01_def_fix_trip ssort02_def_fix_trip ssort03_def_fix_trip ssort04_def_fix_trip
                      ssort05_def_fix_trip ssort06_def_fix_trip ssort07_def_fix_trip ssort08_def_fix_trip
                      ssort09_def_fix_trip ssort10_def_fix_trip ssort11_def_fix_trip ssort12_def_fix_trip
                      ssort13_def_fix_trip ssort14_def_fix_trip ssort15_def_fix_trip ssort16_def_fix_trip
                      ssort17_def_fix_trip ssort18_def_fix_trip ssort19_def_fix_trip ssort20_def_fix_trip
					  ;
do i=1 to 20;
  if not(crf07_any) and defFix[i]=1 then do;
    orTripDate=orTripDates[i];
	explanation='';
	output;
  end;
end;
run;
proc sort data=report2_q2; by monthlyReportId orTripDate; run;


%mend run_report2_q2;



