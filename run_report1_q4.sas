/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query4: Identify cases where a final visit form should be submitted


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */


%macro run_report1_q4(baseData=, errorData=, sourceDate= );


/* process the error flags */
/* none at this time       */
data error4;
set &errorData;
id   ='0000';
visit=0;
run;
 
/* pull the query */
proc sort data=&baseData; by id visit; run;
proc sort data=error4;    by id visit; run;
data report1_q4(keep=id
                     monthlyReportId 
                     monthlyReportFacility 
                     monthlyReportCurrentFacility 
                     monthlyReportVisit 
                     reason 
                     explanation);

merge &baseData (in=v)
      error4
      ;
by id visit;
if v;
if first.id and completeAF01 in (.,0) and saeDeath=1 then do;
  reason="Death";
  explanation='';
  output;
end;
else if completeAF01 in (.,0) and 
        visit=4               and 
        visitOccurred =1      and 
        . < windowEnd <= "&sourceDate"d-7
  then do;
    reason="Final Visit";
    explanation='';
  output;
end;
run;
proc sort data=report1_q4; by monthlyReportId reason; run;


%mend run_report1_q4;



