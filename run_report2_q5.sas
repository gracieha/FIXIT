/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query5: Missing discharge abstract for non-study related rehosps
   on MRR form


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

%macro run_report2_q5(baseData=, errorData=, sourceDate=);

/* process the error flags */
/* none at this time */


/* get medical record review information */
data report2_q5(keep=id monthlyReportId monthlyReportFacility monthlyReportCurrentFacility eventDate  missingAbstract explanation);
merge redcapData(keep  =study_id facilitycode redcap_event_name redcap_data_access_group
                 rename=(redcap_event_name=temp_name)
                 where =(temp_name="baseline_arm_1"))
      redcapData(where=(redcap_event_name in:("2","3","6","12"))
                 drop =facilitycode redcap_data_access_group)
      ;
by study_id;
id                          =input(study_id, $4.);
monthlyReportId             ='FIX-' || input(facilitycode, $3.) || '-' || id;
monthlyReportFacility       =input(facilitycode, $3.);
monthlyReportCurrentFacility=upcase(input(redcap_data_access_group, $3.));
array eventTypes [20]   cmrr_event_type1 -cmrr_event_type20;
array rehospTypes[20]   cmrr_rehosp_type1-cmrr_rehosp_type20;
array eventDates [20]   cmrr_event_date1 -cmrr_event_date20;
array abstracts  [20] $ cmrr_dis_abs1    -cmrr_dis_abs20;
do i=1 to 20;
  if (rehospTypes[i]=2 and eventTypes[i]=1 and abstracts[i]^="[document]") then do;
    eventDate      =eventDates[i];
	missingAbstract="Yes"; 
	explanation    ="";
    output; 
  end;
end;
format eventDate mmddyy10.;
run;
proc sort data=report2_q5; by monthlyReportId; run;



%mend run_report2_q5;
