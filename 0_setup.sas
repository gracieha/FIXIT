/* ------------------------------------------------------------------------- */
/* 
   This program imports redcap data, registry files, mcc db files and error 
   flags, sets the data for the monthly enrollment and visit tables, 
   runs queries, and exports to this months data drive


/* ------------------------------------------------------------------------- */
/* set a macro variable to hold the shared drive root location
   and source file containing the redcap csv export */
%let sharedDrive =\\sph-hpm\hpm\shares\METRC Data;
%let sourceFile  =&sharedDrive.\fixit\data\REDCap\METRCFIXIT_DATA_NOHDRS_2014-05-01_0403.csv;
%let sourceDate  =01MAY2014;
%let sourceYear  =2014;
%let sourceMonth =05;
%let errorFile   =&sharedDrive.\fixit\data\monthly\&sourceYear..&sourceMonth.\FIXIT Monthly Report Error Flags.xls;
%let mccdbFile   =&sharedDrive.\fixit\data\monthly\&sourceYear..&sourceMonth.\METRC Database IRB Information &sourceYear.&sourceMonth.01.xls;
%let registryFile=&sharedDrive.\fixit\data\monthly\&sourceYear..&sourceMonth.\registry.csv;
%let logFile     =&sharedDrive.\fixit\data\monthly\&sourceYear..&sourceMonth.\METRCFIXIT_Logging_2014-05-01_0403.csv;

/* assign libraries */
libname monthly "&sharedDrive.\fixit\data\monthly\&sourceYear..&sourceMonth";
*libname quartly "&sharedDrive.\fixit\data\quarterly\&sourceYear..&sourceMonth";


/* get macro definitions */
%include "&sharedDrive.\fixit\programs\monthly\import_REDCap.sas";
%include "&sharedDrive.\fixit\programs\monthly\make_enrollmentData.sas";
%include "&sharedDrive.\fixit\programs\monthly\make_facilityData.sas";
%include "&sharedDrive.\fixit\programs\monthly\make_visitData.sas";
%include "&sharedDrive.\fixit\programs\monthly\make_deviationData.sas";
%include "&sharedDrive.\fixit\programs\monthly\make_addlQuarterlyData.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report1_q1.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report1_q2.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report1_q3.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report1_q4.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report2_q1.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report2_q2.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report2_q3.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report2_q4.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report2_q5.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report2_q6.sas";
%include "&sharedDrive.\fixit\programs\monthly\run_report2_q7.sas";


/* get the .csv file exported from REDCap */
%import_REDCap(inFile="&sourceFile", datasetName=redcapData, forReports=yes);


/* Get the info from the MCC DB  */
%macro get_mccdb(sheet=, mccdbFile= );
proc import 
  out     =&sheet 
  datafile="&mccdbFile"
  dbms    =xls 
  replace;
    sheet   ="&sheet"; 
    getnames=yes;
    mixed   =yes;
run;
%mend get_mccdb;
%get_mccdb(sheet=tblstudylocal, mccdbFile=&mccdbFile);
%get_mccdb(sheet=tblsites,      mccdbFile=&mccdbFile);


/* get the registry info */
proc import 
  out     =registry 
  datafile="&registryFile"
  dbms    =csv 
  replace;
run;


/* get the external error spreadsheets used to suppress query items */
%macro get_errorFlags(sheet= , errorFile= );
proc import 
  out     =&sheet 
  datafile="&errorFile" 
  dbms    =xls 
  replace;
    sheet   ="&sheet"; 
    getnames=yes;
    mixed   =yes;
run;
%mend get_errorFlags;
%get_errorFlags(sheet=MDC1Error1, errorFile=&errorFile);
%get_errorFlags(sheet=MDC1Error2, errorFile=&errorFile);
%get_errorFlags(sheet=MDC1Error3, errorFile=&errorFile);
%get_errorFlags(sheet=MDC1Error4, errorFile=&errorFile);
%get_errorFlags(sheet=MDC2Error1, errorFile=&errorFile);
%get_errorFlags(sheet=MDC2Error2, errorFile=&errorFile);
%get_errorFlags(sheet=MDC2Error3, errorFile=&errorFile);
%get_errorFlags(sheet=MDC2Error4, errorFile=&errorFile);
%get_errorFlags(sheet=MDC2Error5, errorFile=&errorFile);
%get_errorFlags(sheet=MDC2Error6, errorFile=&errorFile);
%get_errorFlags(sheet=MDC2Error7, errorFile=&errorFile);


/* get the logfile, keeping only site users */
data logFile (drop=datetime);
infile "&logFile" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ; 
informat datetime $20. 
         user     $50. 
         action   $200.
         details  $10000.
         ;
format datetime $20. 
       user     $50.
       action   $200.
       details  $10000.
       ;
input datetime $
      user     $
      action   $
      details  $
      ;
timestamp=input(compress(scan(datetime,1,' '),'-'),yymmdd8.);
if not(upcase(user) in('ACARLINI','AHACKMAN','BDYER','CCHAVIS',
                       'GCLEMENS','GHA','GMETTEE','JDESANTO','JLULY',
                       'KFREY', 'LALLEN','LREIDER','MZADNIK','RCASTILL',
                       'RKIRK','SCOLLINS','SHEINS','SSAMUDRALA','TTAYLOR'));
run;


/* create a dataset with facility info */
%make_facilityData(mccdbTable1=tblstudylocal, mccdbTable2=tblsites, 
                   registryTable=registry, sourceDate=&sourceDate);

/* create a dataset with enrollment info */
%make_enrollmentData(redcapData=redcapData);

/* create a dataset with visit info, along with CRF completeness for the visits */
%make_visitData(redcapData=redcapData, logFile=logFile, sourceDate=&sourceDate);

/* get deviation data */
%make_deviationData(redcapData=redcapData);

/* create a dataset with days to fixation, fracture type, gender, race, and
   ethnicity used in the quarterly and DSMB reports */
%make_addlQuarterlyData(redcapData=redcapData);

/* run the queries on the above datasets */
%run_report1_q1(baseData=visitData,  errorData=MDC1Error1, sourceDate=&sourceDate );
%run_report1_q2(baseData=visitData,  errorData=MDC1Error2, sourceDate=&sourceDate );
%run_report1_q3(baseData=visitData,  errorData=MDC1Error3, sourceDate=&sourceDate );
%run_report1_q4(baseData=visitData,  errorData=MDC1Error4, sourceDate=&sourceDate );
%run_report2_q1(baseData=redcapData, errorData=MDC2Error1, sourceDate=&sourceDate );
%run_report2_q2(baseData=redcapData, errorData=MDC2Error2, sourceDate=&sourceDate );
%run_report2_q3(baseData=redcapData, errorData=MDC2Error3, sourceDate=&sourceDate );
%run_report2_q4(baseData=redcapData, errorData=MDC2Error4, sourceDate=&sourceDate );
%run_report2_q5(baseData=redcapData, errorData=MDC2Error5, sourceDate=&sourceDate );
%run_report2_q6(baseData=redcapData, errorData=MDC2Error6, sourceDate=&sourceDate );
%run_report2_q7(baseData=redcapData, errorData=MDC2Error7, sourceDate=&sourceDate );


/* export everything to this months data drive */
proc datasets;
copy in=work out=monthly;
select enrollmentData 
       facilityData
       visitData
	   deviationData
       report1_q1
       report1_q2
	   report1_q3
	   report1_q4
	   report2_q1
	   report2_q2
	   report2_q3
	   report2_q4
	   report2_q5
	   report2_q6
	   report2_q7
	   ;
quit;

/* export everything to quarterly data drive if using */
/*
proc datasets;
copy in=work out=quartly;
select enrollmentData 
       facilityData
       visitData
       addlQuarterlyData
       ;
quit;
*/
