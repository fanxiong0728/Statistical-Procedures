*-------------------------------------------------------------------*
 *  Author:  Fan Xiong            <fanxiong0728@gmail.com>           *
 *-------------------------------------------------------------------*

/*This SAS program aggregates population data, medical claims, and PDMP pharmacy data by county and builds statistical files for Tableau*/

/*SAS CODE TO BUILD TABLEAU DASHBOARDS*/

OPTIONS COMPRESS=YES CPUCOUNT=ACTUAL;
/*LIBNAME NEEDED TO SPECIFY DIRECTORIES*/
/*LOCATION OF CENSUS BUREAU POPULATION FILES*/
LIBNAME POPDATA "H:\Health Promotion\Injury Disability\secure_injury_data\Population Data";
/*LOCATION OF HOSPITAL DISCHARGE AND EMERGENCY DEPARTMENT DATA*/
libname MEDICAL "C:\TEMP\Medical Discharges\HD";
/*LOCATION OF TABLEAU DATA FILES TO OUTPUT*/
LIBNAME TABDATAB "H:\Health Promotion\Injury Disability\secure_injury_data\Tableau Dashboard Materials\Data";
/*LOCATION OF POPULATION DATA FILES*/
LIBNAME POPDATA "H:\Health Promotion\Injury Disability\secure_injury_data\Population Data";
/*Injury ED Datafiles*/
LIBNAME INJURY "H:\Health Promotion\Injury Disability\secure_injury_data\KHA ED Database\Final Database";

/*Final Datasets for Tableau*/
LIBNAME FINAL "H:\Health Promotion\Injury Disability\secure_injury_data\Tableau Dashboard Materials\Data\Final";

/*Read kansas geography formats for recoding and lookup*/
%include "H:\Health Promotion\Injury Disability\secure_injury_data\Geography Files\Formats\FX_COUNTY CODES AND REGIONS MASTER LIST.sas" / source2;

libname PHI_RESB  oracle user=fxiong password=XXXXX
   dbprompt=NO
   path=VSTRN
   schema=PHI_RESEARCH  
   oracle_73_or_above=YES
   preserve_col_names=YES
   preserve_tab_names=YES
   dbindex=NO;

run;

LIBNAME FINAL "H:\Health Promotion\Injury Disability\secure_injury_data\Tableau Dashboard Materials\Data\Final";


/*WRITE A MACRO PROGRAM TO IMPORT EACH CSV FILES*/

%macro readapprisstableauextract(year=);
      data TABDATAB.OPIOIDS&year    ;
      %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
      infile "H:\Health Promotion\Injury Disability\secure_injury_data\Tableau Dashboard
 Materials\Data\KTRACS\KTRACS_Daily_Updated_Opioid_Prescription_Filled_&year..csv" delimiter
 = ',' MISSOVER DSD
  lrecl=13106 firstobs=2 ;
         informat Opiate_Agonist_and_Opiate_Partia $41. ;
         informat Year_of_Prescription_Filled_Date $4. ;
         informat _2014_to_2017_Year_of_Filled_Log $4. ;
         informat Prescription_per_100_Resident best32. ;
         informat _2012___2016_ACS_5_Year_County_P best32. ;
         informat Kansas_Patient_Demographics_Coun $9. ;
         informat Opioid_Days_Supply best32. ;
         informat Current_YTD_Logic $4. ;
         informat Buprenorphine_Product_Exclusion $5. ;
         informat VAR10 $28. ;
         informat Number_of_Records best32. ;
         informat Patient_Demographics___Kansas $14. ;
         informat Days_Supply best32. ;
         informat Calendar_Month_End_Date mmddyy10. ;
         informat AHFS_Description $15. ;
         informat Drug_Brand_Name $25. ;
         informat Drug_Generic_Name $36. ;
         informat Drug_Label_Name $42. ;
         informat Drug_NDC $11. ;
         informat DEA_Drug_Schedule $1. ;
         informat DEA_Drug_Schedule_Display $10. ;
         informat DEA_Drug_Schedule_No $1. ;
         informat Patient_Demographics_County_Code $9. ;
         informat Patient_Demographics_FIPS_Code $5. ;
         informat Patient_Demographics_State $2. ;
         informat Patient_Demographics_Zip 5. ;
         informat Pharmacy_City $13. ;
         informat Pharmacy_County $9. ;
         informat Pharmacy_State $2. ;
         informat Pharmacy_Zip $5. ;
         informat Prescriber_City $15. ;
         informat Prescriber_County $11. ;
         informat Prescriber_State $2. ;
         informat Prescriber_Zip $5. ;
         informat Quantity best32. ;
         informat Prescription_Count best32. ;
         format Opiate_Agonist_and_Opiate_Partia $41. ;
         format Year_of_Prescription_Filled_Date $4. ;
         format _2014_to_2017_Year_of_Filled_Log $4. ;
         format Prescription_per_100_Resident best12. ;
         format _2012___2016_ACS_5_Year_County_P best12. ;
         format Kansas_Patient_Demographics_Coun $9. ;
         format Opioid_Days_Supply best12. ;
         format Current_YTD_Logic $4. ;
         format Buprenorphine_Product_Exclusion $5. ;
         format VAR10 $28. ;
         format Number_of_Records best12. ;
         format Patient_Demographics___Kansas $14. ;
         format Days_Supply best12. ;
         format Calendar_Month_End_Date mmddyy10. ;
         format AHFS_Description $15. ;
         format Drug_Brand_Name $25. ;
         format Drug_Generic_Name $36. ;
         format Drug_Label_Name $42. ;
         format Drug_NDC $11. ;
         format DEA_Drug_Schedule $1. ;
         format DEA_Drug_Schedule_Display $10. ;
         format DEA_Drug_Schedule_No $1. ;
         format Patient_Demographics_County_Code $9. ;
         format Patient_Demographics_FIPS_Code $5. ;
         format Patient_Demographics_State $2. ;
         format Patient_Demographics_Zip $5. ;
         format Pharmacy_City $13. ;
         format Pharmacy_County $9. ;
         format Pharmacy_State $2. ;
         format Pharmacy_Zip $5. ;
         format Prescriber_City $15. ;
         format Prescriber_County $11. ;
         format Prescriber_State $2. ;
         format Prescriber_Zip $5. ;
         format Quantity best12. ;
         format Prescription_Count best12. ;
      input
                  Opiate_Agonist_and_Opiate_Partia $
                  Year_of_Prescription_Filled_Date
                  _2014_to_2017_Year_of_Filled_Log $
                  Prescription_per_100_Resident
                  _2012___2016_ACS_5_Year_County_P
                  Kansas_Patient_Demographics_Coun $
                  Opioid_Days_Supply
                  Current_YTD_Logic $
                  Buprenorphine_Product_Exclusion $
                  VAR10 $
                  Number_of_Records
                  Patient_Demographics___Kansas $
                  Days_Supply
                  Calendar_Month_End_Date
                  AHFS_Description $
                  Drug_Brand_Name $
                  Drug_Generic_Name $
                  Drug_Label_Name $
                  Drug_NDC
                  DEA_Drug_Schedule
                  DEA_Drug_Schedule_Display $
                  DEA_Drug_Schedule_No
                  Patient_Demographics_County_Code $
                  Patient_Demographics_FIPS_Code
                  Patient_Demographics_State $
                  Patient_Demographics_Zip
                  Pharmacy_City $
                  Pharmacy_County $
                  Pharmacy_State $
                  Pharmacy_Zip
                  Prescriber_City $
                  Prescriber_County $
                  Prescriber_State $
                  Prescriber_Zip
                  Quantity
                  Prescription_Count
      ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
    run;
%mend;
/*RUN THE DATA-STEP TO IMPORT EACH CSV FILES AS A SAS DATASET*/

%readapprisstableauextract(year=2014);
%readapprisstableauextract(year=2015);
%readapprisstableauextract(year=2016);
%readapprisstableauextract(year=2017);
%readapprisstableauextract(year=2018);

/*Previous Month Data Extract*/
      data TABDATAB.OPIOIDSJUN18;
      %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
      infile "H:\Health Promotion\Injury Disability\secure_injury_data\Tableau Dashboard
 Materials\Data\KTRACS\KTRACS_Daily_Updated_Opioid_Prescription_Filled_JUN2018.csv" delimiter
 = ',' MISSOVER DSD
  lrecl=13106 firstobs=2 ;
         informat Opiate_Agonist_and_Opiate_Partia $41. ;
         informat Year_of_Prescription_Filled_Date $4. ;
         informat _2014_to_2017_Year_of_Filled_Log $4. ;
         informat Prescription_per_100_Resident best32. ;
         informat _2012___2016_ACS_5_Year_County_P best32. ;
         informat Kansas_Patient_Demographics_Coun $9. ;
         informat Opioid_Days_Supply best32. ;
         informat Current_YTD_Logic $4. ;
         informat Buprenorphine_Product_Exclusion $5. ;
         informat VAR10 $28. ;
         informat Number_of_Records best32. ;
         informat Patient_Demographics___Kansas $14. ;
         informat Days_Supply best32. ;
         informat Calendar_Month_End_Date mmddyy10. ;
         informat AHFS_Description $15. ;
         informat Drug_Brand_Name $25. ;
         informat Drug_Generic_Name $36. ;
         informat Drug_Label_Name $42. ;
         informat Drug_NDC $11. ;
         informat DEA_Drug_Schedule $1. ;
         informat DEA_Drug_Schedule_Display $10. ;
         informat DEA_Drug_Schedule_No $1. ;
         informat Patient_Demographics_County_Code $9. ;
         informat Patient_Demographics_FIPS_Code $5. ;
         informat Patient_Demographics_State $2. ;
         informat Patient_Demographics_Zip 5. ;
         informat Pharmacy_City $13. ;
         informat Pharmacy_County $9. ;
         informat Pharmacy_State $2. ;
         informat Pharmacy_Zip $5. ;
         informat Prescriber_City $15. ;
         informat Prescriber_County $11. ;
         informat Prescriber_State $2. ;
         informat Prescriber_Zip $5. ;
         informat Quantity best32. ;
         informat Prescription_Count best32. ;
         format Opiate_Agonist_and_Opiate_Partia $41. ;
         format Year_of_Prescription_Filled_Date $4. ;
         format _2014_to_2017_Year_of_Filled_Log $4. ;
         format Prescription_per_100_Resident best12. ;
         format _2012___2016_ACS_5_Year_County_P best12. ;
         format Kansas_Patient_Demographics_Coun $9. ;
         format Opioid_Days_Supply best12. ;
         format Current_YTD_Logic $4. ;
         format Buprenorphine_Product_Exclusion $5. ;
         format VAR10 $28. ;
         format Number_of_Records best12. ;
         format Patient_Demographics___Kansas $14. ;
         format Days_Supply best12. ;
         format Calendar_Month_End_Date mmddyy10. ;
         format AHFS_Description $15. ;
         format Drug_Brand_Name $25. ;
         format Drug_Generic_Name $36. ;
         format Drug_Label_Name $42. ;
         format Drug_NDC $11. ;
         format DEA_Drug_Schedule $1. ;
         format DEA_Drug_Schedule_Display $10. ;
         format DEA_Drug_Schedule_No $1. ;
         format Patient_Demographics_County_Code $9. ;
         format Patient_Demographics_FIPS_Code $5. ;
         format Patient_Demographics_State $2. ;
         format Patient_Demographics_Zip $5. ;
         format Pharmacy_City $13. ;
         format Pharmacy_County $9. ;
         format Pharmacy_State $2. ;
         format Pharmacy_Zip $5. ;
         format Prescriber_City $15. ;
         format Prescriber_County $11. ;
         format Prescriber_State $2. ;
         format Prescriber_Zip $5. ;
         format Quantity best12. ;
         format Prescription_Count best12. ;
      input
                  Opiate_Agonist_and_Opiate_Partia $
                  Year_of_Prescription_Filled_Date
                  _2014_to_2017_Year_of_Filled_Log $
                  Prescription_per_100_Resident
                  _2012___2016_ACS_5_Year_County_P
                  Kansas_Patient_Demographics_Coun $
                  Opioid_Days_Supply
                  Current_YTD_Logic $
                  Buprenorphine_Product_Exclusion $
                  VAR10 $
                  Number_of_Records
                  Patient_Demographics___Kansas $
                  Days_Supply
                  Calendar_Month_End_Date
                  AHFS_Description $
                  Drug_Brand_Name $
                  Drug_Generic_Name $
                  Drug_Label_Name $
                  Drug_NDC
                  DEA_Drug_Schedule
                  DEA_Drug_Schedule_Display $
                  DEA_Drug_Schedule_No
                  Patient_Demographics_County_Code $
                  Patient_Demographics_FIPS_Code
                  Patient_Demographics_State $
                  Patient_Demographics_Zip
                  Pharmacy_City $
                  Pharmacy_County $
                  Pharmacy_State $
                  Pharmacy_Zip
                  Prescriber_City $
                  Prescriber_County $
                  Prescriber_State $
                  Prescriber_Zip
                  Quantity
                  Prescription_Count
      ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
    run;
/*MACRO VARIABLES FOR SQL CODES: EASIER TO MODIFY*/

%LET SQLKEEPVAR=Patient_Demographics_State Patient_Demographics_County_Code Calendar_Month_End_Date Drug_NDC AHFS_Description Prescription_Count Quantity Days_Supply; 
%LET SQLSELECT=Patient_Demographics_State as State,UPCASE(COMPRESS(Patient_Demographics_County_Code)) as COUNTY_NAME,
Calendar_Month_End_Date as Filled_Month_Date, Drug_NDC,AHFS_Description,SUM(Prescription_Count) as Prescription_Count, SUM(Quantity) as Quantity, SUM(Days_Supply) as Days_Supply;
%LET SQLGROUPBY=State,COUNTY_NAME,Filled_Month_Date,Drug_NDC,AHFS_Description;

/*CREATE A VIEW OF THE APPENDED DATASETS*/

DATA TABDATAB.OPIOIDSV1418 (KEEP= &SQLKEEPVAR) / VIEW=TABDATAB.OPIOIDSV1418;
SET TABDATAB.OPIOIDS2014 TABDATAB.OPIOIDS2015 TABDATAB.OPIOIDS2016 TABDATAB.OPIOIDS2017 
/*exclude prior month's data*/
TABDATAB.OPIOIDS2018 TABDATAB.OPIOIDSJUN18;

/*AGGREGATE THE VIEW USING THE SQL MACRO VARIABLES SPECIFIED ABOVE*/
PROC SQL NOPRINT;
CREATE TABLE TABDATAB.OPIOIDS1418 

AS SELECT a.Filled_Month_Date as EOM_DATE, a.State, a.COUNTY_NAME, COMPRESS(SCAN(b.DRUG,1," ")) as DRUG_TYPE,
SUM(Prescription_Count) as Prescription_Count, SUM(Quantity) as Quantity, SUM(Days_Supply) as Days_Supply

FROM 
(SELECT 
	&SQLSELECT
		FROM  TABDATAB.OPIOIDSV1418 GROUP BY &SQLGROUPBY) as a, 
		Tabdatab.Cdc_mme_table_sept2017 as b 
		WHERE a.Drug_NDC=b.NDC
		GROUP BY STATE,a.COUNTY_NAME,EOM_DATE,DRUG_TYPE
		HAVING DRUG_TYPE NE "Buprenorphine";
;

QUIT;


/*Use proc timeseries to get zero counts for incomplete drugs*/

proc sql noprint;
select NAME INTO: OPIOIDVARSUM SEPARATED BY "+" FROM TABDATAB.OPIOIDDATA WHERE NAME NE "Buprenorphine";
select NAME INTO: OPIOIDVAR SEPARATED BY " " FROM TABDATAB.OPIOIDDATA WHERE NAME NE "Buprenorphine";
QUIT;

%macro opioidtranspose(var=,suffix=);

/*State, County, and Drug*/

PROC SORT DATA=TABDATAB.OPIOIDS1418;
BY STATE COUNTY_NAME EOM_DATE DRUG_TYPE;
PROC TRANSPOSE DATA=TABDATAB.OPIOIDS1418 OUT=TABDATAB.OPIOIDS1418&SUFFIX;
BY STATE COUNTY_NAME EOM_DATE;
VAR &VAR;
ID DRUG_TYPE;
IDLABEL DRUG_TYPE;
PROC TIMESERIES DATA=TABDATAB.OPIOIDS1418&SUFFIX OUT=TABDATAB.OPIOIDS1418&SUFFIX.B;
BY STATE COUNTY_NAME;
ID EOM_DATE INTERVAL=MONTH START="01JAN2014"d END="30JUN2018"D SETMISSING=0 ACCUMULATE=TOTAL;
VAR Butorphanol -- Dihydrocodeine;
RUN;


DATA TABDATAB.OPIOIDS1418&SUFFIX.SERIES;
SET TABDATAB.OPIOIDS1418&SUFFIX.B;
KS&SUFFIX=&OPIOIDVARSUM;
LENGTH DRUG $20.;
ARRAY &SUFFIX.VAR (*) &OPIOIDVAR;
DO I = 1 to DIM(&SUFFIX.VAR);
DRUG=VNAME(&SUFFIX.VAR[i]);
&VAR=&SUFFIX.VAR[i];
OUTPUT;
END;
RUN;

/*State, County, and All Opioids*/
PROC SUMMARY DATA=TABDATAB.OPIOIDS1418&SUFFIX.SERIES NOPRINT CHARTYPE;
CLASS STATE COUNTY_NAME EOM_DATE;
TYPES STATE*COUNTY_NAME*EOM_DATE;
OUTPUT OUT=TABDATAB.COUNTY1418&SUFFIX.SERIES (DROP=_TYPE_ _FREQ_)
SUM(&VAR) = COUNTY&VAR;
DATA TABDATAB.COUNTY1418&SUFFIX.SERIES;
SET TABDATAB.COUNTY1418&SUFFIX.SERIES;
DRUG="All Opioids - County";
RUN;

/*State and Drug*/
PROC SUMMARY DATA=TABDATAB.OPIOIDS1418&SUFFIX.SERIES NOPRINT CHARTYPE;
CLASS STATE i DRUG EOM_DATE;
TYPES STATE*i*DRUG*EOM_DATE;
OUTPUT OUT=TABDATAB.KANSASD1418&SUFFIX.SERIES (DROP=_TYPE_ _FREQ_)
SUM(&VAR) = KS&VAR;
DATA TABDATAB.KANSASD1418&SUFFIX.SERIES;
SET TABDATAB.KANSASD1418&SUFFIX.SERIES;
LENGTH COUNTY_NAME $9.;
COUNTY_NAME="State";
RUN;

/*State and All Opioids*/
PROC SUMMARY DATA=TABDATAB.OPIOIDS1418&SUFFIX.SERIES NOPRINT CHARTYPE;
CLASS STATE EOM_DATE;
TYPES STATE*EOM_DATE;
OUTPUT OUT=TABDATAB.KANSAS1418&SUFFIX.SERIES (DROP=_TYPE_ _FREQ_)
SUM(&VAR) = KSALL&VAR;
DATA TABDATAB.KANSAS1418&SUFFIX.SERIES;
SET TABDATAB.KANSAS1418&SUFFIX.SERIES;
LENGTH COUNTY_NAME $9. DRUG $20.;
COUNTY_NAME="State";
DRUG="All Opioids - State";
RUN;

%MEND;

%opioidtranspose(var=Prescription_Count, suffix=RX)
%opioidtranspose(var=Quantity, suffix=QT)
%opioidtranspose(var=Days_Supply, suffix=DD)

PROC SQL NOPRINT;

CREATE TABLE FINAL.FINALOPIOID AS 
SELECT distinct coalesce(a.state,b.state,c.state,d.state) as state, d.county_name as County_name , 
coalesce(a.EOM_DATE, b.Eom_date,c.Eom_date,d.EOM_date) as EOM_DATE FORMAT=MONYY7., 
coalesce(a.DRUG, b.DRUG,c.DRUG) as DRUG, 
coalesce(a.i, b.i,c.i) as SelectOpioid, 
a.Prescription_Count as OpioidRx_count, 
b.Quantity as Opioid_quantity, c.Days_Supply as Opioid_Days_Supply,
d.KSPOPYEAR, d.KSPOPweight,
d.COUNTY_ABBRV, d.COUNTYPOPYEAR,
d.HRPN_NAME, d.HRPNPOPYEAR,d.HRPNPOPWEIGHT,
d.TRAUMA_REGION,d.TRAUMAPOPYEAR,d.TRAUMAPOPWEIGHT

	FROM TABDATAB.OPIOIDS1418RXSERIES as a 
			left join TABDATAB.OPIOIDS1418QTSERIES as b on a.EOM_DATE=b.EOM_DATE and a.COUNTY_NAME=b.COUNTY_NAME and a.i = b.i and a.state=b.state
			left join TABDATAB.OPIOIDS1418DDSERIES as c on a.EOM_DATE=c.EOM_DATE and a.COUNTY_NAME=c.COUNTY_NAME and a.i = c.i and a.state=c.state
			left join final.Finalpoptable as d on (a.state=COMPRESS(d.state) and a.county_name=COMPRESS(SUBSTR(d.county_name,1,9)) and 
					(YEAR(a.EOM_DATE)=YEAR(d.EOM_DATE) and MONTH(a.EOM_DATE)) = MONTH(D.EOM_DATE))
			ORDER BY state,county_name, EOM_DATE,SelectOpioid
;

CREATE TABLE FINAL.FINALCOUNTYOPIOID AS 
SELECT distinct coalesce(a.state,b.state,c.state,d.state) as state, d.county_name as County_name , 
coalesce(a.EOM_DATE, b.Eom_date,c.Eom_date,d.EOM_date) as EOM_DATE FORMAT=MONYY7., 
"All Opioids - County" as DRUG,  
0 as SelectOpioid,
a.COUNTYPrescription_Count as OpioidRx_count, 
b.COUNTYQuantity as Opioid_quantity, c.COUNTYDays_Supply as Opioid_Days_Supply,
d.KSPOPYEAR, d.KSPOPweight,
d.COUNTY_ABBRV, d.COUNTYPOPYEAR,
d.HRPN_NAME, d.HRPNPOPYEAR,d.HRPNPOPWEIGHT,
d.TRAUMA_REGION,d.TRAUMAPOPYEAR,d.TRAUMAPOPWEIGHT
	FROM TABDATAB.COUNTY1418RXSERIES as a 
			left join TABDATAB.COUNTY1418QTSERIES as b on a.EOM_DATE=b.EOM_DATE and a.COUNTY_NAME=b.COUNTY_NAME and a.state=b.state
			left join TABDATAB.COUNTY1418DDSERIES as c on a.EOM_DATE=c.EOM_DATE and a.COUNTY_NAME=c.COUNTY_NAME and a.state=c.state
			left join final.Finalpoptable as d on (a.state=COMPRESS(d.state) and a.county_name=COMPRESS(SUBSTR(d.county_name,1,9)) and 
					(YEAR(a.EOM_DATE)=YEAR(d.EOM_DATE) and MONTH(a.EOM_DATE)) = MONTH(D.EOM_DATE))
			ORDER BY state,county_name, EOM_DATE,SelectOpioid
;

CREATE TABLE FINAL.FINALKANSASDRUG AS 
SELECT distinct coalesce(a.state,b.state,c.state,d.state) as state, coalesce(a.COUNTY_NAME,b.COUNTY_NAME,c.COUNTY_NAME) as COUNTY_NAME,
coalesce(a.EOM_DATE, b.Eom_date,c.Eom_date,d.EOM_date) as EOM_DATE FORMAT=MONYY7., 
coalesce(a.DRUG, b.DRUG,c.DRUG) as DRUG,
coalesce(a.i, b.i,c.i) as SelectOpioid, 
a.KSPrescription_Count as KS_OpioidRx_count, 
b.KSQuantity as KS_Opioid_quantity, c.KSDays_Supply as KS_Opioid_Days_Supply,
d.KSPOPULATION

	FROM TABDATAB.KANSASD1418RXSERIES as a 
			left join TABDATAB.KANSASD1418QTSERIES as b on a.EOM_DATE=b.EOM_DATE and a.state=b.state  and a.i = b.i 
			left join TABDATAB.KANSASD1418DDSERIES as c on a.EOM_DATE=c.EOM_DATE and a.state=c.state  and a.i = c.i 
			left join (Select state, eom_date, sum(COUNTYPOPYEAR) as KSPOPULATION FROM final.Finalpoptable GROUP BY state, eom_date) as d on 
						(a.state=COMPRESS(d.state)) and (YEAR(a.EOM_DATE)=YEAR(d.EOM_DATE) and MONTH(a.EOM_DATE))
			ORDER BY state,county_name, EOM_DATE,SelectOpioid
;

CREATE TABLE FINAL.FINALKANSASOPIOID AS 
SELECT distinct coalesce(a.state,b.state,c.state,d.state) as state,  coalesce(a.COUNTY_NAME,b.COUNTY_NAME,c.COUNTY_NAME) as COUNTY_NAME,
coalesce(a.EOM_DATE, b.Eom_date,c.Eom_date,d.EOM_date) as EOM_DATE FORMAT=MONYY7., 
coalesce(a.DRUG, b.DRUG,c.DRUG) as DRUG,
0 as SelectOpioid,
a.KSALLPrescription_Count as OpioidRx_count, 
b.KSALLQuantity as Opioid_quantity, c.KSALLDays_Supply as Opioid_Days_Supply,
d.KSPOPULATION

	FROM TABDATAB.KANSAS1418RXSERIES as a 
			left join TABDATAB.KANSAS1418QTSERIES as b on a.EOM_DATE=b.EOM_DATE and a.state=b.state
			left join TABDATAB.KANSAS1418DDSERIES as c on a.EOM_DATE=c.EOM_DATE and a.state=c.state
			left join (Select state, eom_date, sum(COUNTYPOPYEAR) as KSPOPULATION FROM final.Finalpoptable GROUP BY state, eom_date) as d on 
						(a.state=COMPRESS(d.state)) and (YEAR(a.EOM_DATE)=YEAR(d.EOM_DATE) and MONTH(a.EOM_DATE))
			ORDER BY state,county_name, EOM_DATE,SelectOpioid
;

QUIT;

DATA FINAL.ALLKTRACS;
SET FINAL.FINALOPIOID FINAL.FINALCOUNTYOPIOID FINAL.FINALKANSASDRUG FINAL.FINALKANSASOPIOID;
RUN; 



/*CREATE ICD-10-CM 2016-2017 MONTHLY HOSPITAL DISCHARGE AND EMERGENCY DEPARTMENT DATA*/

%macro EXPORTMEDICALDATA;
%include "H:\Health Promotion\Injury Disability\secure_injury_data\Geography Files\Formats\FX_COUNTY CODES AND REGIONS MASTER LIST.sas" / source2;
%DO YEAR = 2015 %to 2016;
DATA MEDICAL.KHAHDICD10&YEAR;
SET PHI_RESB.KHA&year
(keep=ATTPHY PLACEOFSRV HOSPCO ADMITTYPE ADMITSOURC DISCDISP CNTYCODE DISDATE ADMDATE BIRTHDATE race ethnicity sex primdiag SECDIAG1-SECDIAG65);
STATEKEY=20000;
COUNTYKEY=STATEKEY+cntycode*1;

IF ("001" <= cntycode <="105");
/*dead or transferred to acute cate*/
IF DISCDISP IN ("02","04","66","82","94","20","40","41","42") THEN KEEP=0;
ELSE KEEP=1;

IF KEEP = 1 THEN DO;
if DISCDISP = "01" THEN Dis_type=2;
ELSE if DISCDISP IN ("06","50","81","86") THEN Dis_type=3;
ELSE if DISCDISP IN ("62","90") THEN Dis_type=4;
ELSE if DISCDISP IN ("03","64","83","92") THEN Dis_type=5;
ELSE Dis_type=1;
END;

IF KEEP=1;

LENGTH STATE $2.;
STATE="KS";
LENGTH COUNTY_NAME $25.;
COUNTY_NAME=UPCASE(COMPRESS(PUT(CNTYCODE,$NMNAM_O.)));

YEAR=COMPRESS(SUBSTR(DISDATE,5,4)); label year="Discharge Year";
MONTH=COMPRESS(SUBSTR(DISDATE,1,2)); label MONTH="Discharge Month";
DAY=COMPRESS(SUBSTR(DISDATE,3,2)); label DAY="Discharge Day";

AYEAR=COMPRESS(SUBSTR(ADMDATE,5,4)); label AYEAR="Admit Year";
AMONTH=COMPRESS(SUBSTR(ADMDATE,1,2)); label AMONTH="Admit Month";
ADAY=COMPRESS(SUBSTR(ADMDATE,3,2)); label ADAY="Admit Day";

ddate=MDY(MONTH,DAY,YEAR); /*discharge date*/
adate=MDY(AMONTH,ADAY,AYEAR); /*admit date*/
/*Subset to ICD-10-CM records (admission date has to be on or after October 1, 2015*/
IF ddate GE "01OCT2015"d; 

BIRTHYEAR=COMPRESS(SUBSTR(BIRTHDATE,5,4)); label BIRTHYEAR="Birth Year";
BIRTHMONTH=COMPRESS(SUBSTR(BIRTHDATE,1,2)); label BIRTHMONTH="Birth Month";
BIRTHDAY=COMPRESS(SUBSTR(BIRTHDATE,3,2)); label BIRTHDAY="Birth Day";

/*if birthdate is a valid string*/
bdate=MDY(BIRTHMONTH,BIRTHDAY,BIRTHYEAR); /*birth date*/

FORMAT adate ddate bdate mmddyy8.;

LENGTH GENDER $1.;
IF sex = "1" then gender='M';
if sex = "2" then gender='F';
if sex = " " then gender=' ';
IF sex = "M" then gender='M';
if sex = "F" then gender='F';
if sex = "U" then gender=' ';


AGE=INT(YRDIF(BDATE, ddate,'ACTUAL'));

IF 0<= AGE < 12 THEN AGEGROUP="00-11";
ELSE IF  12<= AGE <= 24 THEN AGEGROUP="12-24";
ELSE IF  25<= AGE <= 34 THEN AGEGROUP="25-34";
ELSE IF  35<= AGE <= 44 THEN AGEGROUP="35-44";
ELSE IF  45<= AGE <= 54 THEN AGEGROUP="45-54";
ELSE IF  55<= AGE <= 64 THEN AGEGROUP="55-64";
ELSE IF  65<= AGE <= 74 THEN AGEGROUP="65-74";
ELSE IF  75<= AGE <= 84 THEN AGEGROUP="75-84";
ELSE IF  85<= AGE <=120 THEN AGEGROUP="85+";
ELSE AGEGROUP = "MISS";

/*IDENTIFY ICD-10-CM DRUG POISONINGS USING PRINCIPAL DIAGNOSIS CODE*/

/*IDENTIFY ICD-10-CM ASSOCIATED DRUG POISONINGS*/
/*USE AN ANY MENTION*/
/*CREATE THE REGULAR EXPRESSIONS FOR THE INDICATORS*/
/*CREATE TAGS FOR EACH INDICATOR: H1-H3*/
H1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
H2=0;/*NON-HEROIN OPIOID ASSOCIATED OVERDOSE*/
H3=0;/*HEROIN ASSOCIATED OVERDOSE*/
H4=0;/*AMPHETAMINE ASSOCIATED OVERDOSE*/
H5=0;/*OTHER AND UNSPECIFIED PSYCHOSTIMULANT ASSOCIATED OVERDOSE*/
H6=0;/*BENZODIAZEPINES ASSOCIATED OVERDOSE*/
H7=0;/*ANY OPIOID ASSOCIATED OVERDOSE*/
P1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
%let poison5= %str(^T3[679]9[1-4]|^T414[1-4]|^T427[1-4]|^T4[3579]9[1-4]); 
%let poisoning = %str(^T3[679][0-8].[1-4]|^T38[0-9].[1-4]|^T40[0-9].[1-4]|^T41[^4].[1-4]|^T42[^7].[1-4]|^T4[3579][0-8].[1-4]|^T4[468][0-9].[1-4]|^T50..[1-4]|&POISON5.);
REGEX_H1DX=PRXPARSE("/&POISONING./");                       /*H1: ALL DRUG OVERDOSE DIAGNOSIS CODES*/
REGEX_H2DX=PRXPARSE('/^T40[0234].[1-4]|^T406[09][1-4]/');   /*H2: OPIOID OVERDOSE EXCLUDING HEROIN DX CODES*/
REGEX_H3DX=PRXPARSE('/^T401.[1-4]/');                       /*H3: HEROIN OVERDOSE DX CODES*/
REGEX_H4DX=PRXPARSE('/^T4362[1-4]/');                       /*H4: AMPHETMAINE OVERDOSE DX CODES*/
REGEX_H5DX=PRXPARSE('/^T4361[1-4]|T4369[1-4]/');            /*H5: OTHER AND UNSPECIFIED PSYCHOSTIMULANT OVERDOSE DX CODES*/
REGEX_H6DX=PRXPARSE('/^T424.[1-4]/');            			/*H6: BENZODIAZEPINES OVERDOSE DX CODES*/

/*PRINCIPAL DIAGNOSIS IS A DRUG POISONING*/
IF PRXMATCH(REGEX_H1DX, COMPRESS(PRIMDIAG)) THEN P1=1;       

ARRAY ALLDX (*) PRIMDIAG SECDIAG1-SECDIAG65;
	DO I = 1 TO DIM(ALLDX);
		IF ALLDX[i] NE "    " THEN DO;
	/*H1 E-CODES*/ 
            IF PRXMATCH(REGEX_H1DX, COMPRESS(ALLDX[i])) THEN H1+1;       
 	/*H2 E-CODES*/ 
			 IF PRXMATCH(REGEX_H2DX, COMPRESS(ALLDX[i])) THEN H2+1;    
  	/*H3 E-CODES*/ 
			 IF PRXMATCH(REGEX_H3DX, COMPRESS(ALLDX[i])) THEN H3+1;    
	/*H4 E-CODES*/ 
			 IF PRXMATCH(REGEX_H4DX, COMPRESS(ALLDX[i])) THEN H4+1;    
	/*H5 E-CODES*/ 
			 IF PRXMATCH(REGEX_H5DX, COMPRESS(ALLDX[i])) THEN H5+1;    
	/*H6 E-CODES*/ 
			 IF PRXMATCH(REGEX_H6DX, COMPRESS(ALLDX[i])) THEN H6+1;      
      END; 	  /*END ARRAY OPS*/ 
END;
  
	array recode (*) H1-H6;
	do i = 1 to dim(recode);
	if recode[i] GE 1 THEN recode[i]=1;
	END;

/*any opioids*/
	if H2 = 1 OR H3=1 THEN H7=1;

DROP REGEX: I PRIMDIAG SECDIAG1-SECDIAG65;
HD_DISCHARGES=1;

RUN;
%END;

DATA MEDICAL.KHAHDICD102017;
SET PHI_RESB.KHA2017Q123PROVISIONAL
(keep=ATTPHY PLACEOFSRV HOSPCO ADMITTYPE ADMITSOURC DISCDISP CNTYCODE DISDATE ADMDATE BIRTHDATE race ethnicity sex primdiag SECDIAG1-SECDIAG65);
STATEKEY=20000;
COUNTYKEY=STATEKEY+cntycode*1;

IF ("001" <= cntycode <="105");
/*dead or transferred to acute cate*/
IF DISCDISP IN ("02","04","66","82","94","20","40","41","42") THEN KEEP=0;
ELSE KEEP=1;

IF KEEP = 1 THEN DO;
if DISCDISP = "01" THEN Dis_type=2;
ELSE if DISCDISP IN ("06","50","81","86") THEN Dis_type=3;
ELSE if DISCDISP IN ("62","90") THEN Dis_type=4;
ELSE if DISCDISP IN ("03","64","83","92") THEN Dis_type=5;
ELSE Dis_type=1;
END;

IF KEEP=1;

LENGTH STATE $2.;
STATE="KS";
LENGTH COUNTY_NAME $25.;
COUNTY_NAME=UPCASE(COMPRESS(PUT(CNTYCODE,$NMNAM_O.)));

YEAR=COMPRESS(SUBSTR(DISDATE,5,4)); label year="Discharge Year";
MONTH=COMPRESS(SUBSTR(DISDATE,1,2)); label MONTH="Discharge Month";
DAY=COMPRESS(SUBSTR(DISDATE,3,2)); label DAY="Discharge Day";

AYEAR=COMPRESS(SUBSTR(ADMDATE,5,4)); label AYEAR="Admit Year";
AMONTH=COMPRESS(SUBSTR(ADMDATE,1,2)); label AMONTH="Admit Month";
ADAY=COMPRESS(SUBSTR(ADMDATE,3,2)); label ADAY="Admit Day";

ddate=MDY(MONTH,DAY,YEAR); /*discharge date*/
adate=MDY(AMONTH,ADAY,AYEAR); /*admit date*/
/*Subset to ICD-10-CM records (admission date has to be on or after October 1, 2015*/
IF ddate GE "01OCT2015"d; 

BIRTHYEAR=COMPRESS(SUBSTR(BIRTHDATE,5,4)); label BIRTHYEAR="Birth Year";
BIRTHMONTH=COMPRESS(SUBSTR(BIRTHDATE,1,2)); label BIRTHMONTH="Birth Month";
BIRTHDAY=COMPRESS(SUBSTR(BIRTHDATE,3,2)); label BIRTHDAY="Birth Day";

/*if birthdate is a valid string*/
bdate=MDY(BIRTHMONTH,BIRTHDAY,BIRTHYEAR); /*birth date*/

FORMAT adate ddate bdate mmddyy8.;

LENGTH GENDER $1.;
IF sex = "1" then gender='M';
if sex = "2" then gender='F';
if sex = " " then gender=' ';
IF sex = "M" then gender='M';
if sex = "F" then gender='F';
if sex = "U" then gender=' ';


AGE=INT(YRDIF(BDATE, ddate,'ACTUAL'));

IF 0<= AGE < 12 THEN AGEGROUP="00-11";
ELSE IF  12<= AGE <= 24 THEN AGEGROUP="12-24";
ELSE IF  25<= AGE <= 34 THEN AGEGROUP="25-34";
ELSE IF  35<= AGE <= 44 THEN AGEGROUP="35-44";
ELSE IF  45<= AGE <= 54 THEN AGEGROUP="45-54";
ELSE IF  55<= AGE <= 64 THEN AGEGROUP="55-64";
ELSE IF  65<= AGE <= 74 THEN AGEGROUP="65-74";
ELSE IF  75<= AGE <= 84 THEN AGEGROUP="75-84";
ELSE IF  85<= AGE <=120 THEN AGEGROUP="85+";
ELSE AGEGROUP = "MISS";

/*IDENTIFY ICD-10-CM DRUG POISONINGS USING PRINCIPAL DIAGNOSIS CODE*/


/*IDENTIFY ICD-10-CM ASSOCIATED DRUG POISONINGS*/
/*USE AN ANY MENTION*/
/*CREATE THE REGULAR EXPRESSIONS FOR THE INDICATORS*/
/*CREATE TAGS FOR EACH INDICATOR: H1-H3*/
H1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
H2=0;/*NON-HEROIN OPIOID ASSOCIATED OVERDOSE*/
H3=0;/*HEROIN ASSOCIATED OVERDOSE*/
H4=0;/*AMPHETAMINE ASSOCIATED OVERDOSE*/
H5=0;/*OTHER AND UNSPECIFIED PSYCHOSTIMULANT ASSOCIATED OVERDOSE*/
H6=0;/*BENZODIAZEPINES ASSOCIATED OVERDOSE*/
H7=0;/*ANY OPIOID ASSOCIATED OVERDOSE*/
P1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
%let poison5= %str(^T3[679]9[1-4]|^T414[1-4]|^T427[1-4]|^T4[3579]9[1-4]); 
%let poisoning = %str(^T3[679][0-8].[1-4]|^T38[0-9].[1-4]|^T40[0-9].[1-4]|^T41[^4].[1-4]|^T42[^7].[1-4]|^T4[3579][0-8].[1-4]|^T4[468][0-9].[1-4]|^T50..[1-4]|&POISON5.);
REGEX_H1DX=PRXPARSE("/&POISONING./");                       /*H1: ALL DRUG OVERDOSE DIAGNOSIS CODES*/
REGEX_H2DX=PRXPARSE('/^T40[0234].[1-4]|^T406[09][1-4]/');   /*H2: OPIOID OVERDOSE EXCLUDING HEROIN DX CODES*/
REGEX_H3DX=PRXPARSE('/^T401.[1-4]/');                       /*H3: HEROIN OVERDOSE DX CODES*/
REGEX_H4DX=PRXPARSE('/^T4362[1-4]/');                       /*H4: AMPHETMAINE OVERDOSE DX CODES*/
REGEX_H5DX=PRXPARSE('/^T4361[1-4]|T4369[1-4]/');            /*H5: OTHER AND UNSPECIFIED PSYCHOSTIMULANT OVERDOSE DX CODES*/
REGEX_H6DX=PRXPARSE('/^T424.[1-4]/');            			/*H6: BENZODIAZEPINES OVERDOSE DX CODES*/

/*PRINCIPAL DIAGNOSIS IS A DRUG POISONING*/
IF PRXMATCH(REGEX_H1DX, COMPRESS(PRIMDIAG)) THEN P1=1;       

ARRAY ALLDX (*) PRIMDIAG SECDIAG1-SECDIAG65;
	DO I = 1 TO DIM(ALLDX);
		IF ALLDX[i] NE "    " THEN DO;
	/*H1 E-CODES*/ 
            IF PRXMATCH(REGEX_H1DX, COMPRESS(ALLDX[i])) THEN H1+1;       
 	/*H2 E-CODES*/ 
			 IF PRXMATCH(REGEX_H2DX, COMPRESS(ALLDX[i])) THEN H2+1;    
  	/*H3 E-CODES*/ 
			 IF PRXMATCH(REGEX_H3DX, COMPRESS(ALLDX[i])) THEN H3+1;    
	/*H4 E-CODES*/ 
			 IF PRXMATCH(REGEX_H4DX, COMPRESS(ALLDX[i])) THEN H4+1;    
	/*H5 E-CODES*/ 
			 IF PRXMATCH(REGEX_H5DX, COMPRESS(ALLDX[i])) THEN H5+1;    
	/*H6 E-CODES*/ 
			 IF PRXMATCH(REGEX_H6DX, COMPRESS(ALLDX[i])) THEN H6+1;      
      END; 	  /*END ARRAY OPS*/ 
END;
  
	array recode (*) H1-H6;
	do i = 1 to dim(recode);
	if recode[i] GE 1 THEN recode[i]=1;
	END;

/*any opioids*/
	if H2 = 1 OR H3=1 THEN H7=1;

DROP REGEX: I PRIMDIAG SECDIAG1-SECDIAG65;
HD_DISCHARGES=1;


RUN;

/*************************************************************************/
/*************************************************************************/



/*KHA ED DATA Analysis*/
DATA MEDICAL.KHAEDICD102015;
SET INJURY.KHAED2015
(keep=DISC_DIS statecounty ADATE DOB race ethnicity sex uddiag1-uddiag49 uniqueid);
/*Subset to ICD-10-CM records (admission date has to be on or after October 1, 2015*/
IF ("20001" <= statecounty <="20209");
STATEKEY=20000;
CNTYCODE=statecounty-statekey;
COUNTYKEY=STATEKEY+CNTYCODE;
/*dead or transferred to acute cate*/
IF DISC_DIS IN ("02","04","66","82","94","20","40","41","42") THEN KEEP=0;
ELSE KEEP=1;

IF KEEP = 1 THEN DO;
if DISC_DIS = "01" THEN Dis_type=2;
ELSE if DISC_DIS IN ("06","50","81","86") THEN Dis_type=3;
ELSE if DISC_DIS IN ("62","90") THEN Dis_type=4;
ELSE if DISC_DIS IN ("03","64","83","92") THEN Dis_type=5;
ELSE Dis_type=1;
END;

IF KEEP=1;

LENGTH STATE $2.;
STATE="KS";
LENGTH COUNTY_NAME $25.;
COUNTY_NAME=UPCASE(COMPRESS(PUT(CNTYCODE,$NUMNAM_F.)));

AYEAR=COMPRESS(SUBSTR(ADATE,7,4)); label AYEAR="Admit Year";
AMONTH=COMPRESS(SUBSTR(ADATE,1,2)); label AMONTH="Admit Month";
ADAY=COMPRESS(SUBSTR(ADATE,4,2)); label ADAY="Admit Day";
adate2=MDY(AMONTH,ADAY,AYEAR); /*admit date*/
/*Subset to ICD-10-CM records (admission date has to be on or after October 1, 2015*/
IF adate2 GE "01OCT2015"d; 

BIRTHYEAR=COMPRESS(SUBSTR(DOB,7,4)); label BIRTHYEAR="Birth Year";
BIRTHMONTH=COMPRESS(SUBSTR(DOB,1,2)); label BIRTHMONTH="Birth Month";
BIRTHDAY=COMPRESS(SUBSTR(DOB,4,2)); label BIRTHDAY="Birth Day";

/*if birthdate is a valid string*/
bdate=MDY(BIRTHMONTH,BIRTHDAY,BIRTHYEAR); /*birth date*/

FORMAT adate2 bdate mmddyy8.;

LENGTH GENDER $1.;
GENDER=SEX;

AGE=INT(YRDIF(BDATE, adate2,'ACTUAL'));

IF 0<= AGE < 12 THEN AGEGROUP="00-11";
ELSE IF  12<= AGE <= 24 THEN AGEGROUP="12-24";
ELSE IF  25<= AGE <= 34 THEN AGEGROUP="25-34";
ELSE IF  35<= AGE <= 44 THEN AGEGROUP="35-44";
ELSE IF  45<= AGE <= 54 THEN AGEGROUP="45-54";
ELSE IF  55<= AGE <= 64 THEN AGEGROUP="55-64";
ELSE IF  65<= AGE <= 74 THEN AGEGROUP="65-74";
ELSE IF  75<= AGE <= 84 THEN AGEGROUP="75-84";
ELSE IF  85<= AGE <=120 THEN AGEGROUP="85+";
ELSE AGEGROUP = "MISS";

/*IDENTIFY ICD-10-CM DRUG POISONINGS USING PRINCIPAL DIAGNOSIS CODE*/


/*IDENTIFY ICD-10-CM ASSOCIATED DRUG POISONINGS*/
/*USE AN ANY MENTION*/
/*CREATE THE REGULAR EXPRESSIONS FOR THE INDICATORS*/
/*CREATE TAGS FOR EACH INDICATOR: H1-H3*/
H1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
H2=0;/*NON-HEROIN OPIOID ASSOCIATED OVERDOSE*/
H3=0;/*HEROIN ASSOCIATED OVERDOSE*/
H4=0;/*AMPHETAMINE ASSOCIATED OVERDOSE*/
H5=0;/*OTHER AND UNSPECIFIED PSYCHOSTIMULANT ASSOCIATED OVERDOSE*/
H6=0;/*BENZODIAZEPINES ASSOCIATED OVERDOSE*/
H7=0;/*ANY OPIOID ASSOCIATED OVERDOSE*/
P1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
%let poison5= %str(^T3[679]9[1-4]|^T414[1-4]|^T427[1-4]|^T4[3579]9[1-4]); 
%let poisoning = %str(^T3[679][0-8].[1-4]|^T38[0-9].[1-4]|^T40[0-9].[1-4]|^T41[^4].[1-4]|^T42[^7].[1-4]|^T4[3579][0-8].[1-4]|^T4[468][0-9].[1-4]|^T50..[1-4]|&POISON5.);
REGEX_H1DX=PRXPARSE("/&POISONING./");                       /*H1: ALL DRUG OVERDOSE DIAGNOSIS CODES*/
REGEX_H2DX=PRXPARSE('/^T40[0234].[1-4]|^T406[09][1-4]/');   /*H2: OPIOID OVERDOSE EXCLUDING HEROIN DX CODES*/
REGEX_H3DX=PRXPARSE('/^T401.[1-4]/');                       /*H3: HEROIN OVERDOSE DX CODES*/
REGEX_H4DX=PRXPARSE('/^T4362[1-4]/');                       /*H4: AMPHETMAINE OVERDOSE DX CODES*/
REGEX_H5DX=PRXPARSE('/^T4361[1-4]|T4369[1-4]/');            /*H5: OTHER AND UNSPECIFIED PSYCHOSTIMULANT OVERDOSE DX CODES*/
REGEX_H6DX=PRXPARSE('/^T424.[1-4]/');            			/*H6: BENZODIAZEPINES OVERDOSE DX CODES*/

/*PRINCIPAL DIAGNOSIS IS A DRUG POISONING*/
IF PRXMATCH(REGEX_H1DX, COMPRESS(UDDIAG1)) THEN P1=1;       

ARRAY ALLDX (*) UDDIAG:;
	DO I = 1 TO DIM(ALLDX);
		IF ALLDX[i] NE "    " THEN DO;
	/*H1 E-CODES*/ 
            IF PRXMATCH(REGEX_H1DX, COMPRESS(ALLDX[i])) THEN H1+1;       
 	/*H2 E-CODES*/ 
			 IF PRXMATCH(REGEX_H2DX, COMPRESS(ALLDX[i])) THEN H2+1;    
  	/*H3 E-CODES*/ 
			 IF PRXMATCH(REGEX_H3DX, COMPRESS(ALLDX[i])) THEN H3+1;    
	/*H4 E-CODES*/ 
			 IF PRXMATCH(REGEX_H4DX, COMPRESS(ALLDX[i])) THEN H4+1;    
	/*H5 E-CODES*/ 
			 IF PRXMATCH(REGEX_H5DX, COMPRESS(ALLDX[i])) THEN H5+1;    
	/*H6 E-CODES*/ 
			 IF PRXMATCH(REGEX_H6DX, COMPRESS(ALLDX[i])) THEN H6+1;      
      END; 	  /*END ARRAY OPS*/ 
END;
  
	array recode (*) H1-H6;
	do i = 1 to dim(recode);
	if recode[i] GE 1 THEN recode[i]=1;
	END;

/*any opioids*/
	if H2 = 1 OR H3=1 THEN H7=1;

DROP REGEX: I UDDIAG:;
ED_ADMISSIONS=1;
RUN;

DATA MEDICAL.KHAEDICD102016;
SET PHI_RESB.KHAED2016
(keep=ATTPHY PLACEOFSRV HOSPCO ADMITTYPE ADMITSOURC DISCDISP CNTYCODE DISDATE ADMDATE BIRTHDATE race ethnicity sex primdiag SECDIAG1-SECDIAG65);
/*Subset to ICD-10-CM records (admission date has to be on or after October 1, 2015*/
IF ("001" <= cntycode <="105");
STATEKEY=20000;
COUNTYKEY=STATEKEY+cntycode;
/*dead or transferred to acute cate*/
IF DISCDISP IN ("02","04","66","82","94","20","40","41","42") THEN KEEP=0;
ELSE KEEP=1;

IF KEEP = 1 THEN DO;
if DISCDISP = "01" THEN Dis_type=2;
ELSE if DISCDISP IN ("06","50","81","86") THEN Dis_type=3;
ELSE if DISCDISP IN ("62","90") THEN Dis_type=4;
ELSE if DISCDISP IN ("03","64","83","92") THEN Dis_type=5;
ELSE Dis_type=1;
END;

IF KEEP=1;

LENGTH STATE $2.;
STATE="KS";
LENGTH COUNTY_NAME $25.;
COUNTY_NAME=UPCASE(COMPRESS(PUT(CNTYCODE,$NMNAM_O.)));

YEAR=COMPRESS(SUBSTR(DISDATE,5,4)); label year="Discharge Year";
MONTH=COMPRESS(SUBSTR(DISDATE,1,2)); label MONTH="Discharge Month";
DAY=COMPRESS(SUBSTR(DISDATE,3,2)); label DAY="Discharge Day";

AYEAR=COMPRESS(SUBSTR(ADMDATE,5,4)); label AYEAR="Admit Year";
AMONTH=COMPRESS(SUBSTR(ADMDATE,1,2)); label AMONTH="Admit Month";
ADAY=COMPRESS(SUBSTR(ADMDATE,3,2)); label ADAY="Admit Day";

ddate=MDY(MONTH,DAY,YEAR); /*discharge date*/
adate=MDY(AMONTH,ADAY,AYEAR); /*admit date*/

/*Subset to ICD-10-CM records (admission date has to be on or after October 1, 2015*/
IF adate GE "01OCT2015"d; 

BIRTHYEAR=COMPRESS(SUBSTR(BIRTHDATE,5,4)); label BIRTHYEAR="Birth Year";
BIRTHMONTH=COMPRESS(SUBSTR(BIRTHDATE,1,2)); label BIRTHMONTH="Birth Month";
BIRTHDAY=COMPRESS(SUBSTR(BIRTHDATE,3,2)); label BIRTHDAY="Birth Day";

/*if birthdate is a valid string*/
bdate=MDY(BIRTHMONTH,BIRTHDAY,BIRTHYEAR); /*birth date*/

FORMAT adate ddate bdate mmddyy8.;

LENGTH GENDER $1.;
IF sex = "1" then gender='M';
if sex = "2" then gender='F';
if sex = " " then gender=' ';
IF sex = "M" then gender='M';
if sex = "F" then gender='F';
if sex = "U" then gender=' ';

AGE=INT(YRDIF(BDATE, adate,'ACTUAL'));

IF 0<= AGE < 12 THEN AGEGROUP="00-11";
ELSE IF  12<= AGE <= 24 THEN AGEGROUP="12-24";
ELSE IF  25<= AGE <= 34 THEN AGEGROUP="25-34";
ELSE IF  35<= AGE <= 44 THEN AGEGROUP="35-44";
ELSE IF  45<= AGE <= 54 THEN AGEGROUP="45-54";
ELSE IF  55<= AGE <= 64 THEN AGEGROUP="55-64";
ELSE IF  65<= AGE <= 74 THEN AGEGROUP="65-74";
ELSE IF  75<= AGE <= 84 THEN AGEGROUP="75-84";
ELSE IF  85<= AGE <=120 THEN AGEGROUP="85+";
ELSE AGEGROUP = "MISS";

/*IDENTIFY ICD-10-CM DRUG POISONINGS USING PRINCIPAL DIAGNOSIS CODE*/


/*IDENTIFY ICD-10-CM ASSOCIATED DRUG POISONINGS*/
/*USE AN ANY MENTION*/
/*CREATE THE REGULAR EXPRESSIONS FOR THE INDICATORS*/
/*CREATE TAGS FOR EACH INDICATOR: H1-H3*/
H1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
H2=0;/*NON-HEROIN OPIOID ASSOCIATED OVERDOSE*/
H3=0;/*HEROIN ASSOCIATED OVERDOSE*/
H4=0;/*AMPHETAMINE ASSOCIATED OVERDOSE*/
H5=0;/*OTHER AND UNSPECIFIED PSYCHOSTIMULANT ASSOCIATED OVERDOSE*/
H6=0;/*BENZODIAZEPINES ASSOCIATED OVERDOSE*/
H7=0;/*ANY OPIOID ASSOCIATED OVERDOSE*/
P1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
%let poison5= %str(^T3[679]9[1-4]|^T414[1-4]|^T427[1-4]|^T4[3579]9[1-4]); 
%let poisoning = %str(^T3[679][0-8].[1-4]|^T38[0-9].[1-4]|^T40[0-9].[1-4]|^T41[^4].[1-4]|^T42[^7].[1-4]|^T4[3579][0-8].[1-4]|^T4[468][0-9].[1-4]|^T50..[1-4]|&POISON5.);
REGEX_H1DX=PRXPARSE("/&POISONING./");                       /*H1: ALL DRUG OVERDOSE DIAGNOSIS CODES*/
REGEX_H2DX=PRXPARSE('/^T40[0234].[1-4]|^T406[09][1-4]/');   /*H2: OPIOID OVERDOSE EXCLUDING HEROIN DX CODES*/
REGEX_H3DX=PRXPARSE('/^T401.[1-4]/');                       /*H3: HEROIN OVERDOSE DX CODES*/
REGEX_H4DX=PRXPARSE('/^T4362[1-4]/');                       /*H4: AMPHETMAINE OVERDOSE DX CODES*/
REGEX_H5DX=PRXPARSE('/^T4361[1-4]|T4369[1-4]/');            /*H5: OTHER AND UNSPECIFIED PSYCHOSTIMULANT OVERDOSE DX CODES*/
REGEX_H6DX=PRXPARSE('/^T424.[1-4]/');            			/*H6: BENZODIAZEPINES OVERDOSE DX CODES*/

/*PRINCIPAL DIAGNOSIS IS A DRUG POISONING*/
IF PRXMATCH(REGEX_H1DX, COMPRESS(PRIMDIAG)) THEN P1=1;       

ARRAY ALLDX (*) PRIMDIAG SECDIAG1-SECDIAG65;
	DO I = 1 TO DIM(ALLDX);
		IF ALLDX[i] NE "    " THEN DO;
	/*H1 E-CODES*/ 
            IF PRXMATCH(REGEX_H1DX, COMPRESS(ALLDX[i])) THEN H1+1;       
 	/*H2 E-CODES*/ 
			 IF PRXMATCH(REGEX_H2DX, COMPRESS(ALLDX[i])) THEN H2+1;    
  	/*H3 E-CODES*/ 
			 IF PRXMATCH(REGEX_H3DX, COMPRESS(ALLDX[i])) THEN H3+1;    
	/*H4 E-CODES*/ 
			 IF PRXMATCH(REGEX_H4DX, COMPRESS(ALLDX[i])) THEN H4+1;    
	/*H5 E-CODES*/ 
			 IF PRXMATCH(REGEX_H5DX, COMPRESS(ALLDX[i])) THEN H5+1;    
	/*H6 E-CODES*/ 
			 IF PRXMATCH(REGEX_H6DX, COMPRESS(ALLDX[i])) THEN H6+1;      
      END; 	  /*END ARRAY OPS*/ 
END;
  
	array recode (*) H1-H6;
	do i = 1 to dim(recode);
	if recode[i] GE 1 THEN recode[i]=1;
	END;

/*any opioids*/
	if H2 = 1 OR H3=1 THEN H7=1;

DROP REGEX: I PRIMDIAG SECDIAG1-SECDIAG65;
ED_ADMISSIONS=1;
RUN;

DATA MEDICAL.KHAEDICD102017;
SET PHI_RESB.KHAED2017Q123PROV
(keep=ATTPHY PLACEOFSRV HOSPCO ADMITTYPE ADMITSOURC DISCDISP CNTYCODE DISDATE ADMDATE BIRTHDATE race ethnicity sex primdiag SECDIAG1-SECDIAG65);
/*Subset to ICD-10-CM records (admission date has to be on or after October 1, 2015*/
IF ("001" <= cntycode <="105");
STATEKEY=20000;
COUNTYKEY=STATEKEY+cntycode*1;

/*dead or transferred to acute cate*/
IF DISCDISP IN ("02","04","66","82","94","20","40","41","42") THEN KEEP=0;
ELSE KEEP=1;

IF KEEP = 1 THEN DO;
if DISCDISP = "01" THEN Dis_type=2;
ELSE if DISCDISP IN ("06","50","81","86") THEN Dis_type=3;
ELSE if DISCDISP IN ("62","90") THEN Dis_type=4;
ELSE if DISCDISP IN ("03","64","83","92") THEN Dis_type=5;
ELSE Dis_type=1;
END;

IF KEEP=1;

LENGTH STATE $2.;
STATE="KS";
LENGTH COUNTY_NAME $25.;
COUNTY_NAME=UPCASE(COMPRESS(PUT(CNTYCODE,$NMNAM_O.)));

YEAR=COMPRESS(SUBSTR(DISDATE,5,4)); label year="Discharge Year";
MONTH=COMPRESS(SUBSTR(DISDATE,1,2)); label MONTH="Discharge Month";
DAY=COMPRESS(SUBSTR(DISDATE,3,2)); label DAY="Discharge Day";

AYEAR=COMPRESS(SUBSTR(ADMDATE,5,4)); label AYEAR="Admit Year";
AMONTH=COMPRESS(SUBSTR(ADMDATE,1,2)); label AMONTH="Admit Month";
ADAY=COMPRESS(SUBSTR(ADMDATE,3,2)); label ADAY="Admit Day";

ddate=MDY(MONTH,DAY,YEAR); /*discharge date*/
adate=MDY(AMONTH,ADAY,AYEAR); /*admit date*/

/*Subset to ICD-10-CM records (admission date has to be on or after October 1, 2015*/
IF adate GE "01OCT2015"d; 

BIRTHYEAR=COMPRESS(SUBSTR(BIRTHDATE,5,4)); label BIRTHYEAR="Birth Year";
BIRTHMONTH=COMPRESS(SUBSTR(BIRTHDATE,1,2)); label BIRTHMONTH="Birth Month";
BIRTHDAY=COMPRESS(SUBSTR(BIRTHDATE,3,2)); label BIRTHDAY="Birth Day";

/*if birthdate is a valid string*/
bdate=MDY(BIRTHMONTH,BIRTHDAY,BIRTHYEAR); /*birth date*/

FORMAT adate ddate bdate mmddyy8.

LENGTH GENDER $1.;
IF sex = "1" then gender='M';
if sex = "2" then gender='F';
if sex = " " then gender=' ';
IF sex = "M" then gender='M';
if sex = "F" then gender='F';
if sex = "U" then gender=' ';

AGE=INT(YRDIF(BDATE, adate,'ACTUAL'));

IF 0<= AGE < 12 THEN AGEGROUP="00-11";
ELSE IF  12<= AGE <= 24 THEN AGEGROUP="12-24";
ELSE IF  25<= AGE <= 34 THEN AGEGROUP="25-34";
ELSE IF  35<= AGE <= 44 THEN AGEGROUP="35-44";
ELSE IF  45<= AGE <= 54 THEN AGEGROUP="45-54";
ELSE IF  55<= AGE <= 64 THEN AGEGROUP="55-64";
ELSE IF  65<= AGE <= 74 THEN AGEGROUP="65-74";
ELSE IF  75<= AGE <= 84 THEN AGEGROUP="75-84";
ELSE IF  85<= AGE <=120 THEN AGEGROUP="85+";
ELSE AGEGROUP = "MISS";

/*IDENTIFY ICD-10-CM DRUG POISONINGS USING PRINCIPAL DIAGNOSIS CODE*/


/*IDENTIFY ICD-10-CM ASSOCIATED DRUG POISONINGS*/
/*USE AN ANY MENTION*/
/*CREATE THE REGULAR EXPRESSIONS FOR THE INDICATORS*/
/*CREATE TAGS FOR EACH INDICATOR: H1-H3*/
H1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/
H2=0;/*NON-HEROIN OPIOID ASSOCIATED OVERDOSE*/
H3=0;/*HEROIN ASSOCIATED OVERDOSE*/
H4=0;/*AMPHETAMINE ASSOCIATED OVERDOSE*/
H5=0;/*OTHER AND UNSPECIFIED PSYCHOSTIMULANT ASSOCIATED OVERDOSE*/
H6=0;/*BENZODIAZEPINES ASSOCIATED OVERDOSE*/
H7=0;/*ANY OPIOID ASSOCIATED OVERDOSE*/
P1=0;/*ALL DRUG ASSOCIATED OVERDOSE*/

%let poison5= %str(^T3[679]9[1-4]|^T414[1-4]|^T427[1-4]|^T4[3579]9[1-4]); 
%let poisoning = %str(^T3[679][0-8].[1-4]|^T38[0-9].[1-4]|^T40[0-9].[1-4]|^T41[^4].[1-4]|^T42[^7].[1-4]|^T4[3579][0-8].[1-4]|^T4[468][0-9].[1-4]|^T50..[1-4]|&POISON5.);

REGEX_H1DX=PRXPARSE("/&POISONING./");                       /*H1: ALL DRUG OVERDOSE DIAGNOSIS CODES*/
REGEX_H2DX=PRXPARSE('/^T40[0234].[1-4]|^T406[09][1-4]/');   /*H2: OPIOID OVERDOSE EXCLUDING HEROIN DX CODES*/
REGEX_H3DX=PRXPARSE('/^T401.[1-4]/');                       /*H3: HEROIN OVERDOSE DX CODES*/
REGEX_H4DX=PRXPARSE('/^T4362[1-4]/');                       /*H4: AMPHETMAINE OVERDOSE DX CODES*/
REGEX_H5DX=PRXPARSE('/^T4361[1-4]|T4369[1-4]/');            /*H5: OTHER AND UNSPECIFIED PSYCHOSTIMULANT OVERDOSE DX CODES*/
REGEX_H6DX=PRXPARSE('/^T424.[1-4]/');            			/*H6: BENZODIAZEPINES OVERDOSE DX CODES*/

/*PRINCIPAL DIAGNOSIS IS A DRUG POISONING*/
IF PRXMATCH(REGEX_H1DX, COMPRESS(PRIMDIAG)) THEN P1=1;       

ARRAY ALLDX (*) PRIMDIAG SECDIAG1-SECDIAG65;
	DO I = 1 TO DIM(ALLDX);
		IF ALLDX[i] NE "    " THEN DO;
	/*H1 E-CODES*/ 
            IF PRXMATCH(REGEX_H1DX, COMPRESS(ALLDX[i])) THEN H1+1;       
 	/*H2 E-CODES*/ 
			 IF PRXMATCH(REGEX_H2DX, COMPRESS(ALLDX[i])) THEN H2+1;    
  	/*H3 E-CODES*/ 
			 IF PRXMATCH(REGEX_H3DX, COMPRESS(ALLDX[i])) THEN H3+1;    
	/*H4 E-CODES*/ 
			 IF PRXMATCH(REGEX_H4DX, COMPRESS(ALLDX[i])) THEN H4+1;    
	/*H5 E-CODES*/ 
			 IF PRXMATCH(REGEX_H5DX, COMPRESS(ALLDX[i])) THEN H5+1;    
	/*H6 E-CODES*/ 
			 IF PRXMATCH(REGEX_H6DX, COMPRESS(ALLDX[i])) THEN H6+1;      
      END; 	  /*END ARRAY OPS*/ 
END;
  
	array recode (*) H1-H6;
	do i = 1 to dim(recode);
	if recode[i] GE 1 THEN recode[i]=1;
	END;

/*any opioids*/
	if H2 = 1 OR H3=1 THEN H7=1;

DROP REGEX: I PRIMDIAG SECDIAG1-SECDIAG65;
ED_ADMISSIONS=1;

RUN;

%MEND;

%EXPORTMEDICALDATA;


/*CREATE A VIEW OF THE APPENDED DATASETS*/
%macro aggregate;
%do year = 2015 %to 2017;
/*AGGREGATE THE VIEW USING THE SQL MACRO VARIABLES SPECIFIED ABOVE*/
PROC SQL NOPRINT;
/*MACRO VARIABLES FOR SQL CODES: EASIER TO MODIFY*/
%LET SQLKEEPVAR= ddate STATE COUNTY_NAME  H1-H7 P1; 
%LET SQLSELECT= intnx('MONTH',ddate,0,'E') as EOM_DATE FORMAT=DATE9., STATE, COUNTY_NAME ,  SUM(HD_DISCHARGES) as HD_DISCHARGES,
SUM(H1) AS HD_H1, SUM(H2) AS HD_H2, SUM(H3) AS HD_H3, SUM(H4) AS HD_H4, SUM(H5) AS HD_H5, SUM(H6) AS HD_H6, SUM(H7) AS HD_H7, SUM(P1) AS HD_P1 ;
%LET SQLGROUPBY= EOM_DATE, STATE, COUNTY_NAME;

CREATE TABLE TABDATAB.KHAHD&year 

AS SELECT 
	&SQLSELECT
		FROM  MEDICAL.Khahdicd10&year  where year(ddate) = &year GROUP BY &SQLGROUPBY
;
%end;

%do year = 2016 %to 2017;
/*MACRO VARIABLES FOR SQL CODES: EASIER TO MODIFY*/
%LET SQLKEEPVAR= adate STATE COUNTY_NAME  H1-H7 P1; 
%LET SQLSELECT=intnx('MONTH',adate,0,'E') as EOM_DATE FORMAT=DATE9., STATE, COUNTY_NAME , SUM(ED_ADMISSIONS) as ED_ADMISSIONS,
SUM(H1) AS ED_H1, SUM(H2) AS ED_H2, SUM(H3) AS ED_H3, SUM(H4) AS ED_H4, SUM(H5) AS ED_H5, SUM(H6) AS ED_H6, SUM(H7) AS ED_H7, SUM(P1) AS ED_P1 ;
%LET SQLGROUPBY= EOM_DATE, STATE, COUNTY_NAME;

CREATE TABLE TABDATAB.KHAED&year

AS SELECT 
	&SQLSELECT
		FROM  MEDICAL.KhaEdicd10&year where year(adate) = &year GROUP BY &SQLGROUPBY
;
%end;

%LET year = 2015;
/*MACRO VARIABLES FOR SQL CODES: EASIER TO MODIFY*/
%LET SQLKEEPVAR= adate2 STATE COUNTY_NAME  H1-H7 P1; 
%LET SQLSELECT=intnx('MONTH',adate2,0,'E') as EOM_DATE FORMAT=DATE9., STATE, COUNTY_NAME ,  SUM(ED_ADMISSIONS) as ED_ADMISSIONS,
SUM(H1) AS ED_H1, SUM(H2) AS ED_H2, SUM(H3) AS ED_H3, SUM(H4) AS ED_H4, SUM(H5) AS ED_H5, SUM(H6) AS ED_H6, SUM(H7) AS ED_H7, SUM(P1) AS ED_P1 ;
%LET SQLGROUPBY= EOM_DATE, STATE, COUNTY_NAME;

CREATE TABLE TABDATAB.KHAED&year

AS SELECT 
	&SQLSELECT
		FROM  MEDICAL.KhaEdicd10&year where year(adate2) = &year GROUP BY &SQLGROUPBY
;
QUIT;
%mend;

%aggregate;


DATA TABDATAB.KHAEDDATA  (DROP= ED_H1-ED_H7);
SET TABDATAB.KHAED2015 TABDATAB.KHAED2016 TABDATAB.KHAED2017;
LENGTH LABEL $50.;
ARRAY INDICATORS (*) ED_H1-ED_H7 ED_P1 ED_ADMISSIONS;
DO IKEY = 1 to DIM(INDICATORS);
ADMITS=INDICATORS[IKEY];
IF IKEY = 1 then LABEL="ALL DRUG ASSOCIATED OVERDOSE";
IF IKEY = 2 then LABEL="NON-HEROIN OPIOID ASSOCIATED OVERDOSE";
IF IKEY = 3 then LABEL="HEROIN ASSOCIATED OVERDOSE";
IF IKEY = 4 then LABEL="AMPHETAMINE ASSOCIATED OVERDOSE";
IF IKEY = 5 then LABEL="OTHER AND UNSPECIFIED PSYCHOSTIMULANT ASSOCIATED OVERDOSE";
IF IKEY = 6 then LABEL="BENZODIAZEPINES ASSOCIATED OVERDOSE";
IF IKEY	= 7 then LABEL="ANY OPIOID ASSOCIATED OVERDOSE";
IF IKEY = 8 then LABEL="PRIMARY DRUG OVERDOSE";
IF IKEY = 9 then LABEL="ALL ADMISSIONS OR DISCHARGES";

OUTPUT;
END;
/*Use proc timeseries to get zero counts for incomplete drugs*/
PROC SORT DATA=TABDATAB.KHAEDDATA;
BY IKEY LABEL STATE COUNTY_NAME EOM_DATE;
PROC TIMESERIES DATA=TABDATAB.KHAEDDATA OUT=TABDATAB.KHAEDDATASERIES;
BY IKEY LABEL STATE COUNTY_NAME;
ID EOM_DATE INTERVAL=MONTH START="01JAN2016"d END="30SEP2017"d SETMISSING=0 ACCUMULATE=TOTAL;
VAR ADMITS ED_P1 ED_ADMISSIONS;
DATA TABDATAB.KHAEDDATASERIES;
SET TABDATAB.KHAEDDATASERIES;
EOMDATEKEY=intnx('MONTH',EOM_DATE,0,'E')*1;
RUN;

DATA TABDATAB.KHAHDDATA (DROP= HD_H1-HD_H7);
SET TABDATAB.KHAHD2015 TABDATAB.KHAHD2016 TABDATAB.KHAHD2017;

LENGTH LABEL $50.;
ARRAY INDICATORS (*) HD_H1-HD_H7 HD_P1 HD_DISCHARGES;
DO IKEY = 1 to DIM(INDICATORS);
HOSPITALIZATIONS=INDICATORS[IKEY];
IF IKEY = 1 then LABEL="ALL DRUG ASSOCIATED OVERDOSE";
IF IKEY = 2 then LABEL="NON-HEROIN OPIOID ASSOCIATED OVERDOSE";
IF IKEY = 3 then LABEL="HEROIN ASSOCIATED OVERDOSE";
IF IKEY = 4 then LABEL="AMPHETAMINE ASSOCIATED OVERDOSE";
IF IKEY = 5 then LABEL="OTHER AND UNSPECIFIED PSYCHOSTIMULANT ASSOCIATED OVERDOSE";
IF IKEY = 6 then LABEL="BENZODIAZEPINES ASSOCIATED OVERDOSE";
IF IKEY = 7 then LABEL="ANY OPIOID ASSOCIATED OVERDOSE";
IF IKEY = 8 then LABEL="PRIMARY DRUG OVERDOSE";
IF IKEY = 9 then LABEL="ALL ADMISSIONS OR DISCHARGES";

OUTPUT;
END;
/*Use proc timeseries to get zero counts for incomplete drugs*/
PROC SORT DATA=TABDATAB.KHAHDDATA;
BY IKEY LABEL STATE COUNTY_NAME EOM_DATE;
PROC TIMESERIES DATA=TABDATAB.KHAHDDATA OUT=TABDATAB.KHAHDDATASERIES;
BY IKEY LABEL STATE COUNTY_NAME;
ID EOM_DATE INTERVAL=MONTH START="01JAN2016"d END="30SEP2017"d SETMISSING=0 ACCUMULATE=TOTAL;
VAR HOSPITALIZATIONS HD_P1 HD_DISCHARGES;
DATA TABDATAB.KHAHDDATASERIES;
SET TABDATAB.KHAHDDATASERIES;
EOMDATEKEY=intnx('MONTH',EOM_DATE,0,'E')*1;
RUN;

/*merge hospital and ed data tables*/
proc sql noprint;
create table FINAL.FINALKHAHDED AS 
SELECT coalesce(a.Ikey,b.Ikey) as Ikey, coalesce(a.label,b.label) as label, coalesce(a.STATE,b.STATE) as STATE, 
 coalesce(a.COUNTY_NAME,b.COUNTY_NAME) as COUNTY_NAME, coalesce(a.EOM_DATE,b.EOM_DATE) as EOM_DATE, 
a.HOSPITALIZATIONS, a.HD_DISCHARGES, a.HD_P1,
b.admits, b.ED_ADMISSIONS, b.ED_P1
FROM  TABDATAB.KHAHDDATASERIES as a left join TABDATAB.KHAEDDATASERIES as b on 
a.Ikey=b.Ikey and a.STATE=b.STATE and a.COUNTY_NAME=b.COUNTY_NAME 
and a.EOM_DATE=b.EOM_DATE;
QUIT;

/*merge population tables*/
proc sql noprint;
create table FINAL.FINALMEDICALPOP as select 
coalesce(a.STATE,d.STATE) as STATE, 
 coalesce(a.COUNTY_NAME,d.COUNTY_NAME) as COUNTY_NAME, coalesce(a.EOM_DATE,d.EOM_DATE) as EOM_DATE FORMAT=MONYY7., a.Ikey, a.label, 
a.HOSPITALIZATIONS, a.HD_DISCHARGES, 
a.HD_P1,
a.admits, a.ED_ADMISSIONS, a.ED_P1,
d.KSPOPYEAR, d.KSPOPweight,
d.COUNTY_ABBRV, d.COUNTYPOPYEAR,
d.HRPN_NAME, d.HRPNPOPYEAR,d.HRPNPOPWEIGHT,
d.TRAUMA_REGION,d.TRAUMAPOPYEAR,d.TRAUMAPOPWEIGHT
		FROM FINAL.FINALKHAHDED as a left join final.Finalpoptable as d on (COMPRESS(a.state)=COMPRESS(d.state) and COMPRESS(a.county_name)=COMPRESS(d.county_name)) and 
					(YEAR(a.EOM_DATE)=YEAR(d.EOM_DATE) and MONTH(a.EOM_DATE) = MONTH(D.EOM_DATE)) 
ORDER BY STATE, COUNTY_NAME, IKEY,EOM_DATE;
					QUIT;


/*Build Rate and Math Models*/

/*Two Dataset: 

	KTRACS Opioid prescription -> FINAL.ALLKTRACS
	KHA ED AND HD DATA --> FINAL.FINALMEDICALPOP

*/
DATA FINAL.ALLKTRACS2;
SET FINAL.ALLKTRACS;

/*Opioid Rx Drug Rate*/
OPIOIDPERCAPITA_COUNTYA=(OpioidRx_count/COUNTYPOPYEAR)*100;
OPIOIDPERCAPITA_COUNTY_KS=(OpioidRx_count/KSPOPYEAR)*100;
OPIOIDPERCAPITA_COUNTY_HRP=(OpioidRx_count/HRPNPOPYEAR)*100;
OPIOIDPERCAPITA_COUNTY_TRAUMA=(OpioidRx_count/TRAUMAPOPYEAR)*100;

OPIOIDPERCAPITA_STATE=(KS_OpioidRx_count/KSPOPULATION)*100;
ALLOPIOIDPERCAPITA_STATE=(OpioidRx_count/KSPOPULATION)*100;
RUN;


/*
