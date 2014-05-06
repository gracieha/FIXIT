/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
   Run query3: Get incomplete forms when there is evidence of a visit 


/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */


%macro run_report1_q3(baseData=, errorData=, sourceDate= );

/* process the error flags */
proc sql;
create table error3 as (
select put(substr(studyid, 9), $4.) as id,
       case 
         when visit ="Baseline" then 0
         when visit ="6wk"      then 1
         when visit ="3mo"      then 2
         when visit ="6mo"      then 3
         when visit ="12mo"     then 4
		 else .
	   end as visit,
	   case when sum(CRF="CRF00") >=1 then 1 else 0 end as suppressQ3CRF00,
	   case when sum(CRF="CRF02") >=1 then 1 else 0 end as suppressQ3CRF02,
	   case when sum(CRF="CRF03") >=1 then 1 else 0 end as suppressQ3CRF03,
	   case when sum(CRF="CRF04") >=1 then 1 else 0 end as suppressQ3CRF04,
	   case when sum(CRF="CRF05") >=1 then 1 else 0 end as suppressQ3CRF05,
	   case when sum(CRF="CRF06") >=1 then 1 else 0 end as suppressQ3CRF06,
	   case when sum(CRF="CRF07") >=1 then 1 else 0 end as suppressQ3CRF07,
	   case when sum(CRF="CRF14") >=1 then 1 else 0 end as suppressQ3CRF14,
	   case when sum(CRF="CRF15") >=1 then 1 else 0 end as suppressQ3CRF15,
	   case when sum(CRF="CRF16") >=1 then 1 else 0 end as suppressQ3CRF16,
	   case when sum(CRF="CRF17") >=1 then 1 else 0 end as suppressQ3CRF17,
	   case when sum(CRF="CRF18") >=1 then 1 else 0 end as suppressQ3CRF18,
	   case when sum(CRF="CRF19") >=1 then 1 else 0 end as suppressQ3CRF19,
	   case when sum(CRF="CRF20") >=1 then 1 else 0 end as suppressQ3CRF20,
	   case when sum(CRF="CRF21") >=1 then 1 else 0 end as suppressQ3CRF21,
	   case when sum(CRF="CRF22") >=1 then 1 else 0 end as suppressQ3CRF22,
	   case when sum(CRF="CRF23") >=1 then 1 else 0 end as suppressQ3CRF23,
	   case when sum(CRF="CRF24") >=1 then 1 else 0 end as suppressQ3CRF24,
	   case when sum(CRF="CRF25") >=1 then 1 else 0 end as suppressQ3CRF25,
	   case when sum(CRF="CRF26") >=1 then 1 else 0 end as suppressQ3CRF26,
	   case when sum(CRF="CRF27") >=1 then 1 else 0 end as suppressQ3CRF27,
	   case when sum(CRF="CRF28") >=1 then 1 else 0 end as suppressQ3CRF28,
	   case when sum(CRF="CRF29") >=1 then 1 else 0 end as suppressQ3CRF29,
	   case when sum(CRF="CRF30") >=1 then 1 else 0 end as suppressQ3CRF30,
	   case when sum(CRF="CRF31") >=1 then 1 else 0 end as suppressQ3CRF31,
	   case when sum(CRF="CRF32") >=1 then 1 else 0 end as suppressQ3CRF32
  from &errorData
  group by id, visit) order by id, visit;
quit;


/* Query 3: Get incomplete forms when there is evidence of a visit */
proc sort data=&baseData; by id visit; run;
proc sort data=error3;    by id visit; run;
data report1_q3(keep=id
                     monthlyReportId 
                     monthlyReportFacility 
                     monthlyReportCurrentFacility 
                     monthlyReportVisit 
                     crf 
                     explanation);
merge &baseData (in=v)
      error3
      ;
by id visit;
if v;
if visitOccurred=1;
if windowEnd+7 <= "&sourceDate"d or 
   visitDate+7 <= "&sourceDate"d;
if (visit=-1 and not(completeCRF00)                                                                   or
   (visit =0 and 0 < sum(of completeCRF02-completeCRF07) and sum(of completeCRF02-completeCRF07) < 6) or
   (visit =1 and 0 < sum(of touchCRF14-touchCRF16)       and sum(of completeCRF14-completeCRF16) < 3) or
   (visit =2 and 0 < sum(of touchCRF17-touchCRF19)       and sum(of completeCRF17-completeCRF19) < 3) or
   (visit =3 and 0 < sum(of touchCRF20-touchCRF24)       and sum(of completeCRF20-completeCRF24) < 5) or
   (visit =4 and 0 < sum(of touchCRF25-touchCRF32)       and sum(of completeCRF25-completeCRF32) < 8) 
   );
array completeCRFs[26] completeCRF00   completeCRF02  -completeCRF07   completeCRF14  -completeCRF32;
array suppressCRFs[26] suppressQ3CRF00 suppressQ3CRF02-suppressQ3CRF07 suppressQ3CRF14-suppressQ3CRF32;
array CRFs [26] $ _TEMPORARY_ ('CRF00'
                               'CRF02' 'CRF03' 'CRF04' 'CRF05' 'CRF06' 'CRF07' 
                               'CRF14' 'CRF15' 'CRF16' 'CRF17' 'CRF18' 'CRF19'
                               'CRF20' 'CRF21' 'CRF22' 'CRF23' 'CRF24' 'CRF25'
                               'CRF26' 'CRF27' 'CRF28' 'CRF29' 'CRF30' 'CRF31' 
                               'CRF32' )
				           		;
do i=1 to 26;
  if completeCRFs[i]=0 and suppressCRFs[i]^=1 then do;
    crf=CRFs[i];
	explanation='';
    output;
  end;
end;
run;
proc sort data=report1_q3; by monthlyReportId monthlyReportVisit crf; run;


%mend run_report1_q3;



