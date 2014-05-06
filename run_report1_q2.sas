/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query2: Check for AF03 in the case of a missed visit 


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */


%macro run_report1_q2(baseData=, errorData=, sourceDate= );

/* process the error flags */
data error2(keep=id visit suppressQ2);
length id $4.;
set &errorData(rename=(visit=tempVisit));
id = substr(studyid, 9);
if tempVisit ="Baseline" then visit=0;
if tempVisit ="6wk"      then visit=1;
if tempVisit ="3mo"      then visit=2;
if tempVisit ="6mo"      then visit=3;
if tempVisit ="12mo"     then visit=4;
if not(missing(id));
suppressQ2=1;
run;

/* pull the query */
proc sort data=&baseData; by id visit; run;
proc sort data=error2;    by id visit; run;
data report1_q2(keep=id
                     monthlyReportId 
                     monthlyReportFacility 
                     monthlyReportCurrentFacility 
                     monthlyReportVisit 
                     windowStart 
                     windowEnd 
                     explanation); 
merge &baseData (in=v)
      error2
      ;
by id visit;
if v;
if windowEnd+7 < "&sourceDate"d;
if (visitOccurred in(.,0)                and
    visit in (1,2,3,4)                   and
    not(missing(windowStart))            and
	not(missing(windowEnd))              and
    not(. < deathDate      <= windowEnd) and
	not(. < withdrawalDate <= windowEnd) and 
    not(completeAF03=1 and missedType=0 ) and
    not(suppressQ2));
explanation='';
run;
proc sort data=report1_q2; by monthlyReportId monthlyReportVisit; run;


%mend run_report1_q2;



