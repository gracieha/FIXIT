%macro make_deviationData(redcapData= );

data deviationData;
length id       $4.
       facility $3.
	   ;
merge redcapData 
       (keep =study_id
	          facilitycode
			  redcap_event_name
	    where=(redcap_event_name="baseline_arm_1"))
      redcapData
       (keep= study_id
		      redcap_event_name
              sae01_sae_date sae02_sae_date sae03_sae_date
              sae01_sae_type sae02_sae_type sae03_sae_type
              crf10_complete_01 crf10_complete_02 crf10_complete_03
              pdf01_date pdf02_date pdf03_date pdf04_date pdf05_date
              pdf01_full_description
              pdf02_full_description
              pdf03_full_description
              pdf04_full_description
              pdf05_full_description
              pdf01_correction
              pdf02_correction
              pdf03_correction
              pdf04_correction
              pdf05_correction
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
  rename=(redcap_event_name=temp_name)
  where =(temp_name="admin_arm_1"));
by study_id;
if n(of pdf01_date pdf02_date pdf03_date pdf04_date pdf05_date) >0;
id       =input(study_id, $4.);
facility =input(facilitycode, $3.);
run;

%mend make_deviationData;
