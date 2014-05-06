/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query4: Identify missing CRF08 or CRF09 when the CFUP form shows
   a hospitalization


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */


%macro run_report2_q4(baseData=, errorData=, sourceDate=);

/* process the error flags */
data error4(keep=id eventDate);
set &errorData;
id       =input(substr(studyid, 9, 4), $4.);
eventDate=hospDate;
run;


/* get the rehospitalizations recorded on the CFUP form */
data cfups(keep=id monthlyReportId monthlyReportFacility monthlyReportCurrentFacility eventDate rehospOrSDS related atFacility);
merge redcapData(keep= study_id facilitycode redcap_data_access_group redcap_event_name rename=(redcap_event_name=temp_name) where=(temp_name="baseline_arm_1"))
      redcapData(in=r where=(redcap_event_name in:("2","3","6","12")) drop=facilitycode redcap_data_access_group)
      ;
by study_id;
if r;
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
  if not(missing(dates[i])) then do;
      eventDate  =dates[i];
	  rehospOrSDS=1;
      related    =(relateds[i]   =1);  
	  atFacility =(atFacilitys[i]=1);
      output;
  end;
end;
format eventDate mmddyy10.;
run;


/* get rhEvents, which have crf08 and crf09 information */
data rhEvents (keep=id eventDate touchCRF08 completeCRF08 anyOrTrip touchCRF09 completeCRF09);
set redcapData(where=(redcap_event_name in:("rh")));
id=input(study_id, $4.);
array orTrips_isf[20] isf_or_trip_date1 - isf_or_trip_date20;
array orTrips_ort[20] ssort01_date_start ssort02_date_start ssort03_date_start ssort04_date_start
                      ssort05_date_start ssort06_date_start ssort07_date_start ssort08_date_start
                      ssort09_date_start ssort10_date_start ssort11_date_start ssort12_date_start
                      ssort13_date_start ssort14_date_start ssort15_date_start ssort16_date_start
                      ssort17_date_start ssort18_date_start ssort19_date_start ssort20_date_start
					  ;
array completes_ort[20] crf09_complete_01-crf09_complete_20;
if not(missing(isf_adm_date)) then do;
  eventDate    =isf_adm_date;
  touchCRF08   =1;
  completeCRF08=(crf08_complete=2);
  do i=1 to 20;
    if not(missing(orTrips_isf[i])) then do;
	  anyOrTrip     =1;
	  touchCRF09    =0;
	  completeCRF09 =0;
      do j=1 to 20;
        if orTrips_isf[i]=orTrips_ort[j] then do;
          touchCRF09   =1;
          completeCRF09=(completes_ort[j]=2);
		end;
	  end;
	  if touchCRF09=0 then i=20;
	end;
  end;
  output;
end;
if missing(isf_adm_date) then do;
  do k=1 to 20;
    if not(missing(orTrips_ort[k])) then do;
	  anyOrTrip    =1;
      eventDate    =orTrips_ort[k];
	  touchCRF09   =1;
	  completeCRF09=(completes_ort[k]=2);
	  output;
	end;
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



/* merge together and select out query4 */
proc sort data=cfups nodupkey;  by id eventDate; run;
proc sort data=mrrs  nodupkey;  by id eventDate; run;
proc sort data=rhEvents;        by id eventDate; run;
proc sort data=error4 nodupkey; by id eventDate; run;
data report2_q4 (keep=id monthlyReportId monthlyReportFacility monthlyReportCurrentFacility eventDate missingCRF08or09 missingCRF09 missingAbstract explanation);
length id                           $4.
       monthlyReportId              $12. 
       monthlyReportFacility        $3.
       monthlyReportCurrentFacility $3.
       eventDate                     8.
	   missingCRF08or09             $7.
	   missingCRF09                 $7.
	   missingAbstract              $7.
	   ;
merge cfups    (in=c)
      mrrs     
      rhEvents 
	  error4   (in=e)
	  ;
by id eventDate;
if c;
missingCRF08or09="No";
missingCRF09    ="No";
missingAbstract ="No";
if rehospOrSDS=1 and related=1 and not(touchCRF08) and not(touchCRF09) then do;
  missingCRF08or09="Yes";
  missingCRF09    ="Unknown";
  missingAbstract ="Unknown";
end;
if rehospOrSDS=1 and related=1 and touchCRF08=1  and anyOrTrip=1 and not(touchCRF09)           then missingCRF09="Yes";
if rehospOrSDS=1 and (related=1 or atFacility=1) and touchCRF08=1 and not(sds) and abstract^=1 then missingAbstract="Yes";  
if not(e) and (missingCRF08or09="Yes" or
               missingCRF09    ="Yes" or
               missingAbstract ="Yes"
               );
explanation='';
run;
proc sort data=report2_q4; by monthlyReportId eventDate; run;
      



%mend run_report2_q4;
