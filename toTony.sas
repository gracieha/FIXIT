/* send FIXIT visit data to Tony for STREAM study */

/* set locations */
%let sharedDrive =\\sph-hpm\hpm\shares\METRC Data;
%let sourceDate  =01MAY2014;
%let sourceYear  =2014;
%let sourceMonth =05;

/* import utility macros and secondary programs */
%include "&sharedDrive.\_utilities\makeFolder.sas";

/* set an output folder */
%makeFolder(path="&sharedDrive.\fixit\output");

/* assign libraries */
libname monthly "&sharedDrive.\fixit\data\monthly\&sourceYear..&sourceMonth";
libname output  "&outputPath";

/* get visit data, restrict to completed visits, add study code, and
   send desired variables */
data output.fixitVisitData
    (keep=study_id
        projectcode 
        facilitycode 
        visit 
        visitDate);
length study_id     $4.
       projectcode  $3.
	   facilitycode $3.
	   visit        $10.
	   visitDate     8.
	   ;
set monthly.visitData
  (keep=id 
        facility 
		monthlyReportVisitOccurred
        visit 
        visitDate
   rename=(visit=origVisit));
if monthlyReportVisitOccurred;
if origVisit in (2,3,4);
if origVisit=2 then visit='3mo';
if origVisit=3 then visit='6mo';
if origVisit=4 then visit='12mo';
projectcode ='FIX';
study_id    =id;
facilitycode=facility;
run;
