*-------------------------------------------------------------------*
 *  Author:  Fan Xiong            <fanxiong0728@gmail.com>           *
 *-------------------------------------------------------------------*

/*This SAS program builds a multivariate process model using birth cohort factors to identify correlated risk and protective factors 
associated with patients recieving controlled substance prescription drugs*/

/*Multidimensional Scaling*/

libname pbss "C:\TEMP\KTRACS BACKUP\PBSS FILES\KTRACS";

/*PHASE 1:*/
proc contents data=PBSS.FINALDATAMERGED2 order=varnum;
run;

DATA PBSS.Finaldatamergedb;
SET PBSS.Finaldatamerged;
PATIENTS =LOG(PATIENTS);
POPULATION = LOG(POPULATION);
ARRAY RECODE (*) marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1 MPE_F5 ;
do i = 1 to dim(RECODE);
RECODE[i]=LOG(RECODE[i])+PATIENTS;
END;
mme_dd=log(mme_dd);

PROC SUMMARY DATA=PBSS.Finaldatamergedb NOPRINT THREADS;
CLASS GENDER AGE2 BIRTHCOHORT DATE / GROUPINTERNAL;
TYPES GENDER*AGE2*BIRTHCOHORT*DATE ;
FORMAT DATE YEAR4.;
OUTPUT OUT=PBSS.ANALYSISMVP (DROP=_TYPE_ _FREQ_) 
MEAN(PATIENTS POPULATION  marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1 MPE_F5 mme_dd) = 
PATIENTS POPULATION  marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1 MPE_F5 mme_dd;
DATA PBSS.MVPFEMALE PBSS.MVPMALE;
SET PBSS.ANALYSISMVP;
ARRAY RECODE (*) PATIENTS POPULATION  marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1  mme_dd;
do i = 1 to dim(RECODE);
RECODE[i]=EXP(RECODE[i]);
END;
TIME=_N_;
IF GENDER = "M" THEN DO;
TIME=ABS(_N_-216);
OUTPUT PBSS.MVPMALE;
end;
ELSE OUTPUT PBSS.MVPFEMALE;
RUN;

ods graphics on;
/*FEMALES*/
proc mvpmodel data=PBSS.MVPFEMALE;
 var marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1  mme_dd; 
run;

/*MALES*/
proc mvpmodel data=PBSS.MVPMALE;
 var marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1  mme_dd; 
run;

ods graphics on;
/*FEMALES*/
proc mvpmodel data=PBSS.MVPFEMALE ncomp=2 plots=all OUT=PBSS.MVPFEMALEHIST OUTLOADINGS=PBSS.MVPFEMALELOAD;
 var marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1  mme_dd; 
run;

/*MALES*/
proc mvpmodel data=PBSS.MVPMALE ncomp=2 plots=all OUT=PBSS.MVPMALEHIST OUTLOADINGS=PBSS.MVPMALELOAD;
 var marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1  mme_dd; 
run;

/*PHASE 2:*/

/*FEMALES*/

ods graphics on;
proc mvpmonitor history=PBSS.MVPFEMALEHIST loadings=PBSS.MVPFEMALELOAD;
   time TIME;
   tsquarechart / contributions; 
   spechart / contributions;
run;

/*MALES*/

ods graphics on;
proc mvpmonitor history=PBSS.MVPMALEHIST loadings=PBSS.MVPMALELOAD;
   time TIME;
   tsquarechart / contributions; 
   spechart / contributions;
run;

/*Plot the loadings against cohorts*/

DATA PBSS.MVPFEMALEHIST2 (KEEP=GENDER BIRTHCOHORT TIME2 TIME VALUE MPE_F5 FACTORS REFFACTOR INDICATOR);
SET PBSS.MVPFEMALEHIST;
TIME2=MDY(1,1,(1940+(time*5)));
FORMAT TIME2 YEAR4.;
LENGTH INDICATOR $25.;
ARRAY RECODE (*) R_marital_2--R_mme_dd;
ARRAY OLDVAR (*) marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1  mme_dd;
do i = 1 to dim(RECODE);
IF TIME = 1 THEN REFFACTOR=RECODE[i];
FACTORS=RECODE[i];
VALUE=OLDVAR[i];
INDICATOR=COMPRESS(SUBSTR(VNAME(RECODE[i]),3,length(VNAME(RECODE[i]))));
OUTPUT;
END;
RUN;

proc sort data=PBSS.MVPFEMALEHIST2;
by indicator TIME2;
RUN;

proc expand data=PBSS.MVPFEMALEHIST2 OUT=PBSS.MVPFEMALEHIST2b EXTRAPOLATE;
by indicator;
id time2;
var VALUE FACTORS REFFACTOR;
RUN;

DATA PBSS.MVPFEMALEHIST2b;
SET PBSS.MVPFEMALEHIST2b;
EFFECT=(FACTORS-REFFACTOR);
RUN;

DATA PBSS.MVPMALEHIST2 (KEEP=GENDER BIRTHCOHORT TIME2 TIME VALUE MPE_F5 FACTORS REFFACTOR INDICATOR);
RETAIN REFFACTOR;
SET PBSS.MVPMALEHIST;
LENGTH INDICATOR $25.;
TIME2=MDY(1,1,(1940+(time*5)));
FORMAT TIME2 YEAR4.;
ARRAY RECODE (*) R_marital_2--R_mme_dd;
ARRAY OLDVAR (*) marital_2	genhlth_2	income2_1	educa_1	HVYALCOHOL2	PERSDOC_4	PHYHLTH_2	MNTHLTH_2 EMPLOYMENT1  mme_dd;
do i = 1 to dim(RECODE);
IF TIME = 1 THEN REFFACTOR=RECODE[i];
FACTORS=RECODE[i];
VALUE=OLDVAR[i];
INDICATOR=COMPRESS(SUBSTR(VNAME(RECODE[i]),3,length(VNAME(RECODE[i]))));
OUTPUT;
END;
RUN;


proc sort data=PBSS.MVPMALEHIST2;
by indicator TIME2;
RUN;
proc expand data=PBSS.MVPMALEHIST2 OUT=PBSS.MVPMALEHIST2b EXTRAPOLATE;
by indicator;
id time2;
var VALUE FACTORS REFFACTOR;
RUN;
DATA PBSS.MVPMALEHIST2b;
SET PBSS.MVPMALEHIST2b;
EFFECT=(FACTORS-REFFACTOR);
RUN;

proc export data=PBSS.MVPMALEHIST2b OUTFILE="C:\TEMP\Space\MPE\MALEFACTORS.XLS" dbms=xls replace;
proc export data=PBSS.MVPFEMALEHIST2b OUTFILE="C:\TEMP\Space\MPE\FEMALEFACTORS.XLS" dbms=xls replace;
RUN;

proc sgscatter data=PBSS.MVPFEMALEHIST2;
compare X=(time) y=(FACTORS) / GROUP=INDICATOR pbspline=(degree=1);
RUN; 


proc sgscatter data=PBSS.MVPFEMALEHIST2;
where time > 1;
compare X=(time) y=(MPE_F5) / GROUP=INDICATOR pbspline=(degree=1);
RUN; 
