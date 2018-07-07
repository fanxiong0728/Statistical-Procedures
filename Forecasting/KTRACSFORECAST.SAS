*-------------------------------------------------------------------*
 *  Author:  Fan Xiong            <fanxiong0728@gmail.com>           *
*-------------------------------------------------------------------*

/*This SAS program builds an analytical file for analysis using KTRACS PDMP data.*/
/*This SAS program also uses PROC FORECAST to create predicted counts of prescription opioid drugs reported to KTRACS.*/

/*Daily KTRACS OPIOID TREND*/

LIBNAME KTRACS "C:\TEMP\KTRACS BACKUP\PBSS FILES\KTRACS";
LIBNAME PBSS "C:\TEMP\KTRACS BACKUP\PBSS FILES\PBSS";
libname backup "H:\Health Promotion\Injury Disability\secure_injury_data\PDMP\BACKUPS DO NOT OVERWRITE";

LIBNAME DATA "C:\TEMP\KTRACS BACKUP\DATA";

DATA KTRACS.EXTRACT / VIEW=KTRACS.EXTRACT;
SET backup.NEWKTRACS15  (WHERE=(statept="KS" and opioid="1") KEEP=statept opioid written_date_c filled_date_C prescription_number drug patient_identifier dayssupply_dispensed mme_dd)
backup.NEWKTRACS16  (WHERE=(statept="KS" and opioid="1") KEEP=statept opioid written_date_c filled_date_C prescription_number drug patient_identifier dayssupply_dispensed mme_dd) 
backup.NEWKTRACS17  (WHERE=(statept="KS" and opioid="1") KEEP=statept opioid written_date_c filled_date_C prescription_number drug patient_identifier dayssupply_dispensed mme_dd);

IF OPIOID="1" THEN OPIOIDRX=1;
else OPIOIDRX=0;

IF mme_dd GE 90 THEN MME90RX=1;
else MME90RX=0;

IF mme_dd GE 100 THEN MME100RX=1;
else MME100RX=0;

/*Risk of OUD by Dose and Days of Supply*/

PROC SQL NOPRINT;
CREATE TABLE KTRACS.OUDRISK AS 

select patient_identifier as patient,
SUM(MME_DD) as TOTAL_MMEDD,
SUM(OPIOIDRX) as OPIOIDRX,
SUM(MME90RX) as MME90RX,
SUM(MME100RX) as MME100RX,
SUM(dayssupply_dispensed) as dayssupply_dispensed,

COUNT(DISTINCT( CASE WHEN OPIOID="1"  THEN patient_identifier END)) as OPIOIDPT,
COUNT(DISTINCT( CASE WHEN mme_dd GE 90  THEN patient_identifier  END)) as MME90PT,
COUNT(DISTINCT( CASE WHEN mme_dd GE 100  THEN patient_identifier  END)) as MME100PT

FROM KTRACS.EXTRACT
GROUP BY patient_identifier
ORDER BY patient_identifier;
QUIT;

DATA KTRACS.OUDRISK;
SET KTRACS.OUDRISK;
IF patient NE "  ";
LENGTH DOSE_DURATION $55.;
IF MME100RX GE 1 AND dayssupply_dispensed < 90 THEN DOSE_DURATION="High-Dose, Short-Duration";
IF MME100RX GE 1 AND dayssupply_dispensed >= 90 THEN DOSE_DURATION="High-Dose, Long-Duration";

IF MME100RX = 0 AND dayssupply_dispensed < 90 THEN DOSE_DURATION="Low-Dose, Short-Duration";
IF MME100RX = 0 AND dayssupply_dispensed >= 90 THEN DOSE_DURATION="Low-Dose, Long-Duration";
RUN;


PROC FREQ DATA=KTRACS.OUDRISK NOPRINT;
TABLE DOSE_DURATION / OUT=KTRACS.OUDRISK2;
RUN;

DATA KTRACS.OUDRISK2;
SET KTRACS.OUDRISK2;

/*Expected Number of Patients with Diagnosed-OUD*/

IF DOSE_DURATION="High-Dose, Short-Duration" THEN EXPECTED_OUD=COUNT*(62/1000);
IF DOSE_DURATION="High-Dose, Long-Duration" THEN EXPECTED_OUD=COUNT*(40/1000);
IF DOSE_DURATION="Low-Dose, Short-Duration" THEN EXPECTED_OUD=COUNT*(1.5/1000);
IF DOSE_DURATION="Low-Dose, Long-Duration" THEN EXPECTED_OUD=COUNT*(6/1000);
RUN;

proc export data=KTRACS.OUDRISK2 OUTFILE="H:\Health Promotion\Grants\Prescription Drug Overdose\DDPI Y2 APR\BRFSS Proposal\OUDRISK.XLS" DBMS=XLS REPLACE;
RUN;

PROC SQL NOPRINT;
CREATE TABLE KTRACS.DAILYOPIOID AS 

select filled_date_c as FDATE, 
SUM(MME_DD) as TOTAL_MMEDD,
SUM(OPIOIDRX) as OPIOIDRX,
SUM(MME90RX) as MME90RX,
SUM(MME100RX) as MME100RX,
COUNT(DISTINCT( CASE WHEN OPIOID="1"  THEN patient_identifier END)) as OPIOIDPT,
COUNT(DISTINCT( CASE WHEN mme_dd GE 90  THEN patient_identifier  END)) as MME90PT,
COUNT(DISTINCT( CASE WHEN mme_dd GE 100  THEN patient_identifier  END)) as MME100PT

FROM KTRACS.EXTRACT
GROUP BY FDATE
ORDER BY FDATE;
QUIT;

proc timeseries data=KTRACS.DAILYOPIOID OUT=KTRACS.DAILYOPIOID2;
ID FDATE INTERVAL=MONTH START="04JAN2015"d END="30DEC2017"d ACCUMULATE=TOTAL;
VAR TOTAL_MMEDD OPIOIDRX MME90RX OPIOIDPT MME90PT;
RUN;

title1 "Opioid Prescriptions Reported to KTRACS by Kansas Residents by Week, January 4, 2015 to December 30, 2017";
proc sgplot data=KTRACS.DAILYOPIOID2;
   series x=FDATE y=OPIOIDRX / markers markerattrs=(symbol=circlefilled);
   format date MMDDYY10.;
   LABEL FDATE = "Filled Date Week";
   LABEL OPIOIDRX ="Number of Opioid Prescriptions";
run;
title1 "Opioid Prescriptions with 90+ Daily MME Reported to KTRACS by Kansas Residents by Week, January 4, 2015 to December 30, 2017";
proc sgplot data=KTRACS.DAILYOPIOID2;
   series x=FDATE y=MME90RX / markers markerattrs=(symbol=circlefilled);
   format date MMDDYY10.;
   LABEL FDATE = "Filled Date Week";
   LABEL MME90RX ="Number of Opioid Prescriptions with 90+ Daily MME";
run;

DATA KTRACS.DAILYOPIOID2;
SET KTRACS.DAILYOPIOID2;
LN_OPIOIDRX=LOG(OPIOIDRX);
RUN;
proc forecast data=KTRACS.DAILYOPIOID2 interval=MONTH
              method=STEPAR trend=2 lead=12 SEASONS=3
              out=KTRACS.out outfull outest=KTRACS.est;
   id FDATE;
   var LN_OPIOIDRX OPIOIDRX MME90RX;
run;


title1 "Forecasting Prescription Opioids Using the STEPAR Method";
proc sgplot data=KTRACS.out;
   series x=FDATE y=OPIOIDRX / group=_type_;
   format FDATE MMDDYY10.;
   LABEL FDATE = "Filled Date Week";
   LABEL MME90RX ="Number of Opioid Prescriptions with 90+ Daily MME";
   LABEL OPIOIDRX ="Number of Opioid Prescriptions";
run;

title1 "Forecasting Prescription Opioids Using the STEPAR Method";
proc sgplot data=KTRACS.out;
   series x=FDATE y=MME90RX / group=_type_;
   format Fdate MMDDYY10.;
   LABEL FDATE = "Filled Date Week";
   LABEL MME90RX ="Number of Opioid Prescriptions with 90+ Daily MME";
   LABEL OPIOIDRX ="Number of Opioid Prescriptions";
run;

proc import datafile="H:\Health Promotion\Injury Disability\secure_injury_data\Tableau Dashboard Materials\Data\KTRACS\KTRACS20142018.xls" DBMS=XLS 
OUT=KTRACS.APPRISS1418 REPLACE;
RUN;
DATA KTRACS.APPRISS1418;
SET KTRACS.APPRISS1418;
LN_RX=LOG(Prescription_Count);
RUN;

proc forecast data=KTRACS.APPRISS1418 interval=MONTH
              method=STEPAR trend=2 lead=12 SEASONS=6
              out=KTRACS.APPRISS1418B outfull outest=KTRACS.estAPPRISS;
   id Month_of_Calendar_Month_End_Date;
   var LN_RX Prescription_Count Opioid_Days_Supply;
run;

title1 "Forecasting Prescription Opioids Using the ADDWINTER Method";
proc sgplot data=KTRACS.APPRISS1418B;
   series x=Month_of_Calendar_Month_End_Date y=Prescription_Count / group=_type_;
   format Month_of_Calendar_Month_End_Date MMDDYY10.;
   LABEL Month_of_Calendar_Month_End_Date = "Filled Month";
   LABEL Prescription_Count ="Number of Opioid Prescriptions";
   LABEL Opioid_Days_Supply ="Average Opioid Days of Supply Dispensed";
run;

PROC SQL NOPRINT;
CREATE TABLE KTRACS.CHECKFORECAST AS 

SELECT A.Month_of_Calendar_Month_End_Date as FILLED_MONTH, B.FDATE as DE_FDATE, 
a.Prescription_Count, a.Opioid_Days_Supply, a.LN_RX, b.LN_OPIOIDRX, b.OPIOIDRX, b.MME90RX, a._TYPE_ 
FROM KTRACS.APPRISS1418B as a 
						left join KTRACS.out as b on COMPRESS(PUT(a.Month_of_Calendar_Month_End_Date,MONYY7.)) = COMPRESS(PUT(b.FDATE,MONYY7.))

					order by a._TYPE_,FILLED_MONTH;
						QUIT;


title1 "Forecasting Prescription Opioids Using the ADDWINTER Method";
proc sgplot data=KTRACS.CHECKFORECAST;
   series x=FILLED_MONTH y=Prescription_Count / group=_type_;
   format FILLED_MONTH MMDDYY10.;
   LABEL FILLED_MONTH = "Filled Month";
   LABEL Prescription_Count ="Number of Opioid Prescriptions with 90+ Daily MME";
   LABEL Opioid_Days_Supply ="Average Opioid Days of Supply Dispensed";
title1 "Forecasting Prescription Opioids Using the ADDWINTER Method";
proc sgplot data=KTRACS.CHECKFORECAST;
   series x=FILLED_MONTH y=OPIOIDRX / group=_type_;
   format FILLED_MONTH MMDDYY10.;
run;

proc sgscatter data=KTRACS.CHECKFORECAST;
BY _TYPE_;
compare x=(OPIOIDRX) y=(Prescription_Count) / reg=(degree=2);
RUN;

PROC REG data=KTRACS.CHECKFORECAST;
BY _TYPE_;
MODEL Prescription_Count = OPIOIDRX;
RUN;

PROC REG data=KTRACS.CHECKFORECAST;
BY _TYPE_;
MODEL LN_RX = LN_OPIOIDRX;
RUN;

title1 "Forecasting Prescription Opioids Using the ADDWINTER Method";
proc sgplot data=KTRACS.CHECKFORECAST;
   series x=FILLED_MONTH y=Prescription_Count / group=_type_;
   format FILLED_MONTH MMDDYY10.;
   LABEL FILLED_MONTH = "Filled Month";
proc sgplot data=KTRACS.CHECKFORECAST;
   series x=FILLED_MONTH y=LN_RX / group=_type_;
   format FILLED_MONTH MMDDYY10.;
run;

PROC CORR DATA=KTRACS.CHECKFORECAST;
VAR Prescription_Count LN_RX;
WITH OPIOIDRX LN_OPIOIDRX;
RUN;
