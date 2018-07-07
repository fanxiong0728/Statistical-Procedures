*-------------------------------------------------------------------*
 *  Author:  Fan Xiong            <fanxiong0728@gmail.com>           *
*-------------------------------------------------------------------*

/*This SAS program analyzes PDMP data and identifies the estimate number of residents per zipcode with high-risk opioid prescriptions*/

/*Targets were patients living in areas valued by morphine milligram equivalence. Higher MMEs correspond to greater potential for 
intervention and response. 

/*Segmentation was done by zipcodes, risk level, and patient deomgraphics.*/

/*The result is a series of HTML maps used in a public awareness media campaign to target zipcodes with high-risk patients*/

*-------------------------------------------------------------------*
 *  This SAS program uses the brewerpal macro to create colors in SAS written by Michael Friendly  *
*-------------------------------------------------------------------*

LIBNAME MEDIA "C:\TEMP\Space\Projects\Social Media Data";
LIBNAME DATA "C:\TEMP\EHR PAPER OCT\DATA";

proc import datafile="C:\TEMP\Space\Projects\Social Media Data\BRFSS_CENSUSTRACT.XLS" dbms=xls OUT=MEDIA.BRFSSTRACT REPLACE;
RUN;

/*
%macro readRdata;
%do YEAR = 10 %to 17;
%INCLUDE "C:\TEMP\EHR PAPER OCT\DATA\projectnptbl1&YEAR..SAS";
%end;
%mend;

%readRdata;
*/

OPTIONS COMPRESS=YES THREADS CPUCOUNT=ACTUAL;

DATA DATA.NOTEHRINTEGRATION;
SET DATA.PROJECTNPT10-DATA.PROJECTNPT17;

IF PATIENT_GENDER="F" THEN FEMALEPT=1;
ELSE FEMALEPT=0;

IF PATIENT_GENDER="M" THEN MALEPT=1;
ELSE MALEPT=0;

IF PATIENT_GENDER="U" THEN UNKNOWNPT=1;
ELSE UNKNOWNPT=0;

IF AGE GE 65 THEN AGE65PT=1;
ELSE AGE65PT=0;

IF dayssupply_dispensed GE 30 THEN DAYS30=1;
ELSE DAYS30=0;

IF dispensaries GE 5 then DISPENSARY_F5=1;
ELSE DISPENSARY_F5=0;

ARRAY OUTCOMES (*) MME100 MME90 MME80 MME70 MME60 MME50 MME40 MME30 MME20 
				   OPIOIDBENZO DEA_SH2 DEA_SH3 DEA_SH4 LAPT OXYPT OXYMPT OXY_OXYMPT;
DO I = 1 to DIM(OUTCOMES);

/*PATIENT RISK MEASURES*/
OUTCOMES[i]=0;
	if 1 <= i <= 9 THEN DO; 
	IF Rxmme_dd >= 20 THEN OUTCOMES[1]=1;
	IF Rxmme_dd >= 30 THEN OUTCOMES[2]=1;
	IF Rxmme_dd >= 40 THEN OUTCOMES[3]=1;
	IF Rxmme_dd >= 50 THEN OUTCOMES[4]=1;
	IF Rxmme_dd >= 60 THEN OUTCOMES[5]=1;
	IF Rxmme_dd >= 70 THEN OUTCOMES[6]=1;
	IF Rxmme_dd >= 80 THEN OUTCOMES[7]=1;
	IF Rxmme_dd >= 90 THEN OUTCOMES[8]=1;
	IF Rxmme_dd >= 100 THEN OUTCOMES[9]=1;
	END;

	if i = 10 THEN DO;
	IF RXOPIOID >= 1 and RXBENZO >=1 THEN OUTCOMES[10]=1;
	END;

	if 11 <= i =13 THEN DO;
	IF opioidscheduleII GE 1 THEN OUTCOMES[11]=1;
	IF opioidscheduleIII GE 1 THEN OUTCOMES[12]=1;
	IF opioidscheduleIV GE 1 THEN OUTCOMES[13]=1;
	END;

	if i = 14 THEN DO;
	IF LA GE 1 THEN OUTCOMES[14]=1;
	END;

	if 15 <= i <=17 THEN DO;
	IF Oxycodone GE 1 THEN OUTCOMES[15]=1;
	IF Oxymorphone GE 1 THEN OUTCOMES[16]=1;
	IF Oxycodone GE 1  AND Oxymorphone GE 1  THEN OUTCOMES[17]=1;
	END;

END;

TIME=MDY(MONTHF,1,YEARF);
FORMAT TIME DATE9.;
RUN;


PROC SORT DATA= MEDIA.KTRACS1017 OUT=MEDIA.KTRACS1017 THREADS;
BY NUMERICID patient_gender AGE TIME;
PROC TIMESERIES DATA=MEDIA.KTRACS1017 OUT=MEDIA.KTRACS1017B; 
BY NUMERICID patient_gender AGE;
ID TIME INTERVAL=YEAR START="01JUL2010"d END="31DEC2017"d;
VAR prescribers--OXY_OXYMPT / SETMISSING=0 ACCUMULATE=TOTAL;
RUN;

LIBNAME GENDER "H:\Health Promotion\Injury Disability\secure_injury_data\PDMP\Sept 2017 Build\DATA LISTS\Gender";
LIBNAME BY "H:\Health Promotion\Injury Disability\secure_injury_data\PDMP\Sept 2017 Build\DATA LISTS\Birthyear";
LIBNAME Geocode "H:\Health Promotion\Injury Disability\secure_injury_data\PDMP\Sept 2017 Build\DATA LISTS\Geocode";
libname backup "H:\Health Promotion\Injury Disability\secure_injury_data\PDMP\BACKUPS DO NOT OVERWRITE";
LIBNAME STREET "C:\TEMP\Space\Street";
LIBNAME MPE "C:\TEMP\Space\MPE";

PROC SQL NOPRINT;
CREATE TABLE MEDIA.GEOCODEPTDATA as SELECT A.*, B.*
FROM MEDIA.KTRACS1017B (WHERE=(PRESCRIBERS >=1 and dispensaries >=1)) as a left join 
					(SELECT DISTINCT ZIP, CNTYFIPS, AGE, numericid, patient_gender, CNTYNAME, HRPN_NAME, TRAUMA_NAME,state, AVG(RES_RATIO) as RES_RATIO FROM 
							MPE.Allptzipcnty2 (KEEP=ZIP CNTYFIPS AGE numericid patient_gender CNTYNAME HRPN_NAME TRAUMA_NAME  state RES_RATIO) 
						GROUP BY ZIP, CNTYFIPS, AGE, patient_gender, numericid, CNTYNAME, HRPN_NAME, TRAUMA_NAME,state ) as b 
					ON a.numericid=b.NUMERICID and a.patient_gender=b.patient_gender and A.AGE = b.AGE;
					QUIT;
          
DATA MEDIA.GEOCODEPTDATA;
SET MEDIA.GEOCODEPTDATA;
PATIENTS=1;
PROC SORT DATA= MEDIA.GEOCODEPTDATA  THREADS;
BY patient_gender AGE CNTYFIPS ZIP TRAUMA_NAME HRPN_NAME  CNTYNAME TIME;
PROC TIMESERIES DATA=MEDIA.GEOCODEPTDATA OUT=MEDIA.GEOCODEPTDATAB; 
BY patient_gender AGE CNTYFIPS ZIP TRAUMA_NAME HRPN_NAME  CNTYNAME TIME;
ID TIME INTERVAL=YEAR START="01JAN2011"d END="01JAN2018"d;
VAR prescribers--OXY_OXYMPT RES_RATIO PATIENTS / SETMISSING=MISSING ACCUMULATE=TOTAL;
RUN;
PROC FORMAT;
value injuryindicators
0	=	'00'
1-4	=	'01-04'
5-11	=	'05-11'
12-17	=	'12-17'
18-24	=	'18-24'
24-34	=	'25-34'
35-44	=	'35-44'
45-54	=	'45-54'
55-64	=	'55-64'
65-74	=	'65-74'
75-84	=	'75-84'
85-120	=	'85+' 
other   =   '      ';
RUN;
DATA MEDIA.GEOCODEPTDATAB;
SET MEDIA.GEOCODEPTDATAB;
WHERE PRESCRIBERS NE . and DISPENSARIES NE . AND PATIENT_GENDER IN ("M","F") AND 0<=AGE<=120 AND ZIP NE .;
LENGTH ZCTA5CE10 $5. AGECAT $5. NAME $100.;
ZCTA5CE10=COMPRESS(PUT(ZIP,best5.));
AGECAT=TRIM(PUT(AGE,injuryindicators.));
NAME=TRIM(CNTYNAME);
RUN;



/*CREATING THE BASE MAP: Importing and Evaluating the Shapefiles
  DOWNLOAD FROM: https://www.census.gov/geo/maps-data/data/cbf/cbf_zcta.html

		DATAFILE = statement specifies the path and the file name of the shapefile that is of interest
		OUT = statement tells SAS® the name of the dataset where the imported shapefile should be saved
*/

PROC MAPIMPORT
DATAFILE = "C:\TEMP\Space\Projects\Social Media Data\cb_2016_us_zcta510_500k.shp"
OUT = MEDIA.Zip_Codes;
PROC SORT DATA=MEDIA.Zip_Codes OUT=MEDIA.KSZIPCODES;
by AFFGEOID10;
WHERE  -102.0517440  <= X <=  -94.5884130 and 36.9930160 <= Y <= 40.0031620;
PROC GMAP DATA = MEDIA.KSZIPCODES  MAP = MEDIA.KSZIPCODES ;
ID AFFGEOID10;
CHORO SEGMENT;
RUN;
QUIT;

PROC MAPIMPORT
DATAFILE = "C:\TEMP\Space\Projects\Social Media Data\cb_2016_us_county_500k.shp"
OUT = MEDIA.COUNTY;
PROC SORT DATA=MEDIA.COUNTY OUT=MEDIA.COUNTY;
by AFFGEOID;
WHERE STATEFP="20";
PROC GMAP DATA = MEDIA.COUNTY  MAP = MEDIA.COUNTY ;
ID AFFGEOID;
CHORO SEGMENT;
RUN;
QUIT;

PROC SQL NOPRINT;
CREATE TABLE MEDIA.ZIPCODESAS AS SELECT DISTINCT A.ZCTA5CE10, B.STATECODE, B.COUNTYNM FROM 
MEDIA.KSZIPCODES as a left join sashelp.zipcode (WHERE=(STATECODE="KS")) as b on ZCTA5CE10 = COMPRESS(PUT(ZIP, Z5.))
ORDER BY COUNTYNM, ZCTA5CE10;
QUIT;

PROC TRANSPOSE DATA=MEDIA.ZIPCODESAS OUT=MEDIA.ZIPCODESAS2 PREFIX=ZIP;
BY COUNTYNM;
VAR ZCTA5CE10;
RUN;

DATa MEDIA.ZIPCODESAS3;
SET MEDIA.ZIPCODESAS2;
localeID=960
ARRAY ZIP (*) ZIP1-ZIP145;
do i = 1 to dim(ZIP);

RUN;

/*Summarize the Data*/

/*Indicator 1: 2015-2016 Percentage of Prescription Opioids from Total by Zipcode*/
proc sort data=MEDIA.GEOCODEPTDATAB;
by TIME;
PROC FREQ DATA=MEDIA.GEOCODEPTDATAB NOPRINT;
WHERE YEAR(TIME) GE 2015;
TABLES patient_gender*AGECAT*ZCTA5CE10 / list out=MEDIA.OPIOIDZCTA5 (RENAME=COUNT=OPIOIDRX RENAME=PERCENT=OPIOIDRXPER);
WEIGHT RXOPIOID;
PROC FREQ DATA=MEDIA.GEOCODEPTDATAB NOPRINT;
WHERE YEAR(TIME) GE 2015;
TABLES patient_gender*AGECAT*ZCTA5CE10 / list out=MEDIA.PTZCTA5 (RENAME=COUNT=PTZIP RENAME=PERCENT=PTZIPPER);
WEIGHT PATIENTS;
DATA MEDIA.OPIOIDRATE;
MERGE MEDIA.OPIOIDZCTA5 MEDIA.PTZCTA5;
by patient_gender AGECAT ZCTA5CE10;
ARRAY RECODE (*) OPIOIDRX PTZIP;
DO i = 1 to DIM(RECODE);
IF RECODE[i]=. THEN RECODE[i]=0;
END;
OPIOIDRATE=(OPIOIDRX/PTZIP);
IF PTZIP <=20 THEN OPIOIDRATE=0;
RUN;

PROC SUMMARY DATA=MEDIA.OPIOIDRATE NOPRINT;
VAR OPIOIDRATE;
OUTPUT OUT=MEDIA.PERCENTILE 
MIN(OPIOIDRATE) = MINIMUM
P25(OPIOIDRATE) = P25_
MEDIAN(OPIOIDRATE) = MED_
P75(OPIOIDRATE) = P75_
P99(OPIOIDRATE) = P99_ 
MAX(OPIOIDRATE) = MAXIMUM;
RUN;

PROC FORMAT;
VALUE OPIOIDRATE
    0 = "Sparse Estimates or Zero Counts"
	0 <-2 = "At Least 2 Opioids per Patient"
	2<-4 = "More than 2 and Less than 4 Opioids per Patient"
	4 <-6 = "More than 4 and Less than 6 Opioids per Patient"
	6<-HIGH = "More than 6 Opioids per Patient"
	;
RUN;

PROC SORT DATA = MEDIA.KSZIPCODES ;
BY ZCTA5CE10;
RUN;

/* Add html hover-text & drilldown */
data MEDIA.OPIOIDRATE2; 
set MEDIA.OPIOIDRATE;
IF ptzip <=20 THEN DO;
ptzip=.;
OPIOIDRX=.;
OPIOIDRATE=0;
END;
length htmlvar $1024. GENDER $6.;
IF patient_gender = "M" THEN GENDER = "MALE";
ELSE IF patient_gender = "F" THEN GENDER = "FEMALE"; 
 htmlvar= 
  'title='||quote( 
   trim(left(propcase(Gender)))||' Zipcode, '||trim(left(ZCTA5CE10))||'0D'x||
   'Age: '||trim(left(AGECAT))||'0D'x||
	'  Total Opioids: '||trim(left(put(OPIOIDRX,best8.)))||
   'Total Patients: '||trim(left(put(ptzip,best8.))));
LABEL OPIOIDRATE = "Prescription Opioids per Patient:  ";
LABEL GENDER = "Patient Gender   ";
LABEL AGECAT = "Patient Age Category   ";

run;

PROC SORT DATA = MEDIA.OPIOIDRATE2;
BY GENDER AGECAT ZCTA5CE10;
RUN;
/*Color Brewer Macro*/
%include "H:\Health Promotion\Injury Disability\xiong_secure\DDPI FACTSHEETS\brewer.sas"; RUN;
%include "H:\Health Promotion\Injury Disability\xiong_secure\DDPI FACTSHEETS\brewerpal.sas"; RUN;
%brewerpal(n=4, palette=YlOrRd,lib=work, result=yiordrd5);  
%PUT _USER_;
   
PATTERN1 C = CXFAEBD7;
PATTERN2 C = CXFFFFB2;
PATTERN3 C = CXFECC5C;
PATTERN4 C = CXFD8D3C;
PATTERN5 C = CXE31A1C;
%LET PATH = C:\TEMP\Space\Projects\Social Media Data\Analysis Result\Opioid Prescriptions\HTML ZIPCODE;
goptions device=gif; 
ODS LISTING CLOSE;
ODS HTML path="&PATH" 
body="Zipcode_Opioids20152016-body.HTML"  
contents="Zipcode_Opioids20152016-contents.HTML"
 page="Zipcode_Opioids20152016-page.HTML"
 frame="Zipcode_Opioids20152016-frame.HTML"

style=HTMLBLUE image_dpi=300 options(pagebreak='yes');
ODS GRAPHICS;
OPTIONS ORIENTATION=LANDSCAPE; 
PROC GMAP DATA = MEDIA.OPIOIDRATE2 MAP =  MEDIA.KSZIPCODES ;
BY GENDER AGECAT;
ID ZCTA5CE10;
FORMAT OPIOIDRATE OPIOIDRATE.;
CHORO OPIOIDRATE / DISCRETE missing COUTLINE=BLACK
HTML =HTMLVAR;
TITLE;
*TITLE 'Map of Opioid Prescriptions Dispensed per Patient (Annual Rate by Gender, Age Category, and Patient Zipcode)' h=22 COLOR=BLACK JUSTIFY=CENTER FONT=ARIAL;
FOOTNOTE link="http://www.kansashealthmatters.org/index.php?module=indicators&controller=index&action=view&indicatorId=2370&localeTypeId=2" "Link to Kansas Health Matters for County-level Drug Poisoning Deaths for Kansas and Counties" h=14 COLOR=BLACK JUSTIFY=CENTER FONT=ARIAL;
LEGEND POSITION=TOP;
RUN;
QUIT;
ODS HTML CLOSE;

/*Indicator 2: 2015-2016 Percentage of Prescription Opioid and Benzo Overlaps*/
proc sort data=MEDIA.GEOCODEPTDATAB;
by TIME;
PROC FREQ DATA=MEDIA.GEOCODEPTDATAB NOPRINT;
WHERE YEAR(TIME) GE 2015;
TABLES patient_gender*AGECAT*ZCTA5CE10 / list out=MEDIA.OPBZZCTA5 (RENAME=COUNT=OPBZRX RENAME=PERCENT=OPBZPER);
WEIGHT OPIOIDBENZO;
DATA MEDIA.OPBZCTA;
SET MEDIA.OPBZZCTA5;
by patient_gender AGECAT ZCTA5CE10;
ARRAY RECODE (*) OPBZRX OPBZPER;
DO i = 1 to DIM(RECODE);
IF RECODE[i]=. THEN RECODE[i]=0;
END;
OPBZRXRATE=OPBZPER;
IF OPBZRX <=20 THEN OPBZRXRATE=0;
RUN;

PROC SUMMARY DATA=MEDIA.OPBZCTA NOPRINT;
VAR OPBZRXRATE;
OUTPUT OUT=MEDIA.PERCENTILE2 
MIN(OPBZRXRATE) = MINIMUM
P25(OPBZRXRATE) = P25_
MEDIAN(OPBZRXRATE) = MED_
P75(OPBZRXRATE) = P75_
P99(OPBZRXRATE) = P99_ 
MAX(OPBZRXRATE) = MAXIMUM;
RUN;

PROC FORMAT;
VALUE OPIOIDBENZO
    0 = "Sparse Estimates or Zero Counts"
	0 <-0.05 = "Less than 5% of Opioid Patients have Concurrent Benzo Prescriptions per Month"
	0.05<-0.10 = "More than 5% to 10% of Opioid Patients have Concurrent Benzo Prescriptions per Month"
	0.10 <-0.5 = "More than 10% to 50% of Opioid Patients have Concurrent Benzo Prescriptions per Month"
	0.5<-HIGH = "More than 50% of Opioid Patients have Concurrent Benzo Prescriptions per Month"
	;
RUN;

PROC SORT DATA = MEDIA.KSZIPCODES ;
BY ZCTA5CE10;
RUN;

/* Add html hover-text & drilldown */
data MEDIA.OPBZCTA2; 
set MEDIA.OPBZCTA;
IF OPBZRX <=20 THEN DO;
OPBZRX=.;
OPBZRXRATE=0;
END;

length htmlvar $1024. GENDER $6.;
IF patient_gender = "M" THEN GENDER = "MALE";
ELSE IF patient_gender = "F" THEN GENDER = "FEMALE"; 
 htmlvar= 
  'title='||quote( 
   trim(left(propcase(Gender)))||' Zipcode, '||trim(left(ZCTA5CE10))||'0D'x||
   'Age: '||trim(left(AGECAT))||'0D'x||
	'  Percentage of Opioid Patients with Overlapping Benzo Prescriptions: '||trim(left(put(OPBZRXRATE,percent9.1)))||
   'Total Opioid Patients with Overlapping Benzo Prescriptions: '||trim(left(put(OPBZRX,best8.))));
LABEL OPBZRXRATE = "Percentage of Opioids with Overlapping Benzo Prescriptions:  ";
LABEL GENDER = "Patient Gender   ";
LABEL AGECAT = "Patient Age Category   ";
run;

PROC SORT DATA = MEDIA.OPBZCTA2;
BY GENDER AGECAT ZCTA5CE10;
RUN;
/*Color Brewer Macro*/
%include "H:\Health Promotion\Injury Disability\xiong_secure\DDPI FACTSHEETS\brewer.sas"; RUN;
%include "H:\Health Promotion\Injury Disability\xiong_secure\DDPI FACTSHEETS\brewerpal.sas"; RUN;
%brewerpal(n=4, palette=YlOrRd,lib=work, result=yiordrd5);  
%PUT _USER_;
   
PATTERN1 C = CXFAEBD7;
PATTERN2 C = CXFFFFB2;
PATTERN3 C = CXFECC5C;
PATTERN4 C = CXFD8D3C;
PATTERN5 C = CXE31A1C;
%LET PATH = C:\TEMP\Space\Projects\Social Media Data\Analysis Result\Opioid Prescriptions\HTML ZIPCODE;
goptions device=gif; 
ODS LISTING CLOSE;
ODS HTML path="&PATH" 
body="Zipcode_OPBZCTA220152016-body.HTML"  
contents="Zipcode_OPBZCTA220152016-contents.HTML"
 page="Zipcode_OPBZCTA220152016-page.HTML"
 frame="Zipcode_OPBZCTA220152016-frame.HTML"

style=HTMLBLUE image_dpi=300 options(pagebreak='yes');
ODS GRAPHICS;
OPTIONS ORIENTATION=LANDSCAPE; 
PROC GMAP DATA = MEDIA.OPBZCTA2 MAP =  MEDIA.KSZIPCODES ;
BY GENDER AGECAT;
ID ZCTA5CE10;
FORMAT OPBZRXRATE OPIOIDBENZO.;
CHORO OPBZRXRATE / DISCRETE missing COUTLINE=BLACK
HTML =HTMLVAR;
TITLE;
*TITLE 'Map of Opioid Prescriptions Dispensed per Patient (Annual Rate by Gender, Age Category, and Patient Zipcode)' h=22 COLOR=BLACK JUSTIFY=CENTER FONT=ARIAL;
FOOTNOTE link="http://www.kansashealthmatters.org/index.php?module=indicators&controller=index&action=view&indicatorId=2370&localeTypeId=2" "Link to Kansas Health Matters for County-level Drug Poisoning Deaths for Kansas and Counties" h=14 COLOR=BLACK JUSTIFY=CENTER FONT=ARIAL;
LEGEND POSITION=TOP;
RUN;
QUIT;
ODS HTML CLOSE;

/*Indicator 3: 2015-2016 Percentage of Patients with 90 MME or Higher*/
proc sort data=MEDIA.GEOCODEPTDATAB;
by TIME;
PROC FREQ DATA=MEDIA.GEOCODEPTDATAB NOPRINT;
WHERE YEAR(TIME) GE 2015;
TABLES patient_gender*AGECAT*ZCTA5CE10 / list out=MEDIA.MME90ZCTA5 (RENAME=COUNT=MME90RX RENAME=PERCENT=MME90PER);
WEIGHT MME90;
DATA MEDIA.MME90ZCTA;
SET MEDIA.MME90ZCTA5;
by patient_gender AGECAT ZCTA5CE10;
ARRAY RECODE (*) MME90RX MME90PER;
DO i = 1 to DIM(RECODE);
IF RECODE[i]=. THEN RECODE[i]=0;
END;
IF MME90RX <=20 THEN MME90PER=0;
RUN;

PROC SUMMARY DATA=MEDIA.MME90ZCTA NOPRINT;
VAR MME90PER;
OUTPUT OUT=MEDIA.PERCENTILE3
MIN(MME90PER) = MINIMUM
P25(MME90PER) = P25_
MEDIAN(MME90PER) = MED_
P75(MME90PER) = P75_
P99(MME90PER) = P99_ 
MAX(MME90PER) = MAXIMUM;
RUN;

PROC FORMAT;
VALUE MME90PER
    0 = "Sparse Estimates or Zero Counts"
	0 <-0.010 = "Less than 0.1% of Opioid Patients with 90 MME or More per Month"
	0.010<-0.10 = "More than 0.10% to 10% of Opioid Patients with 90 MME or More per Month"
	0.10 <-0.20 = "10% to 20% of Opioid Patients with 90 MME or More per Month"
	0.20<-HIGH = "More than 20% of Opioid Patients with 90 MME or More per Month"
	;
RUN;

PROC SORT DATA = MEDIA.KSZIPCODES ;
BY ZCTA5CE10;
RUN;

/* Add html hover-text & drilldown */
data MEDIA.MME90ZCTA2; 
set MEDIA.MME90ZCTA;
IF MME90RX <=20 THEN DO;
MME90RX=.;
MME90PER=0;
END;

length htmlvar $1024. GENDER $6.;
IF patient_gender = "M" THEN GENDER = "MALE";
ELSE IF patient_gender = "F" THEN GENDER = "FEMALE"; 
 htmlvar= 
  'title='||quote( 
   trim(left(propcase(Gender)))||' Zipcode, '||trim(left(ZCTA5CE10))||'0D'x||
   'Age: '||trim(left(AGECAT))||'0D'x||
	'  Percentage of Opioid Patients with 90 MME or More: '||trim(left(put(MME90PER,percent9.1)))||
   'Total Opioid Patients with 90 MME or More: '||trim(left(put(MME90RX,best8.))));
LABEL MME90RX = "Opioid Patients with 90 MME or More:  ";
LABEL GENDER = "Patient Gender   ";
LABEL AGECAT = "Patient Age Category   ";
run;

PROC SORT DATA = MEDIA.MME90ZCTA2;
BY GENDER AGECAT ZCTA5CE10;
RUN;
/*Color Brewer Macro*/
%include "H:\Health Promotion\Injury Disability\xiong_secure\DDPI FACTSHEETS\brewer.sas"; RUN;
%include "H:\Health Promotion\Injury Disability\xiong_secure\DDPI FACTSHEETS\brewerpal.sas"; RUN;
%brewerpal(n=4, palette=YlOrRd,lib=work, result=yiordrd5);  
%PUT _USER_;
   
PATTERN1 C = CXFAEBD7;
PATTERN2 C = CXFFFFB2;
PATTERN3 C = CXFECC5C;
PATTERN4 C = CXFD8D3C;
PATTERN5 C = CXE31A1C;
%LET PATH = C:\TEMP\Space\Projects\Social Media Data\Analysis Result\Opioid Prescriptions\HTML ZIPCODE;
goptions device=gif; 
ODS LISTING CLOSE;
ODS HTML path="&PATH" 
body="Zipcode_MME90PER20152016-body.HTML"  
contents="Zipcode_MME90PER20152016-contents.HTML"
 page="Zipcode_MME90PER20152016-page.HTML"
 frame="Zipcode_MME90PER20152016-frame.HTML"

style=HTMLBLUE image_dpi=300 options(pagebreak='yes');
ODS GRAPHICS;
OPTIONS ORIENTATION=LANDSCAPE; 
PROC GMAP DATA = MEDIA.MME90ZCTA2 MAP =  MEDIA.KSZIPCODES ;
BY GENDER AGECAT;
ID ZCTA5CE10;
FORMAT MME90PER MME90PER.;
CHORO MME90PER / DISCRETE missing COUTLINE=BLACK
HTML =HTMLVAR;
TITLE;
*TITLE 'Map of Opioid Prescriptions Dispensed per Patient (Annual Rate by Gender, Age Category, and Patient Zipcode)' h=22 COLOR=BLACK JUSTIFY=CENTER FONT=ARIAL;
FOOTNOTE link="http://www.kansashealthmatters.org/index.php?module=indicators&controller=index&action=view&indicatorId=2370&localeTypeId=2" "Link to Kansas Health Matters for County-level Drug Poisoning Deaths for Kansas and Counties" h=14 COLOR=BLACK JUSTIFY=CENTER FONT=ARIAL;
LEGEND POSITION=TOP;
RUN;
QUIT;
ODS HTML CLOSE;
