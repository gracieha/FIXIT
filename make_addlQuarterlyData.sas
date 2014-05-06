/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Set up additional data used for the quarterly and dsmb reports, 
   such as days to fixation, fracture type, gender, race, and
   ethnicity


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

%macro make_addlQuarterlyData(redcapData= );

data addlQuarterlyData(
  keep=id facility injuryDate sex raceWhite raceBlack raceOther
       hispanic quarterlyReportFractureType1-quarterlyReportFractureType5
       defFixationDate
       );
set redcapData(where=(redcap_event_name="baseline_arm_1" and
                      treat_assign in (0,1,2)));

/* corrections */
if study_id='1057' then dff_procedure_date ='06FEB2012'd;

/* limit to complete forms */
*if crf02_complete=2 or proxycrf02_complete=2;

/* variables for the report */
id                          =input(study_id, $4.);
facility                    =input(facilitycode, $3.);
injuryDate                  =gicf_date;
if crf02_complete=2 then do;
  sex                         =pcf_gender;
  raceWhite                   =(pcf_race___1=1 and 
                                not(pcf_race___2=1 or  
                                    pcf_race___3=1 or 
                                    pcf_race___4=1 or 
                                    pcf_race___5=1 or 
                                    pcf_race___6=1));
  raceBlack                   =(pcf_race___2=1 and 
                                not(pcf_race___1=1 or 
                                    pcf_race___3=1 or 
                                    pcf_race___4=1 or 
                                    pcf_race___5=1 or 
                                    pcf_race___6=1));
  raceOther                   =not(raceWhite) and not(raceBlack) and 
                               not(pcf_race___998=1) and not(pcf_race___999=1);
  if      missing(pcf_latino_hispanic) or
          pcf_latino_hispanic=998      or
          pcf_latino_hispanic=999      then hispanic=.;
  else if pcf_latino_hispanic=1        then hispanic=1;
  else                                      hispanic=0;
end;
else if proxycrf02_complete=2 then do;
  sex                         =pxpcf_gender;
  raceWhite                   =(pxpcf_race___1=1 and 
                                not(pxpcf_race___2=1 or  
                                    pxpcf_race___3=1 or 
                                    pxpcf_race___4=1 or 
                                    pxpcf_race___5=1 or 
                                    pxpcf_race___6=1));
  raceBlack                   =(pxpcf_race___2=1 and 
                                not(pxpcf_race___1=1 or 
                                    pxpcf_race___3=1 or 
                                    pxpcf_race___4=1 or 
                                    pxpcf_race___5=1 or 
                                    pxpcf_race___6=1));
  raceOther                   =not(raceWhite) and not(raceBlack) and 
                               not(pxpcf_race___998=1) and not(pxpcf_race___999=1);
  if      missing(pxpcf_latino_hispanic) or
          pxpcf_latino_hispanic=998      or
          pxpcf_latino_hispanic=999      then hispanic=.;
  else if pxpcf_latino_hispanic=1        then hispanic=1;
  else                                      hispanic=0;
end;
quarterlyReportFractureType1=(inex_open_tibia_criteria___1);
quarterlyReportFractureType2=(inex_open_tibia_criteria___2);
quarterlyReportFractureType3=(inex_open_tibia_criteria___3);
quarterlyReportFractureType4=(inex_open_tibia_criteria___4);
quarterlyReportFractureType5=(inex_open_tibia_criteria___5);
defFixationDate             =dff_procedure_date;
run;

%mend make_addlQuarterlyData;
