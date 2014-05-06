/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query1: Identify cases where an or trip form is needed per the
   index hospitalization form


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */


%macro run_report2_q1(baseData=, errorData=, sourceDate=);



/* process the error flags */
/* note: none at this time */



/* Using the redcapdata, get the OR trip dates indicated on the
   index hosp form */
data orTrips1(keep=id monthlyReportId monthlyReportFacility monthlyReportCurrentFacility orTripNum orTripDate );
set redcapdata(where=(redcap_event_name="baseline_arm_1"));
id                          =input(study_id, $4.);
monthlyReportId             ='FIX-' || input(facilitycode, $3.) || '-' || id;
monthlyReportFacility       =input(facilitycode, $3.);
monthlyReportCurrentFacility=upcase(input(redcap_data_access_group, $3.));
array orTripDates[20] ihf_or_trip_date1-ihf_or_trip_date20;
do orTripNum=1 to 20;
  if not(missing(orTripDates[orTripNum])) then do;
    orTripDate=orTripDates[orTripNum];
	output;
  end;
end;
run;

/* similarly for the dates on CRF09 */
data orTrips2(keep=id orTripDate);
set redcapdata(where=(redcap_event_name="baseline_arm_1"));
id=input(study_id, $4.);
array orTripDates[20] ssort01_date_start ssort02_date_start ssort03_date_start ssort04_date_start
                      ssort05_date_start ssort06_date_start ssort07_date_start ssort08_date_start
                      ssort09_date_start ssort10_date_start ssort11_date_start ssort12_date_start
                      ssort13_date_start ssort14_date_start ssort15_date_start ssort16_date_start
                      ssort17_date_start ssort18_date_start ssort19_date_start ssort20_date_start
					  ;
array orCompletes[20] crf09_complete_01-crf09_complete_20;
do i=1 to 20;
  *if orCompletes[i]=2 then do;
  if not(missing(orTripDates[i])) then do;
    orTripDate=orTripDates[i];
	output;
  end;
end;
run;

/* merge together, and output those cases without a match */
proc sort data=orTrips1; by id orTripDate; run;
proc sort data=orTrips2; by id orTripDate; run;
data report2_q1(keep=id
                     monthlyReportId 
                     monthlyReportFacility 
                     monthlyReportCurrentFacility 
                     orTripNum 
                     orTripDate 
                     explanation);
merge orTrips1 (in=o1)
      orTrips2 (in=o2)
	  ;
by id orTripDate;
if o1 and not(o2);
explanation='';
format orTripDate mmddyy10.;
run;
proc sort data=report2_q1; by monthlyReportId orTripNum; run;


%mend run_report2_q1;



