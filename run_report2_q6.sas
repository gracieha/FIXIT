/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query6: Missing discharge abstract for non-study related rehosps
   on CFUP form


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */


%macro run_report2_q6(baseData=, errorData=, sourceDate=);

/* process the error flags */
data error6(keep=id eventDate);
set &errorData;
id       =input(substr(studyid, 9, 4), $4.);
eventDate=hospDate;
run;

/* get the rehospitalizations recorded on the CFUP form that are non-study related
   and at the facility */
data cfups(keep=id monthlyReportId monthlyReportFacility monthlyReportCurrentFacility eventDate);
merge redcapData(keep  =study_id facilitycode redcap_event_name redcap_data_access_group
                 rename=(redcap_event_name=temp_name)
                 where =(temp_name="baseline_arm_1"))
      redcapData(where=(redcap_event_name in:("2","3","6","12"))
                 drop = facilitycode redcap_data_access_group
      );
by study_id;
id                          =input(study_id, $4.);
monthlyReportId             ='FIX-' || input(facilitycode, $3.) || '-' || id;
monthlyReportFacility       =input(facilitycode, $3.);
monthlyReportCurrentFacility=upcase(input(redcap_data_access_group, $3.));
array dates       [15]  cf6w_rehosp1_admindate  cf6w_rehosp2_admindate  cf6w_rehosp3_admindate  cf6w_rehosp4_admindate  cf6w_rehosp5_admindate
                        cf3m_rehosp1_admindate  cf3m_rehosp2_admindate  cf3m_rehosp3_admindate  cf3m_rehosp4_admindate  cf3m_rehosp5_admindate
						cf12m_rehosp1_admindate cf12m_rehosp2_admindate cf12m_rehosp3_admindate cf12m_rehosp4_admindate cf12m_rehosp5_admindate
						;
array relateds    [15]  cf6w_rehosp1_other     cf6w_rehosp2_other     cf6w_rehosp3_other     cf6w_rehosp4_other     cf6w_rehosp5_other
                        cf3m_rehosp1_other     cf3m_rehosp2_other     cf3m_rehosp3_other     cf3m_rehosp4_other     cf3m_rehosp5_other
                        cf12m_rehosp1_other    cf12m_rehosp2_other    cf12m_rehosp3_other    cf12m_rehosp4_other    cf12m_rehosp5_other
                        ;
array atFacilitys [15]  cf6w_rehosp1_metrc_fac  cf6w_rehosp2_metrc_fac  cf6w_rehosp3_metrc_fac  cf6w_rehosp4_metrc_fac  cf6w_rehosp5_metrc_fac
                        cf3m_rehosp1_metrc_fac  cf3m_rehosp2_metrc_fac  cf3m_rehosp3_metrc_fac  cf3m_rehosp4_metrc_fac  cf3m_rehosp5_metrc_fac
                        cf12m_rehosp1_metrc_fac cf12m_rehosp2_metrc_fac cf12m_rehosp3_metrc_fac cf12m_rehosp4_metrc_fac cf12m_rehosp5_metrc_fac
                        ;
do i=1 to 15;
  if not(missing(dates[i])) and relateds[i]=0 and atFacilitys[i]=1 then do;
      eventDate  =dates[i];
      output;
  end;
end;
format eventDate mmddyy10.;
run;


/* get the abstracts recorded on the MRR form */
data mrrs(keep=id eventDate sds abstract);
set redcapData(where=(redcap_event_name in:("2","3","6","12")));
id      =input(study_id, $4.);
array eventDates [20]   cmrr_event_date1 -cmrr_event_date20;
array eventTypes [20]   cmrr_event_type1 -cmrr_event_type20;
array abstracts  [20] $ cmrr_dis_abs1    -cmrr_dis_abs20;
do i=1 to 20;
  if not(missing(eventDates[i])) then do;
    eventDate =eventDates[i];
	sds       =(eventTypes[i]=2);
	abstract  =(abstracts[i]="[document]"); 
    output; 
  end;
end;
format eventDate mmddyy10.;
run;
proc sort data=mrrs; by id eventDate descending abstract; run;


/* put togehter and select out the query */
proc sort data=cfups  nodupkey; by id eventDate; run;
proc sort data=mrrs   nodupkey; by id eventDate; run;
proc sort data=error6 nodupkey; by id eventDate; run;
data report2_q6(keep=id monthlyReportId monthlyReportFacility monthlyReportCurrentFacility eventDate missingAbstract explanation);
length id $12.;
merge cfups  (in=c)
      mrrs
	  error6 (in=e)
	  ;
by id eventDate;
if c;
if not(e) and not(sds) and not(abstract);
missingAbstract="Yes";
explanation='';
run;
proc sort data=report2_q6; by monthlyReportId; run;



%mend run_report2_q6;
