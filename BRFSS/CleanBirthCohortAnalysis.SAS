*-------------------------------------------------------------------*
 *  Author:  Fan Xiong            <fanxiong0728@gmail.com>           *
*-------------------------------------------------------------------*

/*This SAS program uses a %include to build the BRFSS data and KTRACS data for birth cohort analysis. Results are then combined by 
birthcohort and gender.*/

/*CLEANER CODE*/

%include "C:\TEMP\PBSS macros and documentation\Kansas\MACROS\BRFSS SAS 10.2.2017.sas";

%macro brfssfreq (i=,var=);
proc surveyfreq data=ksbrfss.ks1116 MISSING;
format PERSDOC_ provider. HIGHRISK1 HIGHRISK3 HVYALCOHOL diabetes arthritis CHD heartattack cancer skin stroke 
        kidney depression copd asthma PHYHLTH_  MNTHLTH_ disease. mcc_ mcc. genhlth_ health. employment workstatus. income2_ incomecat. educa_ educcat. marital_ marital. hlthpln1_ insurance. ;
tables BIRTHCOHORT*patient_gender*&VAR / ROW cl cv;
weight _LLCPWT;
STRATA _STSTR;

ODS OUTPUT CROSSTABS=KSBRFSS.TEST&VAR;

proc surveyfreq data=ksbrfss.ks1116 NOMCAR;
format  PERSDOC_ provider. HIGHRISK1 HIGHRISK3 HVYALCOHOL diabetes arthritis CHD heartattack cancer skin stroke 
        kidney depression copd asthma PHYHLTH_  MNTHLTH_ ANYALCOHOL disease. mcc_ mcc. genhlth_ health. employment workstatus. income2_ incomecat. educa_ educcat. marital_ marital. hlthpln1_ insurance. ;
tables BIRTHCOHORT*patient_gender*&VAR / COL cl cv;
weight _LLCPWT;
STRATA _STSTR;
ODS OUTPUT CROSSTABS=KSBRFSS.&VAR;

DATA ksbrfss.brfss&i (KEEP= BIRTHCOHORT patient_gender LEVEL VARN F_&VAR PERCENT&i COLCV&i WgtFreq&i Freq&i);
SET KSBRFSS.&VAR;
WHERE BIRTHCOHORT NE . and patient_gender IN ("M","F") AND F_&VAR NE "Total";
*IN ("Yes","Two or more chronic conditions",
			"Fair or Poor","Uninsured","Not currently married","No Work / Unable to Work/Student/Homemaker",
			"White, non-Hispanic","Less than $25,000","No physical activity or exercise in last 30 days",
			"Underweight/Overweight or Obese","Less than high school or High school graduate or G.E.D","No regular doctor/health-care provider"));
*IF RowCV < 0.30 THEN DO;
PERCENT&i = COLPercent;
WgtFreq&i=INT(WgtFreq);
Freq&i=Frequency;
LEVEL=F_&VAR;
VARN=&VAR+1;
COLCV&i = COLCV;
*END;
label PERCENT&i = "Percent &var";

proc sort data=ksbrfss.brfss&i ;
by BIRTHCOHORT patient_gender VARN;
proc transpose data=ksbrfss.brfss&i out=ksbrfss.brfssw&i (DROP=_NAME_) prefix=&VAR;
by BIRTHCOHORT patient_gender;
WHERE patient_gender IN ("M","F");
var PERCENT&i;
id VARN;
idlabel level;
RUN;
%mend;
%brfssfreq(i=0,var=ANYALCOHOL);

%brfssfreq(i=1,var=income2_);
%brfssfreq(i=2,var=genhlth_);
%brfssfreq(i=3,var=marital_);
%brfssfreq(i=4,var=hlthpln1_);
%brfssfreq(i=5,var=diabetes);
%brfssfreq(i=6,var=arthritis);
%brfssfreq(i=7,var=CHD);
%brfssfreq(i=8,var=heartattack);
%brfssfreq(i=9,var=cancer);
%brfssfreq(i=10,var=skin);
%brfssfreq(i=11,var=stroke);
%brfssfreq(i=12,var=kidney);
%brfssfreq(i=13,var=depression);
%brfssfreq(i=14,var=COPD);
%brfssfreq(i=15,var=asthma);
%brfssfreq(i=16,var=PHYHLTH_);
%brfssfreq(i=17,var=MNTHLTH_);
%brfssfreq(i=18,var=HIGHRISK1);
%brfssfreq(i=19,var=HIGHRISK3);
%brfssfreq(i=20,var=HVYALCOHOL);
%brfssfreq(i=21,var=PERSDOC_);
%brfssfreq(i=22,var=educa_);
%brfssfreq(i=23,var=EMPLOYMENT);


%macro append;
proc sort data=ksbrfss.brfssw1;
by BIRTHCOHORT patient_gender;
data ksbrfss.alldata;
set ksbrfss.brfssw0 (DROP=_LABEL_) ;

%do set = 1 %to 23;
proc sort data=ksbrfss.brfssw&SET;
by BIRTHCOHORT patient_gender;
data ksbrfss.alldata;
merge ksbrfss.alldata ksbrfss.brfssw&SET (DROP=_LABEL_) ;
by BIRTHCOHORT patient_gender;
IF BIRTHCOHORT GE 1930 and BIRTHCOHORT LE 1989;
RUN;
%END;
%mend;
%append;

LIBNAME CDC "C:\TEMP\SPACE";
RUN;
LIBNAME DATA "C:\TEMP\Space\MPE\DATA";
/*MPE RATES*/
%macro VIEWSUMMARY;
%do YEAR = 11 %to 17;
PROC SQL NOPRINT;
CREATE TABLE DATA.MPE&YEAR  AS SELECT 
numericid, patient_gender, patient_birthyear as BIRTHCOHORT,
yearf, qtrf,
COUNT(DISTINCT(prescriber)) as prescribers, 
COUNT(DISTINCT(dispensary)) as dispensaries, 
SUM(CASE WHEN OPIOID = "1" THEN 1 else . end) as OPIOIDRX,
SUM(mme_dd) as MMEDD,
SUM(Quantity_dispensed) as Quantity_dispensed,
SUM(dayssupply_dispensed) as dayssupply_dispensed,
SUM(CASE WHEN BENZO = "1" THEN 1 else . end) as BENZORX,
SUM(CASE WHEN STIMULANT = "1" THEN 1 else . end) as STIMULANTRX,
SUM(CASE WHEN MuscleRelaxant = "1" THEN 1 else . end) as MuscleRelaxantRX,
SUM(CASE WHEN MISC = "1" THEN 1 else . end) as MISCRX,

SUM(CASE WHEN Drug IN ("HydrocodoneSA","HydrocodoneLA") THEN 1 else . end) as HYDROCODONE,
SUM(CASE WHEN Drug IN ("OxycodoneSA","OxycodoneLA") THEN 1 else . end) as Oxycodone,
SUM(CASE WHEN Drug IN ("Zolpidem","Alprazolam","Diazepam") THEN 1 else . end) as ZOL_APLRA_DIAZE,
SUM(CASE WHEN Drug IN ("Carisoprodol") THEN 1 else . end) as Carisoprodol,
SUM(CASE WHEN Drug IN ("Amphetamine") THEN 1 else . end) as Amphetamine

FROM PBSS.NEWKTRACS&YEAR (WHERE=(statept = "KS" and DRUG NE "Buprenorphine" AND
						CSIIIV = "1" AND patient_identifier NE "   " and patient_gender IN ("M","F") and ("1899"<=patient_birthyear <= "1990"))
						KEEP=Drug ZIP_patient patient_city statept statedisp statepre CSIIIV numericid patient_identifier patient_gender 
						patient_birthyear yearf qtrf prescriber dispensary OPIOID mme_dd Quantity_dispensed dayssupply_dispensed
							 BENZO STIMULANT MuscleRelaxant MISC)  
GROUP BY numericid, BIRTHCOHORT, patient_gender,yearf, qtrf
ORDER BY numericid;
quit;
%END;
%mend;
%VIEWSUMMARY;

*Combine BRFSS and KTRACS BIRTH COHORT*/
LIBNAME KSBRFSS "H:\Health Promotion\Injury Disability\xiong_secure\BRFSS Work\KS BRFSS Datasets\Datasets";
LIBNAME MPE "C:\TEMP\Space\MPE";

PROC SQL NOPRINT;

CREATE TABLE MPE.DATACOHORTALL AS SELECT a.*, b.*
FROM MPE.KSALLCOHORT2 as a, KSBRFSS.ALLDATA as b 
WHERE a.patient_gender=b.patient_gender and a.cohortpopulation=b.cohortpopulation;
QUIT;

PROC EXPORT DATA=MPE.DATACOHORTALL OUTFILE="C:\TEMP\Space\MPE\DATA\KSBRFSS_KTRACS_COHORT.XLS" DBMS=XLS REPLACE;
RUN;

