/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Set up enrollment data - get all screened subjects and flag those
   eligible, refused, enrolled, whether they have completed the study,
   along with final visit and discontinuation dates.

   Assign a month and year used for reporting.


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

%macro make_enrollmentData(redcapData= );

data enrollmentData(keep=id facility screened eligible refused enrolled group
                         completedStudy finalVisitDate discontinuationDate 
                         screenAndEnrollDate
                         exclAge exclOpenTibia exclFxNotSuitable 
                         exclTraumaticAmp exclPriorFixation 
                         exclTibiaInfection exclComplex       
                         exclNonAmbulatory exclOther
						 withdrawalDate deathDate deviationScreening
						 deviationProcedural deviationAdmin deviationOther
						 sae 
                         );
merge redcapData(in   =r
                 where=(redcap_event_name="baseline_arm_1" and
                        crf00_complete=2                   and
                        not(inex_open_tibia_criteria___1=0 and  
                            inex_open_tibia_criteria___2=0 and
                            inex_open_tibia_criteria___3=0 and
                            inex_open_tibia_criteria___4=0 and
                            inex_open_tibia_criteria___5=0)))
	  redcapData(keep=  study_id 
                        redcap_event_name 
                        sae01_sae_date 
                        sae02_sae_date 
                        sae03_sae_date
						crf10_complete_01 
                        crf10_complete_02 
                        crf10_complete_03
	             rename=(redcap_event_name=temp_name1)
				 where =(temp_name1="adverse_events_arm_1"))
      redcapData(keep=  study_id
	                    redcap_event_name
					    fsf_study_completed
					    fsf_final_visit_date
					    fsf_study_not_completed
					    fsf_reason_not_completed
						af01_complete
						pdf01_screen_consent___1 - pdf01_screen_consent___4 
						pdf02_screen_consent___1 - pdf02_screen_consent___4
						pdf03_screen_consent___1 - pdf03_screen_consent___4
						pdf04_screen_consent___1 - pdf04_screen_consent___4
						pdf05_screen_consent___1 - pdf05_screen_consent___4
						pdf01_procedural___5     - pdf01_procedural___10
						pdf02_procedural___5     - pdf02_procedural___10
						pdf03_procedural___5     - pdf03_procedural___10
						pdf04_procedural___5     - pdf04_procedural___10
						pdf05_procedural___5     - pdf05_procedural___10
						pdf01_admin___11         - pdf01_admin___15 
						pdf02_admin___11         - pdf02_admin___15 
						pdf03_admin___11         - pdf03_admin___15 
						pdf04_admin___11         - pdf04_admin___15 
						pdf05_admin___11         - pdf05_admin___15 
						pdf01_admin_other
                        pdf02_admin_other 
                        pdf03_admin_other
						pdf04_admin_other
						pdf05_admin_other
				 rename=(redcap_event_name=temp_name2)
				 where =(temp_name2="admin_arm_1"));
by study_id;
if r;

/* sae and protocol deviation information */
array saeDates             [3]  sae01_sae_date sae02_sae_date sae03_sae_date;
array saeCompletes         [3]  crf10_complete_01 crf10_complete_02 crf10_complete_03;
array deviationScreenings  [20] pdf01_screen_consent___1 - pdf01_screen_consent___4 
								pdf02_screen_consent___1 - pdf02_screen_consent___4
								pdf03_screen_consent___1 - pdf03_screen_consent___4
								pdf04_screen_consent___1 - pdf04_screen_consent___4
								pdf05_screen_consent___1 - pdf05_screen_consent___4
								;
array deviationProcedurals [30] pdf01_procedural___5 - pdf01_procedural___10
                                pdf02_procedural___5 - pdf02_procedural___10
								pdf03_procedural___5 - pdf03_procedural___10
								pdf04_procedural___5 - pdf04_procedural___10
								pdf05_procedural___5 - pdf05_procedural___10
								;
array deviationAdmins      [25] pdf01_admin___11 - pdf01_admin___15
                                pdf02_admin___11 - pdf02_admin___15
								pdf03_admin___11 - pdf03_admin___15
								pdf04_admin___11 - pdf04_admin___15
								pdf05_admin___11 - pdf05_admin___15
								;
array deviationOthers      [5]$ pdf01_admin_other pdf02_admin_other pdf03_admin_other 
                                pdf04_admin_other pdf05_admin_other;

/* corrections */
if study_id in('1001','1002','1003','1004') then inex_dt_form_completed='01JUL2011'd;
if study_id='1044'                          then inex_dt_form_completed='09JAN2012'd;
if study_id='1053'                          then inex_dt_form_completed='12JAN2012'd;
if study_id='1262'                          then inex_dt_form_completed='29JAN2013'd;
if study_id='1395'                          then inex_dt_form_completed='29MAY2013'd;
if study_id='1057'                          then dff_procedure_date    ='06FEB2012'd;

/* manual map of obs to rct for one patient */
if study_id='1286' and treat_assign in (0,1) then treat_assign=2; 

/* variables for the report */
id       =input(study_id, $4.);
facility =input(facilitycode, $3.);
screened =(crf00_complete=2);
eligible =(inex_eligible);
refused  =(crf00version=2     and 
           inex_consent=0     and 
           inex_consent_obs=0 and 
           not(missing(inex_consent_date))) 
              or
          (not(crf00version=2)                 and 
           inex_consent_obs=0                  and 
           not(missing(inex_refusal_rct_date)) and 
           not(missing(inex_consent_obs_date)));
enrolled =(treat_assign in (0,1,2));
if treat_assign in (0,1) then group=1;
if treat_assign in (2)   then group=2;
completedStudy     =(fsf_study_completed=1 and af01_complete=2);
finalVisitDate     =fsf_final_visit_date;
discontinuationDate=fsf_study_not_completed;
screenAndEnrollDate=inex_dt_form_completed; 
exclAge            =(inex_patient_age            =0);
exclOpenTibia      =(inex_open_tibia_criteria_pmt=0);
exclFxNotSuitable  =(inex_limb_salvage           =0);
exclTraumaticAmp   =(inex_tibia_amp              =1);
exclPriorFixation  =(inex_prev_def_fix           =1);
exclTibiaInfection =(inex_curr_infection         =1);
exclComplex        =(inex_cpop_frac              =1 or
                     v2_inex_cpop_frac           =1);
exclNonAmbulatory  =(inex_noam_sci               =1 or 
                     inex_noam_pec               =1 or 
                     v2_inex_noam_sci            =1 or 
                     v2_inex_noam_pec            =1);
exclOther          =not(eligible)           and 
                    not(exclAge)            and            
                    not(exclOpenTibia)      and 
                    not(exclFxNotSuitable)  and
                    not(exclTraumaticAmp)   and
                    not(exclPriorFixation)  and
                    not(exclTibiaInfection) and 
                    not(exclComplex)        and
                    not(exclNonAmbulatory); 
if fsf_reason_not_completed^=666 then withdrawalDate=fsf_study_not_completed;
else                                  withdrawalDate=.;
if fsf_reason_not_completed =666 then deathDate     =fsf_study_not_completed;
else                                  deathDate     =.;
deviationScreening =sum(of deviationScreenings[*]);
deviationProcedural=sum(of deviationProcedurals[*]);
deviationAdmin     =sum(of deviationAdmins[*]);
deviationOther     =5-cmiss(of deviationOthers[*]); 
sae=0;
do i=1 to 3;
  if not(missing(saeDates[i])) and (saeCompletes[i]=2) then sae=sae+1;
end;
run;

%mend make_enrollmentData;
