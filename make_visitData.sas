/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Set up visit data - create a universe of visits for each subject,
   get all observed visits, get missed visits, final visits, and 
   SAE reports. Finally, create a visit data table with a record for each
   person-visit.


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */


%macro make_visitData(redcapData= , logFile=, sourceDate= );

/* ------------------------------------------------------------------------- */
/*
   Using the redcapdata, calculate the expected visits and windows


/* ------------------------------------------------------------------------- */
/* create a table of expected visits and their windows by rolling out 
   the universe of visits for every patient */
data expectedVisits(keep=id facility currentFacility injuryDate visit 
                         windowStart windowEnd);
set redcapData(keep =study_id facilitycode redcap_data_access_group 
                     treat_assign redcap_event_name gicf_date 
                     ihf_discharge_date
               where=(redcap_event_name="baseline_arm_1"))
			   ;
id             =input(study_id, $4.);
facility       =input(facilitycode, $3.);
currentFacility=upcase(input(redcap_data_access_group, $3.));
injuryDate     =gicf_date;
if treat_assign in (0,1,2) then do;
  do visit=-1 to 4; 
    if visit=0 then do; windowStart=ihf_discharge_date;    windowEnd=ihf_discharge_date+7;  end; 
    if visit=1 then do; windowStart=gicf_date+(7* 6)-14;   windowEnd=gicf_date+(7 *6)+14;   end;
    if visit=2 then do; windowStart=gicf_date+(7*12)-14;   windowEnd=gicf_date+(7*12)+14;   end;
    if visit=3 then do; windowStart=gicf_date+(7*26)-14;   windowEnd=gicf_date+(7*26)+14;   end;
    if visit=4 then do; windowStart=gicf_date+(7*52)-14+1; windowEnd=gicf_date+(7*52)+14+1; end;
    output;
  end;
end;
else do;
  visit=-1; 
  output;
end;
format windowStart windowEnd mmddyy10.;
run;



/* ------------------------------------------------------------------------- */
/*
   Using the redcapdata, get all observed visits along with whether
   each form for the visit is touched or complete 


/* ------------------------------------------------------------------------- */
/* create a table of observed visits */
data observedVisits(keep=id visit visitOccurred visitDate 
                         completeCRF00
                         completeCRF02 completeCRF03 completeCRF04 
                         completeCRF05 completeCRF06 completeCRF07 
                         completeCRF14 completeCRF15 completeCRF16  
				         completeCRF17 completeCRF18 completeCRF19  
                         completeCRF20 completeCRF21 completeCRF22   
                         completeCRF23 completeCRF24 completeCRF25 
                         completeCRF26 completeCRF27 completeCRF28
                         completeCRF29 completeCRF30 completeCRF31 
                         completeCRF32
                         touchCRF02 touchCRF03 touchCRF04 
                         touchCRF05 touchCRF06 touchCRF07 
                         touchCRF14 touchCRF15 touchCRF16  
				         touchCRF17 touchCRF18 touchCRF19  
                         touchCRF20 touchCRF21 touchCRF22   
                         touchCRF23 touchCRF24 touchCRF25 
                         touchCRF26 touchCRF27 touchCRF28
                         touchCRF29 touchCRF30 touchCRF31 
                         touchCRF32
                         );
set redcapData;

if redcap_event_name ="baseline_arm_1" then do;
  id             =input(study_id, $4.);
  visit          =-1;
  visitOccurred  =1;
  visitDate      =(inex_dt_form_completed);
  completeCRF00  =(crf00_complete=2); 
  output;
  end;

if redcap_event_name ="baseline_arm_1" and treat_assign in (0,1,2) then do;
  id             =input(study_id, $4.);
  visit          =0;
  visitOccurred  =1;
  visitDate      =ihf_discharge_date;
  completeCRF02  =(crf02_complete=2 or 
                   proxycrf02_complete=2);
  completeCRF03  =(crf03_complete=2);
  completeCRF04  =(crf04_complete=2);
  completeCRF05  =(crf05_complete=2);
  completeCRF06  =(crf06_complete=2); 
  completeCRF07  =(crf07_complete=2);
  touchCRF02     =(crf02_complete=2 or proxycrf02_complete=2 or crf02_any or prx02_any);
  touchCRF03     =(crf03_complete=2 or crf03_any);
  touchCRF04     =(crf04_complete=2 or crf04_any);
  touchCRF05     =(crf05_complete=2 or crf05_any);
  touchCRF06     =(crf06_complete=2 or crf06_any);
  touchCRF07     =(crf07_complete=2 or crf07_any);
  output;
  end;

if redcap_event_name ="6_week_followup_arm_1" then do;
  id             =input(study_id, $4.);
  visit          =1;
  visitOccurred  =1; 
  visitDate      =cf6w_clin_visit_dt; 
  completeCRF14  =(crf11_complete=2);
  completeCRF15  =(crf15_complete=2 or 
                   proxycrf15_complete=2); 
  completeCRF16  =(crf13_complete=2);      
  touchCRF14     =(crf11_complete=2 or cmrr_any);
  touchCRF15     =(crf15_complete=2 or proxycrf15_complete=2 or pi6w_any or pxpi6w_any);
  touchCRF16     =(crf13_complete=2 or cf6w_any);
  output;
  end;

if redcap_event_name ="3_month_followup_arm_1" then do;
  id             =input(study_id, $4.);
  visit          =2;
  visitOccurred  =1; 
  visitDate      =cf3m_clin_visit_dt; 
  completeCRF17  =(crf11_complete=2);      
  completeCRF18  =(crf18_complete=2 or    
                   proxycrf18_complete=2); 
  completeCRF19  =(crf19_complete=2);     
  touchCRF17     =(crf11_complete=2 or cmrr_any);
  touchCRF18     =(crf18_complete=2 or proxycrf18_complete=2 or pi3m_any or pxpi3m_any);
  touchCRF19     =(crf19_complete=2 or cf3m_any);
  output;
  end;

if redcap_event_name ="6_month_followup_arm_1" then do;
  id             =input(study_id, $4.);
  visit          =3;
  visitOccurred  =1; 
  visitDate      =cf3m_clin_visit_dt; 
  completeCRF20  =(crf11_complete=2);   
  completeCRF21  =(crf21_complete=2 or     
                   proxycrf21_complete=2); 
  completeCRF22  =(crf19_complete=2);     
  completeCRF23  =(crf23_complete=2);   
  completeCRF24  =(crf24_complete=2);  
  touchCRF20     =(crf11_complete=2  or cmrr_any);
  touchCRF21     =(crf21_complete=2 or proxycrf21_complete=2 or pi6m_any or pxpi6m_any);
  touchCRF22     =(crf19_complete=2 or cf3m_any);
  touchCRF23     =(crf23_complete=2 or smfa_any);
  touchCRF24     =(crf24_complete=2 or bpi_any);
  output;
  end;

if redcap_event_name ="12_month_followup_arm_1" then do;
  id             =input(study_id, $4.);
  visit          =4;
  visitOccurred  =1; 
  visitDate      =cf12m_clin_visit_dt; 
  completeCRF25  =(crf11_complete=2);    
  completeCRF26  =(crf26_complete=2 or 
                   proxycrf26_complete=2);
  completeCRF27  =(crf27_complete=2);   
  completeCRF28  =(crf23_complete=2);     
  completeCRF29  =(crf24_complete=2);  
  completeCRF30  =(crf30_complete=2);  
  completeCRF31  =(crf31_complete=2); 
  completeCRF32  =(crf32_complete=2);    
  touchCRF25     =(crf11_complete=2 or cmrr_any);
  touchCRF26     =(crf26_complete=2 or 
                   proxycrf26_complete=2 or pi12m_any or pxpi12m_any);
  touchCRF27     =(crf27_complete=2 or cf12m_any);
  touchCRF28     =(crf23_complete=2 or smfa_any);
  touchCRF29     =(crf24_complete=2 or bpi_any);
  touchCRF30     =(crf30_complete=2 or phq_any);
  touchCRF31     =(crf31_complete=2 or pcl_any);
  touchCRF32     =(crf32_complete=2 or psq_any);
  output;
  end;
run;



/* ------------------------------------------------------------------------- */
/*
   Using the redcapdata, get all missed visits from AF03 


/* ------------------------------------------------------------------------- */
data missedVisits(keep=id visit completeAF03 missedType missedReason missedReasonDesc);
set redcapData(where=(redcap_event_name="admin_arm_1"));
array visits      [10] mioowv01_missed_visit mioowv02_missed_visit mioowv03_missed_visit 
                       mioowv04_missed_visit mioowv05_missed_visit mioowv06_missed_visit 
                       mioowv07_missed_visit mioowv08_missed_visit mioowv09_missed_visit 
                       mioowv10_missed_visit
					   ;
array missedTypes [10] mioowv01_occur mioowv02_occur mioowv03_occur mioowv04_occur mioowv05_occur
                       mioowv06_occur mioowv07_occur mioowv08_occur mioowv09_occur mioowv10_occur
					   ;	
array reasons     [10] mioowv01_missed_reason mioowv02_missed_reason mioowv03_missed_reason 
                       mioowv04_missed_reason mioowv05_missed_reason mioowv06_missed_reason
                       mioowv07_missed_reason mioowv08_missed_reason mioowv09_missed_reason 
                       mioowv10_missed_reason
					   ;
array descriptions[10] mioowv01_missed_reason_o mioowv02_missed_reason_o mioowv03_missed_reason_o 
                       mioowv04_missed_reason_o mioowv05_missed_reason_o mioowv06_missed_reason_o 
                       mioowv07_missed_reason_o mioowv08_missed_reason_o mioowv09_missed_reason_o 
                       mioowv10_missed_reason_o
                       ;
array completes   [10] af03_complete_01 - af03_complete_10;
id=input(study_id, $4.);
do i=1 to 10;
  if visits[i] not in (.,2) then do;
    if visits[i]    =1 then visit=0;
	if visits[i]    =2 then visit=.;
	if visits[i]    =3 then visit=1;
	if visits[i]    =4 then visit=2;
	if visits[i]    =5 then visit=3;
	if visits[i]    =6 then visit=4;
	completeAF03    =(completes[i]=2);
	missedType      =missedTypes[i];
	missedReason    =reasons[i];
	missedReasonDesc=descriptions[i] ;
    output;
  end; 
end;
run;




/* ------------------------------------------------------------------------- */
/*
   Using redcapdata, get dates of death and withdrawal from AF01


/* ------------------------------------------------------------------------- */
/* create a table having death and withdrawal information */
data finalVisits(keep=id visit completeAF01 withdrawalDate deathDate);
set redcapData(where=(redcap_event_name="admin_arm_1"));
id = input(study_id, $4.);
do visit=-1 to 4;
  completeAF01=(af01_complete=2);
  if fsf_reason_not_completed^=666 then withdrawalDate=fsf_study_not_completed;
  else                                  withdrawalDate=.;
  if fsf_reason_not_completed =666 then deathDate     =fsf_study_not_completed;
  else                                  deathDate     =.;
  output;
end;
run;




/* ------------------------------------------------------------------------- */
/*
   Using redcapdata, get dates of death from SAE form


/* ------------------------------------------------------------------------- */
data saeDeaths(keep=id visit saeDeath);
set redcapData(where=(redcap_event_name="adverse_events_arm_1"));
id =input(study_id, $4.);
array saes[3] sae01_sae_type sae02_sae_type sae03_sae_type;
do visit=-1 to 4;
  exit=3;
  do j=1 to exit;
    if saes[j]=1 then do;
      saeDeath=1;
	  j=3;
      output;
    end;
  end;
end;
run;



/* ------------------------------------------------------------------------- */
/*
   Using the log file, get the most recent date of form entry for
   each form


/* ------------------------------------------------------------------------- */
proc sql;
create table formEdits as (
  select put(scan(action,3), $4.) as id,
         case 
           when scan(action,2,'()') ='Baseline'           then 0
		   when scan(action,2,'()') ='6 week follow-up'   then 1
		   when scan(action,2,'()') ='3 month follow-up'  then 2
		   when scan(action,2,'()') ='6 month follow-up'  then 3
		   when scan(action,2,'()') ='12 month follow-up' then 4
		   else                                                .
		 end as visit,
		 case
           when index(details,'crf02')>0 or index(details,'proxycrf02')>0 then 'CRF02'
           when index(details,'crf03')>0                                  then 'CRF03'
           when index(details,'crf04')>0                                  then 'CRF04'
           when index(details,'crf05')>0                                  then 'CRF05'
           when index(details,'crf06')>0                                  then 'CRF06'
           when index(details,'crf07')>0                                  then 'CRF07'
           when index(details,'crf11')>0 and calculated visit=1           then 'CRF14'
           when index(details,'crf15')>0 or index(details,'proxycrf15')>0 then 'CRF15'
           when index(details,'crf13')>0 and calculated visit=1           then 'CRF16'
           when index(details,'crf11')>0 and calculated visit=2           then 'CRF17'
           when index(details,'crf18')>0 or index(details,'proxycrf18')>0 then 'CRF18'
           when index(details,'crf19')>0 and calculated visit=2           then 'CRF19'
           when index(details,'crf11')>0 and calculated visit=3           then 'CRF20'
           when index(details,'crf21')>0 or index(details,'proxycrf21')>0 then 'CRF21'
           when index(details,'crf19')>0 and calculated visit=3           then 'CRF22'
           when index(details,'crf23')>0 and calculated visit=3           then 'CRF23'
           when index(details,'crf24')>0 and calculated visit=3           then 'CRF24'
           when index(details,'crf11')>0 and calculated visit=4           then 'CRF25'
           when index(details,'crf26')>0 or index(details,'proxycrf26')>0 then 'CRF26'
           when index(details,'crf27')>0                                  then 'CRF27'
           when index(details,'crf23')>0 and calculated visit=4           then 'CRF28'
           when index(details,'crf24')>0 and calculated visit=4           then 'CRF29'
           when index(details,'crf30')>0                                  then 'CRF30'
           when index(details,'crf31')>0                                  then 'CRF31'
           when index(details,'crf32')>0                                  then 'CRF32'
		   else ''
		 end as form,
		 max(timestamp) as timestamp format=mmddyy10.
  from logFile
  where  not(missing(details))             and
          (action like 'Created Record %' 
           or 
           action like 'Updated Record %') and
		 calculated visit in (0,1,2,3,4)   and
		 calculated form^=''

  group by id, calculated visit, calculated form
);
quit;





/* ------------------------------------------------------------------------- */
/*
   Merge the visit info together into a large master table, add 
   the monthly report definitions of expected, occurred,
   and missed visits, plus visit and id text


/* ------------------------------------------------------------------------- */
proc sort data=expectedVisits;                               by id visit; run;
proc sort data=observedVisits;                               by id visit; run;
proc sort data=formEdits;                                    by id visit; run;
proc sort data=missedVisits out=missedVisitsNoDups nodupkey; by id visit; run;
proc sort data=finalVisits;                                  by id visit; run;
proc sort data=saeDeaths;                                    by id visit; run;
data visitData(
  drop=form
       timestampCRF02
       timestampCRF03
       timestampCRF04
       timestampCRF05
       timestampCRF06
       timestampCRF07
       timestampCRF14
       timestampCRF15
       timestampCRF16
       timestampCRF17
       timestampCRF18
       timestampCRF19
       timestampCRF20
       timestampCRF21
       timestampCRF22
       timestampCRF23
       timestampCRF24
       timestampCRF25
       timestampCRF26
       timestampCRF27
       timestampCRF28
       timestampCRF29
       timestampCRF30
       timestampCRF31
       timestampCRF32
       );
length id                           $4.
       monthlyReportId              $12.
       monthlyReportFacility        $3.
       monthlyReportCurrentFacility $3.
       monthlyReportVisit           $15.
       monthlyReportVisitOccurred   8.
       monthlyReportVisitExpected   8.
       monthlyReportVisitMissed     8.
       ;
merge expectedVisits    (in=e)
      observedVisits    (in=o)
	  formEdits         (rename=(timestamp=timestampCRF02) where=(form='CRF02'))
	  formEdits         (rename=(timestamp=timestampCRF03) where=(form='CRF03'))
	  formEdits         (rename=(timestamp=timestampCRF04) where=(form='CRF04'))
	  formEdits         (rename=(timestamp=timestampCRF05) where=(form='CRF05'))
	  formEdits         (rename=(timestamp=timestampCRF06) where=(form='CRF06'))
	  formEdits         (rename=(timestamp=timestampCRF07) where=(form='CRF07'))
	  formEdits         (rename=(timestamp=timestampCRF14) where=(form='CRF14'))
	  formEdits         (rename=(timestamp=timestampCRF15) where=(form='CRF15'))
	  formEdits         (rename=(timestamp=timestampCRF16) where=(form='CRF16'))
	  formEdits         (rename=(timestamp=timestampCRF17) where=(form='CRF17'))
	  formEdits         (rename=(timestamp=timestampCRF18) where=(form='CRF18'))
	  formEdits         (rename=(timestamp=timestampCRF19) where=(form='CRF19'))
	  formEdits         (rename=(timestamp=timestampCRF20) where=(form='CRF20'))
	  formEdits         (rename=(timestamp=timestampCRF21) where=(form='CRF21'))
	  formEdits         (rename=(timestamp=timestampCRF22) where=(form='CRF22'))
	  formEdits         (rename=(timestamp=timestampCRF23) where=(form='CRF23'))
	  formEdits         (rename=(timestamp=timestampCRF24) where=(form='CRF24'))
	  formEdits         (rename=(timestamp=timestampCRF25) where=(form='CRF25'))
	  formEdits         (rename=(timestamp=timestampCRF26) where=(form='CRF26'))
	  formEdits         (rename=(timestamp=timestampCRF27) where=(form='CRF27'))
	  formEdits         (rename=(timestamp=timestampCRF28) where=(form='CRF28'))
	  formEdits         (rename=(timestamp=timestampCRF29) where=(form='CRF29'))
	  formEdits         (rename=(timestamp=timestampCRF30) where=(form='CRF30'))
	  formEdits         (rename=(timestamp=timestampCRF31) where=(form='CRF31'))
	  formEdits         (rename=(timestamp=timestampCRF32) where=(form='CRF32'))
	  missedVisitsNoDups(in=m)
	  finalVisits
	  saeDeaths
	  ;
by id visit;
if e;
monthlyReportId             ='FIX-' || facility || '-' || id;
monthlyReportFacility       =facility;
monthlyReportCurrentFacility=currentFacility;
if visit in (-1,0) then monthlyReportVisit='(0) Baseline';
if visit=1         then monthlyReportVisit='(2) 6wk';
if visit=2         then monthlyReportVisit='(3) 3mo';
if visit=3         then monthlyReportVisit='(4) 6mo';
if visit=4         then monthlyReportVisit='(5) 12mo';
monthlyReportVisitOccurred  =visitOccurred;
monthlyReportVisitExpected  =(. < windowEnd+7 < "&sourceDate"d and not(. < deathDate < windowEnd+7)) or
                             monthlyReportVisitOccurred; 
monthlyReportVisitMissed    =(completeAF03=1 and missedType=0);
if monthlyReportVisitOccurred=1 and not(missedType=0) then do;  
  if visit=0 then do;
    timelyBaselineForms1  =(completeCRF02 and (. < timestampCRF02 <= visitDate+7 <= "&sourceDate"d) and
	                        completeCRF04 and (. < timestampCRF04 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF05 and (. < timestampCRF05 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF06 and (. < timestampCRF06 <= visitDate+7 <= "&sourceDate"d)); 
    timelyBaselineForms2  =(completeCRF03 and (. < timestampCRF03 <= visitDate+7 <= "&sourceDate"d));
  end;
  if visit=1 then do;
    timelySixWeekForms    =(completeCRF14 and (. < timestampCRF14 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF15 and (. < timestampCRF15 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF16 and (. < timestampCRF16 <= visitDate+7 <= "&sourceDate"d));
  end;
  if visit=2 then do;
	timelyThreeMonthForms =(completeCRF17 and (. < timestampCRF17 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF18 and (. < timestampCRF18 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF19 and (. < timestampCRF19 <= visitDate+7 <= "&sourceDate"d));
  end;
  if visit=3 then do;
	timelySixMonthForms   =(completeCRF20 and (. < timestampCRF20 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF21 and (. < timestampCRF21 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF22 and (. < timestampCRF22 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF23 and (. < timestampCRF23 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF24 and (. < timestampCRF24 <= visitDate+7 <= "&sourceDate"d));
  end;
  if visit=4 then do;
	timelyTwelveMonthForms=(completeCRF25 and (. < timestampCRF25 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF26 and (. < timestampCRF26 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF27 and (. < timestampCRF27 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF28 and (. < timestampCRF28 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF29 and (. < timestampCRF29 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF30 and (. < timestampCRF30 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF31 and (. < timestampCRF31 <= visitDate+7 <= "&sourceDate"d) and
                            completeCRF32 and (. < timestampCRF32 <= visitDate+7 <= "&sourceDate"d));
  end;
end;
format visitDate mmddyy10.;
run;

%mend make_visitData;
