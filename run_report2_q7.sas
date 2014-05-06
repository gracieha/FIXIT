/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query7: CRF08 and CRF09 but no corresponding CFUP or MRR


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

%macro run_report2_q7(baseData=, errorData=, sourceDate=);

/* process the error flags */
data error7(keep=id eventDate);
set &errorData;
id       =input(substr(studyid, 9, 4), $4.);
eventDate=hospDate;
run;

/* get rhEvents, which have crf08 and crf09 information */
data rhEvents (keep=id monthlyReportId monthlyReportFacility monthlyReportCurrentFacility eventDate touchCRF08 completeCRF08);
merge redcapData(keep  =study_id facilitycode redcap_event_name redcap_data_access_group
                 rename=(redcap_event_name=temp_name)
                 where =(temp_name="baseline_arm_1"))
      redcapData(where=(redcap_event_name in:("rh"))
                 drop =facilitycode redcap_data_access_group);
by study_id;
id                          =input(study_id, $4.);
monthlyReportId             ='FIX-' || input(facilitycode, $3.) || '-' || id;
monthlyReportFacility       =input(facilitycode, $3.);
monthlyReportCurrentFacility=upcase(input(redcap_data_access_group, $3.));
if not(missing(isf_adm_date)) then do;
  eventDate    =isf_adm_date;
  touchCRF08   =1;
  completeCRF08=(crf08_complete=2);
  output;
end;
format eventDate mmddyy10.;
run;

/* get the hospitalizations recorded on the MRR form */
data mrrs(keep=id eventDate);
set redcapData(where=(redcap_event_name in:("2","3","6","12")));
id      =input(study_id, $4.);
array eventDates [20]   cmrr_event_date1 -cmrr_event_date20;
array eventTypes [20]   cmrr_event_type1 -cmrr_event_type20;
do i=1 to 20;
  if not(missing(eventDates[i])) and eventTypes[i]=1 then do;
    eventDate =eventDates[i];
    output; 
  end;
end;
format eventDate mmddyy10.;
run;

/* get the hospitalizations recorded on the CFUP form */
data cfups(keep=id eventDate);
set redcapData(where=(redcap_event_name in:("2","3","6","12")));
id      =input(study_id, $4.);
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
  if not(missing(dates[i])) then do;
      eventDate  =dates[i];
      output;
  end;
end;
format eventDate mmddyy10.;
run;

/* put togehter and select out the query */
proc sort data=rhEvents;          by id eventDate; run;
proc sort data=cfups    nodupkey; by id eventDate; run;
proc sort data=mrrs     nodupkey; by id eventDate; run;
proc sort data=error7   nodupkey; by id eventDate; run;
data report2_q7(keep=id monthlyReportId monthlyReportFacility monthlyReportCurrentFacility eventDate missingCFUP missingMRR explanation);
merge rhEvents (in=r)
      cfups    (in=c)
      mrrs     (in=m)
	  error7   (in=e)
	  ;
by id eventDate;
if r;
if r and not(c) then missingCFUP="Yes"; else missingCFUP="No";
if r and not(m) then missingMRR ="Yes"; else missingMRR ="No";
explanation='';
if not(e) and (missingCFUP="Yes" or
               missingMRR ="Yes");
run;
proc sort data=report2_q7; by monthlyReportId; run;



%mend run_report2_q7;
