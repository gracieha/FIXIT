
%macro make_facilityData(mccdbTable1=, mccdbTable2=, registryTable=, sourceDate= );

/* put together to get days certified and expected screened */
proc sort data=&mccdbTable1;   by sitecode;      run;
proc sort data=&mccdbTable2;   by sitecode;      run;
proc sort data=&registryTable; by facility_code; run;
data facilityData(keep=facility facilityType dateCert daysCert expectedScreened 
                       dateLocalIRBApproval dateDODApproval);
merge &mccdbTable1(where=(studyName='FIXIT'))
      &mccdbTable2
	  &registryTable (rename=(facility_code=siteCode))
	  ;
by siteCode;
if (SiteType in ('MTF', 'Core') and 
    status not in ('',  'Not Invited to Participate', 'Declined to participate', 
                   'Withdrew from participating'))
	  or
   (SiteType in ('Satellite') and 
    status not in ('1. Plans to participate', '',  'Not Invited to Participate', 
                   'Declined to participate', 'Withdrew from participating'));
facility            =SiteCode;
facilityType        =SiteType;
dateCert            =LocalSiteMCC_CertificationDate;
daysCert            ="&sourceDate"d-dateCert;
expectedScreened    =daysCert *(FIX/365);
dateLocalIRBApproval=LocalSiteIRB_ApprovalDate;
dateDODApproval     =LocalSite_DoD_ApprovalDate;
run;


%mend make_facilityData;
