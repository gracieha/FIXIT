/* ------------------------------------------------------------------------- */
/* 
   get items for Grace so she can complete additional monthly METRC-wide
   items 


/* ------------------------------------------------------------------------- */
/* set a macro variables */
%let sharedDrive      =\\sph-hpm\hpm\shares\METRC Data;
%let sourceDate       =01MAY2014;
%let sourceYear       =2014;
%let sourceMonth      =05;
%let sourceMonthAbbrev=May;
%let errorFile        =&sharedDrive.\fixit\data\monthly\&sourceYear..&sourceMonth.\FIXIT Monthly Report Error Flags.xls;

/* import utility macros and secondary programs */
%include "&sharedDrive.\_utilities\makeFolder.sas";

/* set an output folder */
%makeFolder(path="&sharedDrive.\fixit\output");

/* assign libraries */
libname monthly "&sharedDrive.\fixit\data\monthly\&sourceYear..&sourceMonth";
libname output  "&outputPath";

/* copy in data */
proc datasets;
copy in=monthly out=work;
select facilityData
       enrollmentData
	   visitData
	   deviationData
	   ;
quit;



/* leaderboard */
proc sql;
create table leaderboardFIXIT as (
select case
         when f.facility in ('UMN','HCM') then 'MIN'
         when f.facility in ('SJH','TGH') then 'FOI'
         else f.facility
       end as facilityCode,
       case
         when f.facility in ('UMN','HCM') then 'Core'
         when f.facility in ('SJH','TGH') then 'Core'
         else f.facilityType
       end as siteType,
	   count(distinct 
         case 
           when e.enrolled=1 then e.id
           else ''
          end) as enrolled&sourceMonthAbbrev.&sourceYear,
	   count(distinct 
         case 
           when e.group=1 and e.enrolled=1 then e.id
           else ''
         end) as enrolledRCT,
	   count(distinct
         case 
           when e.group=2 and e.enrolled=1 then e.id
		   else ''
		 end) as enrolledOBS,
	   (sum(monthlyReportVisitOccurred)/sum(monthlyReportVisitExpected))*100 as followup,
	   'FIX' as projectCode
from   (facilityData   (keep=facility facilityType)      f 
          left join
	    enrollmentData (keep=id facility enrolled group) e on e.facility=f.facility)
	      left join
	    visitData      (keep = id visit monthlyReportVisitOccurred 
                               monthlyReportVisitExpected
		                where=(visit in (1,2,3,4)))      v on e.id=v.id
group by calculated facilityCode, 
         calculated siteType);
quit;



/* upcoming visit report */
proc sql;
create table upcomingVisitFIXIT as (
select monthlyReportID              as finalID,
       monthlyReportCurrentFacility as transferCode,
       monthlyReportVisit           as visit,
	   windowStart                  as start,
	   windowEnd                    as end
from   visitData
where  visit in (1,2,3,4,5,6)    and 
       not(visitOccurred)        and
       not(deathDate)            and
	   not(withdrawalDate)       and
	   not(missing(windowStart)) and
	   not(missing(windowEnd))
  ) order by finalID, 
             monthlyReportCurrentFacility;
quit;



/* check for new facilities before running the following */
%macro checkForNewFacilities(n=); 
proc sql noprint; 
select count(distinct facility) into :nFacilities from facilityData where not(missing(dateCert));
%if &nFacilities > &n %then %put ERROR: Update code to account for new facility; 
quit; %put &nFacilities;
%mend checkForNewFacilities;
%checkForNewFacilities(n=31);



/* projection tool (screened) */
proc sql;
create table projectionScreenedFIXIT as (
  select input(put(screenAndEnrollDate, monyy5.), monyy5.) as monthYear format=mmddyy10.,
         sum(screened) as ALL,
		 sum(case
		       when screened=1 and facility='UMD' then 1
		       else 0
		     end) as UMD,
		 sum(case
		       when screened=1 and facility='CMC' then 1
		       else 0
		     end) as CMC,
		 sum(case
		       when screened=1 and facility='HOU' then 1
		       else 0
		     end) as HOU,
		 sum(case
		       when screened=1 and facility='WFU' then 1
		       else 0
		     end) as WFU,
         sum(case
		       when screened=1 and facility in ('HCM','UMN') then 1
		       else 0
		     end) as MIN,
		 sum(case
		       when screened=1 and facility='MET' then 1
		       else 0
		     end) as MET,
		 sum(case
		       when screened=1 and facility='ORL' then 1
		       else 0
		     end) as ORL,
		 sum(case
		       when screened=1 and facility='RYD' then 1
		       else 0
		     end) as RYD,
         sum(case
		       when screened=1 and facility in ('SJH','TGH') then 1
		       else 0
		     end) as FOI,
		 sum(case
		       when screened=1 and facility='PSU' then 1
		       else 0
		     end) as PSU,
		 sum(case
		       when screened=1 and facility='MTH' then 1
		       else 0
		     end) as MTH,
		 sum(case
		       when screened=1 and facility='UMS' then 1
		       else 0
		     end) as UMS,
		 sum(case
		       when screened=1 and facility='USF' then 1
		       else 0
		     end) as USF,
		 sum(case
		       when screened=1 and facility='BAM' then 1
		       else 0
		     end) as BAM,
		 sum(case
		       when screened=1 and facility='DHA' then 1
		       else 0
		     end) as DHA,
		 sum(case
		       when screened=1 and facility='ELP' then 1
		       else 0
		     end) as ELP,
         sum(case
		       when screened=1 and facility='VMC' then 1
		       else 0
		     end) as VMC,
         sum(case
		       when screened=1 and facility='WRD' then 1
		       else 0
		     end) as WRD,
         sum(case
		       when screened=1 and facility='STL' then 1
		       else 0
		     end) as STL,
         sum(case
		       when screened=1 and facility='UIA' then 1
		       else 0
		     end) as UIA,
         sum(case
		       when screened=1 and facility='BMC' then 1
		       else 0
		     end) as BMC,
         sum(case
		       when screened=1 and facility='STV' then 1
		       else 0
		     end) as STV,
         sum(case
		       when screened=1 and facility='NPM' then 1
		       else 0
		     end) as NPM,
         sum(case
		       when screened=1 and facility='DUK' then 1
		       else 0
		     end) as DUK,
         sum(case
		       when screened=1 and facility='UTX' then 1
		       else 0
		     end) as UTX,
         sum(case
		       when screened=1 and facility='ASH' then 1
		       else 0
		     end) as ASH,
         sum(case
		       when screened=1 and facility='AGY' then 1
		       else 0
		     end) as AGY,
         sum(case
		       when screened=1 and facility='NSD' then 1
		       else 0
		     end) as NSD,
         sum(case
		       when screened=1 and facility='SPC' then 1
		       else 0
		     end) as SPC
  from enrollmentData
  group by calculated monthYear);
quit;



/* projection tool (enrolled) */
proc sql;
create table projectionEnrolledFIXIT as (
  select input(put(screenAndEnrollDate, monyy5.), monyy5.) as monthYear format=mmddyy10.,
         sum(enrolled) as ALL,
		 sum(case
		       when enrolled=1 and facility='UMD' then 1
		       else 0
		     end) as UMD,
		 sum(case
		       when enrolled=1 and facility='CMC' then 1
		       else 0
		     end) as CMC,
		 sum(case
		       when enrolled=1 and facility='HOU' then 1
		       else 0
		     end) as HOU,
		 sum(case
		       when enrolled=1 and facility='WFU' then 1
		       else 0
		     end) as WFU,
         sum(case
		       when enrolled=1 and facility in ('HCM','UMN') then 1
		       else 0
		     end) as MIN,
		 sum(case
		       when enrolled=1 and facility='MET' then 1
		       else 0
		     end) as MET,
		 sum(case
		       when enrolled=1 and facility='ORL' then 1
		       else 0
		     end) as ORL,
		 sum(case
		       when enrolled=1 and facility='RYD' then 1
		       else 0
		     end) as RYD,
         sum(case
		       when enrolled=1 and facility in ('SJH','TGH') then 1
		       else 0
		     end) as FOI,
		 sum(case
		       when enrolled=1 and facility='PSU' then 1
		       else 0
		     end) as PSU,
		 sum(case
		       when enrolled=1 and facility='MTH' then 1
		       else 0
		     end) as MTH,
		 sum(case
		       when enrolled=1 and facility='UMS' then 1
		       else 0
		     end) as UMS,
		 sum(case
		       when enrolled=1 and facility='USF' then 1
		       else 0
		     end) as USF,
		 sum(case
		       when enrolled=1 and facility='BAM' then 1
		       else 0
		     end) as BAM,
		 sum(case
		       when enrolled=1 and facility='DHA' then 1
		       else 0
		     end) as DHA,
		 sum(case
		       when enrolled=1 and facility='ELP' then 1
		       else 0
		     end) as ELP,
         sum(case
		       when enrolled=1 and facility='VMC' then 1
		       else 0
		     end) as VMC,
         sum(case
		       when enrolled=1 and facility='WRD' then 1
		       else 0
		     end) as WRD,
         sum(case
		       when enrolled=1 and facility='STL' then 1
		       else 0
		     end) as STL,
         sum(case
		       when enrolled=1 and facility='UIA' then 1
		       else 0
		     end) as UIA,
         sum(case
		       when enrolled=1 and facility='BMC' then 1
		       else 0
		     end) as BMC,
         sum(case
		       when enrolled=1 and facility='STV' then 1
		       else 0
		     end) as STV,
         sum(case
		       when enrolled=1 and facility='NPM' then 1
		       else 0
		     end) as NPM,
         sum(case
		       when enrolled=1 and facility='DUK' then 1
		       else 0
		     end) as DUK,
         sum(case
		       when enrolled=1 and facility='UTX' then 1
		       else 0
		     end) as UTX,
         sum(case
		       when enrolled=1 and facility='ASH' then 1
		       else 0
		     end) as ASH,
         sum(case
		       when enrolled=1 and facility='AGY' then 1
		       else 0
		     end) as AGY,
         sum(case
		       when enrolled=1 and facility='NSD' then 1
		       else 0
		     end) as NSD,
         sum(case
		       when enrolled=1 and facility='SPC' then 1
		       else 0
		     end) as SPC
  from enrollmentData
  group by calculated monthYear);
quit;




/* protocol deviations (internal) */
data protocolDeviationsFIXIT
 (keep=id
       facility
       deviationDate
	   deviationDescription
	   deviationCorrection
  );
length id $12.;
set deviationData;
id   ='FIX'||'-'||facility||'-'||id;
array deviationDates pdf01_date 
                     pdf02_date 
                     pdf03_date 
                     pdf04_date 
                     pdf05_date
                     ;
array descriptions   pdf01_full_description
                     pdf02_full_description
                     pdf03_full_description
                     pdf04_full_description
                     pdf05_full_description
                     ;
array corrections    pdf01_correction
                     pdf02_correction
                     pdf03_correction
                     pdf04_correction
                     pdf05_correction
					 ;
do i=1 to 5;
  if not(missing(deviationDates[i])) then do;
    deviationDate         =deviationDates[i];
	deviationDescription  =descriptions[i];
	deviationCorrection   =corrections[i];
    output;
  end;
end;
format deviationDate mmddyy10.;
run;




/* missed visit report (internal) */
/* 1- get the error flags */
proc import 
  out     =MDC1Error2 
  datafile="&errorFile" 
  dbms    =xls 
  replace;
    sheet   ="MDC1Error2"; 
    getnames=yes;
    mixed   =yes;
run;

/* 2- process the error flags */
data MDC1Error2(keep=id visit explanation);
length id $4.;
set MDC1Error2(rename=(visit=tempVisit));
id = substr(studyid, 9);
if tempVisit ="Baseline" then visit=0;
if tempVisit ="6wk"      then visit=1;
if tempVisit ="3mo"      then visit=2;
if tempVisit ="6mo"      then visit=3;
if tempVisit ="12mo"     then visit=4;
if tempVisit ="18mo"     then visit=5;
if tempVisit ="24mo"     then visit=6;
if not(missing(id));
run;

/* 3- pull the records */
proc sort data=visitData;  by id visit; run;
proc sort data=mdc1error2; by id visit; run;
data missedVisitsFIXIT
 (keep=monthlyReportId   
       monthlyReportVisit
	   af03Provided      
	   af03Reason        
	   flag              
	   flagExplanation   
  );
length monthlyReportId     $12.
       monthlyReportVisit  $15.
	   af03Provided          8.
	   af03Reason         $500.
	   flag                  8.
	   flagExplanation    $500.
       ;
merge visitData
      mdc1error2 (in=e)
      ;
by id;
if visit in (1,2,3,4,5,6) and . < windowEnd < "&sourceDate"d+7 and not(visitOccurred);
af03Provided=completeAF03;
if missedReason=1   then af03Reason='Patient reported to clinic on wrong/different day';
if missedReason=2   then af03Reason='Patient illness / patient hospitalized';
if missedReason=3   then af03Reason='Transportation problem';
if missedReason=4   then af03Reason='Clinic error';
if missedReason=5   then af03Reason='Scheduling difficulties';
if missedReason=6   then af03Reason='Moved too far from clinic';
if missedReason=7   then af03Reason='Temporarily out of area';
if missedReason=8   then af03Reason='Patient incarcerated';
if missedReason=666 then af03Reason='Patient death';
if missedReason=777 then af03Reason='Unable to contact patient';
if missedReason=997 then af03Reason= missedReasonDesc;
if missedReason=998 then af03Reason='Patient refused to return' ;
flag           =e;
flagExplanation=explanation;
run;



/* send datasets to the output folder */
proc datasets;
copy in=work out=output;
select leaderboardFIXIT
       upcomingVisitFIXIT
       projectionScreenedFIXIT
       projectionEnrolledFIXIT
       protocolDeviationsFIXIT
       missedVisitsFIXIT
	   ;
quit;

