/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query1: Check for AF03 in the case of an out-of-window visit 

/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */


%macro run_report1_q1(baseData=, errorData=, sourceDate= );

/* process the error flags */
data error1(keep=id visit suppressQ1);
length id $4.;
set &errorData(rename=(visit=tempVisit));
id = substr(studyid, 9);
if tempVisit ="Baseline" then visit=0;
if tempVisit ="6wk"      then visit=1;
if tempVisit ="3mo"      then visit=2;
if tempVisit ="6mo"      then visit=3;
if tempVisit ="12mo"     then visit=4;
if not(missing(id));
suppressQ1=1;
run;


/* pull the query */
proc sort data=&baseData; by id visit; run;
proc sort data=error1;    by id visit; run;
data report1_q1(keep=id
                     monthlyReportId 
                     monthlyReportFacility 
                     monthlyReportCurrentFacility 
                     monthlyReportVisit 
                     visitDate 
                     windowStart 
                     windowEnd 
                     explanation); 
merge &baseData (in=v)
      error1    
      ; 
by id visit;
if v;
if (visitOccurred=1                            and 
    visit in (1,2,3,4)                         and  
    not(missing(visitDate))                    and 
    not(missing(windowStart))                  and 
    not(missing(windowEnd))                    and
    not(windowStart <= visitDate <= windowEnd) and 
	 (windowEnd+7  <= "&sourceDate"d or
	  visitDate+7  <= "&sourceDate"d)         and           
    not(completeAF03=1 and missedType=1)   and
    not(suppressQ1)
    );
explanation='';
run;
proc sort data=report1_q1; by monthlyReportId monthlyReportVisit; run;


%mend run_report1_q1;



