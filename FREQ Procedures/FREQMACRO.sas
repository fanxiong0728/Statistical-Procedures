
/*This macro creates summary counts by year, month, age groups, and patient residence for each outcome of interest from ICD-9-CM and ICD-10-CM*/
 *-------------------------------------------------------------------*
 *  Author:  Fan Xiong            <fanxiong0728@gmail.com>           *
 *-------------------------------------------------------------------*

%macro FREQICD9(YEAR=,OUTCOME=);
	/*Run this file reader to access Libname Engines relevant for analysis*/
	%include "H:\Health Promotion\Injury Disability\secure_injury_data\KHA ED Database\Kansas Opioid ED\Create Libname Macro 11.30.2017 FX.sas";
	/*Temp Library*/
	Libname EDT "C:\TEMP\Space\ED BUILD"; 
PROC FREQ DATA=CDC.ICD9&YEAR NOPRINT ;
		TABLE ADMITYEAR*(&OUTCOME) / OUT=EDT.ANNUALICD9&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITMONTH*(&OUTCOME) / OUT=EDT.MONTHLYICD9&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITYEAR*AGEG*(&OUTCOME) / OUT=EDT.YEARAGEGICD9&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITMONTH*AGEG(&OUTCOME) / OUT=EDT.MONTHAGEGICD9&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITYEAR*TR*(&OUTCOME) / OUT=EDT.YEARPATTRICD9&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITYEAR*HTR*(&OUTCOME) / OUT=EDT.YEARHOSPTRICD9&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITMONTH*TR*(&OUTCOME) / OUT=EDT.MONTHPATTRICD9&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITMONTH*HTR*(&OUTCOME) / OUT=EDT.MONTHHOSPTRICD9&OUTCOME&YEAR nopercent norow nocol;
RUN;
%MEND;

%macro FREQICD10(YEAR=,OUTCOME=);
	/*Run this file reader to access Libname Engines relevant for analysis*/
	%include "H:\Health Promotion\Injury Disability\secure_injury_data\KHA ED Database\Kansas Opioid ED\Create Libname Macro 11.30.2017 FX.sas";
	/*Temp Library*/
	Libname EDT "C:\TEMP\Space\ED BUILD"; 
PROC FREQ DATA=CDC.ICD10&YEAR NOPRINT ;
		TABLE ADMITYEAR*(&OUTCOME) / OUT=EDT.ANNUALICD10&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITMONTH*(&OUTCOME) / OUT=EDT.MONTHLYICD10&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITYEAR*AGEG*(&OUTCOME) / OUT=EDT.YEARAGEGICD10&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITMONTH*AGEG(&OUTCOME) / OUT=EDT.MONTHAGEGICD10&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITYEAR*TR*(&OUTCOME) / OUT=EDT.YEARPATTRICD10&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITYEAR*HTR*(&OUTCOME) / OUT=EDT.YEARHOSPTRICD10&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITMONTH*TR*(&OUTCOME) / OUT=EDT.MONTHPATTRICD10&OUTCOME&YEAR nopercent norow nocol;
		TABLE ADMITMONTH*HTR*(&OUTCOME) / OUT=EDT.MONTHHOSPTRICD10&OUTCOME&YEAR nopercent norow nocol;
RUN;
%MEND;
