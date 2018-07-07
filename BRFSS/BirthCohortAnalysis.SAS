*-------------------------------------------------------------------*
 *  Author:  Fan Xiong            <fanxiong0728@gmail.com>           *
*-------------------------------------------------------------------*

/*This SAS program analyzes the Kansas BRFSS data by Birth Cohort*/

/*BRFSS CODE*/

/*Kansas BRFSS DATA*/
PROC FORMAT ;
  
    value BMI_ 0='Underweight/Overweight or Obese' 1='Normal Weight' 2-3='Underweight/Overweight or Obese'  Other = "Missing";
    value income2cat 0="Less than $25,000" 1="$25,000 to less than $50,000" 
        2="$50,000 or more"  Other = "Missing";
	value workstatus 
		1 = "Employed/Retired"
		0 = "No Work / Unable to Work/Student/Homemaker"  Other = "Missing";
    Value incomecat 0-1='Less than $25,000' 
       2='$25,000 - $50,000' 3='$50,000+'  Other = "Missing";
Value educcat 0='Less than high school or High school graduate or G.E.D' 
        1='Some College to College Graduate'  Other = "Missing";
    Value ra2ce 0='White, non-Hispanic' 1='Non-Hispanic non-White and Hispanic';
    Value marital 0='Married/Member of unmarried couple' 
        1='Not currently married'  Other = "Missing";
    VAlue disability 1='Have a disability' 0='Do not have a disability'  Other = "Missing";
    VAlue insurance 0='Insured' 1='Uninsured'  Other = "Missing";
    value totinda 0='Had physical activity or exercise in last 30 days' 
        1='No physical activity or exercise in last 30 days'  Other = "Missing";
    value disease 1='Yes' 0='No'  Other = "Missing";
    value health 0='Excellent or Very Good or Good' 1='Fair or Poor'  Other = "Missing";
    value mcc 0-1='0 to 1 chronic conditions' 2-3='Two or more chronic conditions'  Other = "Missing";
	value provider 
		1-2 = "One or more regular doctor/health-care provider"
		3 = "No regular doctor/health-care provider" Other = "Missing";
RUN;

/*BRFSS Analaysis*/
/*Set libname to reference the folder where you have the dataset*/
LIBNAME KSBRFSS "H:\Health Promotion\Injury Disability\xiong_secure\BRFSS Work\KS BRFSS Datasets\Datasets";
run;
*Please assign weight variable. Please note that 'weight variable' changes by your requested variable. Refer to BRFSS Data Dictionary 'User Information' field to check 'Survey Part/Arm'. e.g. Part A, Part B or Core etc.;

/*Please use the appropriate weighting variable here. Please look at your state BRFSS documentation for defining weighing variables*/ 
%let weightvar=_LLCPWT;
*Please assign strata variable;
%let stratvar=_ststr;
*Please give the path(windows directory) for output files;
%let out=C:\Users\fxiong\TEMP\BRFSS\Local Weights;

/*Demographic and By Variables to use for domain*/
/*Domain variables to use*/ 

/*2011 Kansas BRFSS DATA*/
%LET set1 = ksbrfss.ks11internal;

/*2012 Kansas BRFSS DATA*/
%LET set2 = ksbrfss.ks12internal;

/*2013 Kansas BRFSS DATA*/
%LET set3 = ksbrfss.ks13internal;

/*2014 Kansas BRFSS DATA*/
%LET set4 = ksbrfss.ks14internal;

/*2015 Kansas BRFSS DATA*/
%LET set5 = ksbrfss.ks15internal;

/*2016 Kansas BRFSS DATA*/
%LET set6 = ksbrfss.ks16internal;

/*Combined Created 2011-2015 DATA*/
%LET data1 = ksbrfss.ks1116;

%LET BRFSSVAR =  IYEAR  SEX INCOME2  educa genhlth marital hlthpln1 _TOTINDA DIABETE3 CVDINFR4 CVDCRHD4 CVDSTRK3 ASTHMA3 asthnow CHCSCNCR 
CHCOCNCR HAVARTH3 ADDEPEV2 CHCKIDNY _BMI5 PERSDOC2
PHYSHLTH MENTHLTH SEATBELT HIVTST6 DRNKANY5 ;

data &data1 (compress=yes DROP=&BRFSSVAR );
    /*_ststr was not the same length from 2012 to 2014*/
    length _ststr 8.;
    set  
&set1 (in=in1 KEEP= _STATE _STSTR CTYCODE1 ZIPCODE _LLCPWT  IYEAR IMONTH IDAY NUMADULT NUMMEN NUMWOMEN &BRFSSVAR AGE EMPLOY CHCCOPD _RFDRHV4) 
&set2  (in=in2  KEEP=_STATE _STSTR CTYCODE1 ZIPCODE _LLCPWT IYEAR IMONTH IDAY NUMADULT NUMMEN NUMWOMEN &BRFSSVAR AGE EMPLOY CHCCOPD1 _RFDRHV4) 
&set3  (in=in3  KEEP=_STATE _STSTR CTYCODE1 ZIPCODE _LLCPWT IYEAR IMONTH IDAY NUMADULT NUMMEN NUMWOMEN &BRFSSVAR AGE EMPLOY1 CHCCOPD1 _RFDRHV4)
&set4 (in=in4 KEEP=_STATE _STSTR CTYCODE1 ZIPCODE _LLCPWT  IYEAR IMONTH IDAY NUMADULT NUMMEN NUMWOMEN &BRFSSVAR AGE EMPLOY1 CHCCOPD1 _RFDRHV4) 
&set5  (in=in5  KEEP=_STATE _STSTR CTYCODE1 ZIPCODE _LLCPWT IYEAR IMONTH IDAY NUMADULT NUMMEN NUMWOMEN &BRFSSVAR AGE EMPLOY1 CHCCOPD1 _RFDRHV5) 
&set6  (in=in6  KEEP=_STATE _STSTR CTYCODE1 ZIPCODE1 _LLCPWT IYEAR IMONTH IDAY NUMADULT NUMMEN NUMWOMEN &BRFSSVAR AGE EMPLOY1 CHCCOPD1 _RFDRHV5)
;

/*Rename variables to common variable names*/
   LENGTH STATE $2. CITY $25. ; 
IF in1 then DO;
				_RFDRHV=_RFDRHV4;
				CHCCOPD1=CHCCOPD;
				COUNTYFP=CTYCODE1;
				DATE = MDY(IMONTH,IDAY,2011);
		 		YEAR=YEAR(DATE);
				QTR=QTR(DATE);
				format DATE date9.;
				if zipcode NOT IN ("77777", "99999") THEN ZIP=ZIPCODE*1;
	if zipcode NOT IN ("77777", "99999") THEN 	STATE=COMPRESS(ZIPSTATE(ZIP));
	if zipcode NOT IN ("77777", "99999") THEN 	CITY=TRIM(UPCASE(SCAN(ZIPCITY(ZIP),1,",")));
	END;
DROP CHCCOPD;

	if in2 then  DO;				_RFDRHV=_RFDRHV4;

				COUNTYFP=CTYCODE1;
				DATE = MDY(IMONTH,IDAY,2012);
		 		YEAR=YEAR(DATE);
				QTR=QTR(DATE);
				format DATE date9.;			if zipcode NOT IN ("77777", "99999") THEN 	ZIP=ZIPCODE*1;
		if zipcode NOT IN ("77777", "99999") THEN 	STATE=COMPRESS(ZIPSTATE(ZIP));
		if zipcode NOT IN ("77777", "99999") THEN 	CITY=TRIM(UPCASE(SCAN(ZIPCITY(ZIP),1,",")));
	END;

	if in3 then  DO;				_RFDRHV=_RFDRHV4;

				EMPLOY=EMPLOY1;
				COUNTYFP=CTYCODE1;
				DATE = MDY(IMONTH,IDAY,2013);
		 		YEAR=YEAR(DATE);
				QTR=QTR(DATE);
				format DATE date9.;			if zipcode NOT IN ("77777", "99999") THEN 	ZIP=ZIPCODE*1;
		if zipcode NOT IN ("77777", "99999") THEN 	STATE=COMPRESS(ZIPSTATE(ZIP));
	if zipcode NOT IN ("77777", "99999") THEN 		CITY=TRIM(UPCASE(SCAN(ZIPCITY(ZIP),1,",")));
	END;

	if in4 then  DO;				_RFDRHV=_RFDRHV4;

					EMPLOY=EMPLOY1;

				COUNTYFP=CTYCODE1;
				DATE = MDY(IMONTH,IDAY,2014);
		 		YEAR=YEAR(DATE);
				QTR=QTR(DATE);
				format DATE date9.;			if zipcode NOT IN ("77777", "99999") THEN 	ZIP=ZIPCODE*1;
		if zipcode NOT IN ("77777", "99999") THEN 	STATE=COMPRESS(ZIPSTATE(ZIP));
		if zipcode NOT IN ("77777", "99999") THEN 	CITY=TRIM(UPCASE(SCAN(ZIPCITY(ZIP),1,",")));
	END;
		
	if in5 then  DO;				_RFDRHV=_RFDRHV5;

					EMPLOY=EMPLOY1;

				COUNTYFP=CTYCODE1;
				DATE = MDY(IMONTH,IDAY,2015);
		 		YEAR=YEAR(DATE);
				QTR=QTR(DATE);
				format DATE date9.;		
	if zipcode1 NOT IN ("77777", "99999") THEN 	ZIP=ZIPCODE1*1;
	if zipcode1 NOT IN ("77777", "99999") THEN 		STATE=COMPRESS(ZIPSTATE(ZIP));
	if zipcode1 NOT IN ("77777", "99999") THEN 		CITY=TRIM(UPCASE(SCAN(ZIPCITY(ZIP),1,",")));
	END;
		
	if in6 then  DO;_RFDRHV=_RFDRHV5;
					EMPLOY=EMPLOY1;

				COUNTYFP=CTYCODE1;
				DATE = MDY(IMONTH,IDAY,2016);
		 		YEAR=YEAR(DATE);
				QTR=QTR(DATE);
				format DATE date9.;
if zipcode1 NOT IN ("77777", "99999") THEN 		ZIP=ZIPCODE1*1;
	if zipcode1 NOT IN ("77777", "99999") THEN 		STATE=COMPRESS(ZIPSTATE(ZIP));
	if zipcode1 NOT IN ("77777", "99999") THEN 		CITY=TRIM(UPCASE(SCAN(ZIPCITY(ZIP),1,",")));
	END;

drop employ1 zipcode1 zipcode;

IF STATE NE "KS" THEN STATE="  ";
IF STATE NE "KS" THEN CITY="  ";
IF STATE NE "KS" THEN ZIP=.;



IF CTYCODE1 IN (1:209) then CountyFp=CTYCODE1;
	ELSE CountyFp = .;


length patient_gender $1.;
 /*male*/
    If sex=1 then
        patient_gender="M";

    /*Female*/
    else if sex=2 then
        patient_gender="F";

    /*Missing*/
    else
        patient_gender="U";

    /*'Less than $15,000'*/
    if income2 in (1:2) then
        income2_=0;

    /*'$15,000 to less than $25,000'*/
    else if income2 in (3:4)  then
        income2_=1;

  /*'$25,000 to less than $50,000'*/
    else if income2 in (5:6)  then
        income2_=2;

  /*'$50,000 or more'*/
    else if income2 in (7,8)  then
        income2_=3;

	/*mising income*/
		else income2_=.;

	/*Employment status*/

		if EMPLOY IN (1,2,7) THEN EMPLOYMENT=1;
			ELSE IF EMPLOY IN (3,4,5,6,8) THEN EMPLOYMENT=0;
			else employment = . ;

    /*Less than high school or high school*/
    if educa IN (1:4) then
        educa_=0;

    /*Some college or technical school and higher*/
    else if educa IN (5:6) then
        educa_=1;

    /*Missing*/
    else
        educa_=.;

    /*Excellent, very good, or good*/
    if genhlth IN (1:3) then
        genhlth_=0;

    /*fair or poor*/
    else if genhlth IN (4:5) then
        genhlth_=1;

    /* Missing*/
    else
        genhlth_=.;

    /*Married or member of unmarried couple*/
    if marital=1 or marital=6 then
        marital_=0;

    /*Divorced, seperated, widowed, or never marrried*/
    else if marital=2 or marital=3 or marital=4 or marital=5 then
        marital_=1;

    /*missing*/
    else
        marital_=.;

    /*Insured*/
    if hlthpln1=1 then
        hlthpln1_=0;

    /*Uninsured*/
    else if hlthpln1=2 then
        hlthpln1_=1;

    /* Missing*/
    else
        hlthpln1_=.;

    /*Had physical activity or exercise in the past 30 days*/
    if _TOTINDA=1 then
        _TOTINDA_=0;

    /*No physical activity or exercise in the past 30 days*/
    else if _TOTINDA=2 then
        _TOTINDA_=1;

    /*Missing*/
    else
        _TOTINDA_=.;

****code from ericka****;
    *define your prevalence of falls variable, account for missing - take them out;
    *and then define injuries among those who have fallen ****;

    /*Multiple Chronic Conditions*/
    /* Multiple Chronic Conditions include disability, arthritis, asthma, chronic obstructive pulmonary disease, coronary heart
    disease, diabetes, heart attack, visually impaired, depression, kidney disease, skin cancer, other cancers (excluding skin), or stroke*/
    *Diabetes recode;
    *Have diabetes;

if DIABETE3=1 then
        diabetes=1;
    *No diabetes;
    else if DIABETE3=2 or DIABETE3=3 or DIABETE3=4 then
        diabetes=0;
    else
        diabetes=.;
    
    *heart attack;
    *heart attack is yes;

    if CVDINFR4=1 then
        heartattack=1;
    *no heart attack;
    else if CVDINFR4=2 then
        heartattack=0;
    else
        heartattack=.;
    *CHD;
    *coronary heart disease;

    if CVDCRHD4=1 then
        CHD=1;
    *no coronary heart disease;
    else if CVDCRHD4=2 then
        CHD=0;
    else
        CHD=.;
    *stroke;
    *stroke;

    if CVDSTRK3=1 then
        stroke=1;
    *no stroke;
    else if CVDSTRK3=2 then
        stroke=0;
    else
        stroke=.;
    *Asthma;
    *current asthma;

    if ASTHMA3=1 and asthnow=1 then
        asthma=1;
    *no (current) asthma;
    else if ASTHMA3=1 and asthnow=2 then
        asthma=0;
    *no asthma ever is still no asthma;
    else if ASTHMA3=2 then
        asthma=0;
    else
        asthma=.;
    *Skin Cancer;

    /*skin cancer*/
    if CHCSCNCR=1 then
        skin=1;

    /*no skin cancer*/
   else if CHCSCNCR=2 then  
        skin=0;  ***NOTE TO FAN: need an else before your if here;
    else skin=.;
    *cancer (except skin);
    *cancer;

    if CHCOCNCR=1 then
        cancer=1;
    *no cancer;
    else if CHCOCNCR=2 then
        cancer=0;
    else
        cancer=.;
    *arthritis;

    if HAVARTH3=1 then
        arthritis=1;
    *no arthritis;
    else if HAVARTH3=2 then
        arthritis=0;
    else
        arthritis=.;
    *depression;

    if ADDEPEV2=1 then
        depression=1;
    *no depression;
    else if ADDEPEV2=2 then
        depression=0;
    else
        depression=.;
    *kidney disease;

    if CHCKIDNY=1 then
        kidney=1;
    *no kidney disease;
    else if CHCKIDNY=2 then
        kidney=0;
    else
        kidney=.;
    *COPD;

    if CHCCOPD1=1 then
        COPD=1;

    *No COPD;
    else if CHCCOPD1=2 then
        COPD=0;
    else
        COPD=.;*/

    *BMI';

    /*Underweight*/
    if _BMI5 < 1850 then
        bmi_=0;

    /*Normal weight*/
    else if 1850 <=_BMI5 < 2500 then
        bmi_=1;

    /*overweight*/
    else if 2500 <=_BMI5 < 3000 then
        bmi_=2;

    /*Obese*/
    else if 3000 <=_BMI5 < 9999 then
        bmi_=3;
    else
        bmi_=.;
    *Multiple Chronic Conditions Count;
    *Any mentions of any chronic conditions from Jeanie's list;
    mcc_count=0;


    /*count the number of MCC*/
    array mcc [*] diabetes arthritis CHD heartattack cancer skin stroke 
        kidney depression copd asthma;
    /*Hypertension and visually impaired questions were not asked on both years*/
    do i=1 to dim(mcc);

        /*count the number of chronic conditions*/
        IF mcc[i]=1 then
            mcc_count=mcc_count+1;
    end;

    /*No chronic condions*/
    If mcc_count=0 then
        mcc_=0;

    /*1 chronic condion*/
    If mcc_count=1 then
        mcc_=1;

    /*2 chronic condition*/
    else if mcc_count=2 then
        mcc_=2;

    /*3+ chronic condition*/
    else if mcc_count ge 3 then
        mcc_=3;

		else mcc_ = .;

	/*providers*/
		if PERSDOC2 = 1 then PERSDOC_=1;
		else if  PERSDOC2 = 2 then PERSDOC_=2;
		else if  PERSDOC2 = 3 then PERSDOC_=3;
		else PERSDOC_=.;

	/*physical or mental health not good*/

	if 14<= PHYSHLTH <= 30 then PHYHLTH_=1;
		else if 1<=PHYSHLTH < 14 then PHYHLTH_=0;
		else if PHYSHLTH = 88 then PHYHLTH_=0;
		else PHYHLTH_=.;

if 14<= MENTHLTH <= 30 then MNTHLTH_=1;
		else if 1<=MENTHLTH < 14 then MNTHLTH_=0;
		else if MENTHLTH = 88 then MNTHLTH_=0;
		else MNTHLTH_=.;

	/*high risk behaviours*/
		if SEATBELT IN (3:5) THEN HIGHRISK1=1; else if SEATBELT IN (1:2) THEN HIGHRISK1=0; ELSE HIGHRISK1=.;
		if HIVTST6 = 1 THEN HIGHRISK3=1; else if HIVTST6 = 2  THEN HIGHRISK3=0; ELSE HIGHRISK3=.;

label PERSDOC_ = "Number of Providers"
	  PHYHLTH_ = "14 Days or More of Physical Health Not Good"
	  MNTHLTH_ = "14 Days or More of Mental Health Not Good"
	  HIGHRISK1 = "Seldom to Never Using Seatbelt"
	  HIGHRISK3 = "Tested for HIV";

	  /*any alcohol use*/
	  if DRNKANY5 = 1 then ANYALCOHOL=1;
	  ELSE if DRNKANY5 = 2 then ANYALCOHOL=0;
	  	ELSE ANYALCOHOL =.;

	  /*heavy alcohol use*/

	  if _RFDRHV =1 THEN HVYALCOHOL=0;
	  	ELSE IF _RFDRHV =2 THEN HVYALCOHOL=1;
		ELSE HVYALCOHOL=.;

	label HVYALCOHOL = "Heavy Alcohol Use";

 

	/*Test Individual Year for Age Prevalence*/
	IF IN1 THEN DOMAIN ="2011";
	ELSE IF IN2 THEN DOMAIN ="2012";
	ELSE IF IN3 THEN DOMAIN ="2013";
	ELSE IF IN4 THEN DOMAIN ="2014";
	ELSE IF IN5 THEN DOMAIN ="2015";
	ELSE IF IN6 THEN DOMAIN ="2016";

	/*Calculate the normalized weight for each observation*/
	   /*divide weight by six for six survey years*/
	IF IN1 THEN _LLCPWT6 =_LLCPWT*(20712/104962);
	ELSE IF IN2 THEN _LLCPWT6 =_LLCPWT*(11801/104962);
	ELSE IF IN3 THEN _LLCPWT6 =_LLCPWT*(23282/104962);
	ELSE IF IN4 THEN _LLCPWT6 =_LLCPWT*(13743/104962);
	ELSE IF IN5 THEN _LLCPWT6 =_LLCPWT*(23236/104962);
	ELSE IF IN6 THEN _LLCPWT6 =_LLCPWT*(12188/104962);

    IF 18<=AGE<=24 THEN TESTAGE=1;
	ELSE IF 25<=AGE<=34 THEN TESTAGE=2;
	ELSE IF 35<=AGE<=44 THEN TESTAGE=3;
	ELSE IF 45<=AGE<=54 THEN TESTAGE=4;
	ELSE IF 55<=AGE<=64 THEN TESTAGE=5;
	ELSE IF 65<=AGE THEN TESTAGE=6;
	ELSE TESTAGE=7;

/*Create 5-years Age Group for Pooled Estimates*/
	IF 18<=AGE<=22 THEN AGEGROUP5=1;
	ELSE IF 23<=AGE<=27 THEN AGEGROUP5=2;
	ELSE IF 28<=AGE<=32 THEN AGEGROUP5=3;
	ELSE IF 33<=AGE<=37 THEN AGEGROUP5=4;
	ELSE IF 38<=AGE<=42 THEN AGEGROUP5=5;
	ELSE IF 43<=AGE<=47 THEN AGEGROUP5=6;
	ELSE IF 48<=AGE<=52 THEN AGEGROUP5=7;
	ELSE IF 53<=AGE<=57 THEN AGEGROUP5=8;
	ELSE IF 58<=AGE<=62 THEN AGEGROUP5=9;
	ELSE IF 63<=AGE<=67 THEN AGEGROUP5=10;
	ELSE IF 68<=AGE<=72 THEN AGEGROUP5=11;
	ELSE IF 73<=AGE<=77 THEN AGEGROUP5=12;
	ELSE IF 78<=AGE<=82 THEN AGEGROUP5=13;
	ELSE IF 82<=AGE THEN AGEGROUP5=14;
	ELSE AGEGROUP5=.;


/***********Create Birth Cohort from Age--use 5-years birth cohort*********************/

if TESTAGE NE 7 THEN birthcohort=iyear-age;
else birthcohort=.;

			IF BIRTHCOHORT <= 1934 THEN COHORTGROUP5=1;
			ELSE IF 1935 <= BIRTHCOHORT < 1940 THEN COHORTGROUP5=2;

			ELSE IF 1940 <= BIRTHCOHORT <= 1944 THEN COHORTGROUP5=3 ;
			ELSE IF 1945 <= BIRTHCOHORT < 1950 THEN COHORTGROUP5=4 ;

				ELSE IF 1950 <= BIRTHCOHORT <= 1954 THEN COHORTGROUP5=5;
			ELSE IF 1955 <= BIRTHCOHORT < 1960 THEN COHORTGROUP5=6 ;

					ELSE IF 1960 <= BIRTHCOHORT <= 1964 THEN COHORTGROUP5=7 ;
			ELSE IF 1965 <= BIRTHCOHORT < 1970 THEN COHORTGROUP5=8 ;

					ELSE IF 1970 <= BIRTHCOHORT <= 1974 THEN COHORTGROUP5=9;
			ELSE IF 1975 <= BIRTHCOHORT < 1980 THEN COHORTGROUP5=10;

					ELSE IF 1980 <= BIRTHCOHORT <= 1984 THEN COHORTGROUP5=11;
			ELSE IF 1985 <= BIRTHCOHORT < 1990 THEN COHORTGROUP5=12;

					ELSE IF 1990 <= BIRTHCOHORT <= 1994 THEN COHORTGROUP5=13;
			ELSE IF 1995 <= BIRTHCOHORT < 2000 THEN COHORTGROUP5=14 ;
			ELSE COHORTGROUP5=.;



RUN;

PROC FORMAT;
VALUE COHORT 
1 = "1900-1934"
2 = "1935-1939"
3 = "1940-1944"
4 = "1945-1949"
5 = "1950-1954"
6 = "1955-1959"
7 = "1960-1964"
8 = "1965-1969"
9 = "1970-1974"
10 = "1975-1979"
11 = "1980-1984"
12 = "1985-1989"
13 = "1990-1994"
14 = "1995-1999"
.  = "Missing";

VALUE TESTAGE 
1 = "18-24"
2 = "25-34"
3 = "35-44"
4="45-54"
5="55-64"
6="65+"
7="Missing"
;

VALUE TEST5AGE 
1 = "18-22"
2 = "23-27"
3 = "28-32"
4="33-37"
5="38-42"
6="43-47"
7="48-52"
8 = "53-57"
9 = "58-62"
10 = "63-67"
11="68-72"
12="73-77"
13="82+"
14="Missing"
;
RUN;

/*Test Adults who are heavy alcohol drinker*/
/*DATA ksbrfss.weight_sum;
SET ksbrfss.weight_sum;
SAMPLE=_FREQ_;
proc summary data=ksbrfss.weight_sum;
OUTPUT OUT=KSBRFSS.TOTALWEIGHT SUM(SAMPLE sum_wt) = SAMPLE sum_wt;
RUN;*/

/*Individual year*/
proc surveyfreq data=ksbrfss.ks1116 NOMCAR;
format  TESTAGE TESTAGE. PERSDOC_ provider. HIGHRISK1 HIGHRISK3 HVYALCOHOL diabetes arthritis CHD heartattack cancer skin stroke 
        kidney depression copd asthma PHYHLTH_  MNTHLTH_ ANYALCOHOL disease. mcc_ mcc. genhlth_ health. employment workstatus. income2_ incomecat. educa_ educcat. marital_ marital. hlthpln1_ insurance. ;
tables DOMAIN*PATIENT_GENDER*TESTAGE*HVYALCOHOL / ROW cl cv;
weight _LLCPWT6;
STRATA _STSTR;
ODS OUTPUT CROSSTABS=KSBRFSS.TESTCROSSTAB;
DATA KSBRFSS.TESTCROSSTAB;
SET KSBRFSS.TESTCROSSTAB;
IF F_HVYALCOHOL = "Yes" AND F_TESTAGE NE "Total";
IF TESTAGE NE 7;
FORMAT ROWPERCENT 9.1;
DROP PERCENT StdErr LowerCl UpperCL _SkipLine;
RUN;


/*Pooled year*/
proc surveyfreq data=ksbrfss.ks1116 NOMCAR;
format  TESTAGE TESTAGE. PERSDOC_ provider. HIGHRISK1 HIGHRISK3 HVYALCOHOL diabetes arthritis CHD heartattack cancer skin stroke 
        kidney depression copd asthma PHYHLTH_  MNTHLTH_ ANYALCOHOL disease. mcc_ mcc. genhlth_ health. employment workstatus. income2_ incomecat. educa_ educcat. marital_ marital. hlthpln1_ insurance. ;
tables PATIENT_GENDER*TESTAGE*HVYALCOHOL / ROW cl cv;
weight _LLCPWT6;
STRATA _STSTR;
ODS OUTPUT CROSSTABS=KSBRFSS.TESTCROSSTAB2;
DATA KSBRFSS.TESTCROSSTAB2;
SET KSBRFSS.TESTCROSSTAB2;
IF F_HVYALCOHOL = "Yes" AND F_TESTAGE NE "Total";
IF TESTAGE NE 7;
FORMAT ROWPERCENT 9.1;
DROP PERCENT StdErr LowerCl UpperCL _SkipLine;
RUN;

/*Pooled year for birthcohortgroup*/

/*Test 5-years age Group*/
proc surveyfreq data=ksbrfss.ks1116 NOMCAR;
format  AGEGROUP5 TEST5AGE. PERSDOC_ provider. HIGHRISK1 HIGHRISK3 HVYALCOHOL diabetes arthritis CHD heartattack cancer skin stroke 
        kidney depression copd asthma PHYHLTH_  MNTHLTH_ ANYALCOHOL disease. mcc_ mcc. genhlth_ health. employment workstatus. income2_ incomecat. educa_ educcat. marital_ marital. hlthpln1_ insurance. ;
tables PATIENT_GENDER*AGEGROUP5*HVYALCOHOL / ROW cl cv;
weight _LLCPWT6;
STRATA _STSTR;
ODS OUTPUT CROSSTABS=KSBRFSS.TESTCROSSTAB3;
DATA KSBRFSS.TESTCROSSTAB3;
SET KSBRFSS.TESTCROSSTAB3;
IF F_HVYALCOHOL = "Yes" AND F_AGEGROUP5 NE "Total";
IF AGEGROUP5 NE .;
RSE=RowStdErr/ROWPERCENT;
IF RSE > 0.30 THEN ROWPERCENT=.;
FORMAT ROWPERCENT 9.1;
DROP PERCENT StdErr LowerCl UpperCL _SkipLine;
RUN;

proc surveyfreq data=ksbrfss.ks1116 NOMCAR;
format  COHORTGROUP5 COHORT. PERSDOC_ provider. HIGHRISK1 HIGHRISK3 HVYALCOHOL diabetes arthritis CHD heartattack cancer skin stroke 
        kidney depression copd asthma PHYHLTH_  MNTHLTH_ ANYALCOHOL disease. mcc_ mcc. genhlth_ health. employment workstatus. income2_ incomecat. educa_ educcat. marital_ marital. hlthpln1_ insurance. ;
tables PATIENT_GENDER*COHORTGROUP5*HVYALCOHOL / ROW cl cv;
weight _LLCPWT6;
STRATA _STSTR;
ODS OUTPUT CROSSTABS=KSBRFSS.TESTCROSSTAB4;
DATA KSBRFSS.TESTCROSSTAB4;
SET KSBRFSS.TESTCROSSTAB4;
IF F_HVYALCOHOL = "Yes" AND F_COHORTGROUP5 NE "Total";
IF COHORTGROUP5 NE .;
RSE=RowStdErr/ROWPERCENT;
IF RSE > 0.30 THEN ROWPERCENT=.;
FORMAT ROWPERCENT 9.1;
DROP PERCENT StdErr LowerCl UpperCL _SkipLine;
RUN;

/*Compare Scatter Plot of Age - Prevalence*/
		PROC SGSCATTER DATA=KSBRFSS.TESTCROSSTAB;
		format  TESTAGE TESTAGE. ROWPERCENT 9.1;
		PLOT RowPercent*TESTAGE / GROUP=DOMAIN REG=(DEGREE=3);
		Title "Heavy Alcohol Consumption in the Past 30 Days - Male";
		WHERE PATIENT_GENDER = "M";
		PROC SGSCATTER DATA=KSBRFSS.TESTCROSSTAB;
		format  TESTAGE TESTAGE. ROWPERCENT 9.1;
		PLOT RowPercent*TESTAGE / GROUP=DOMAIN REG=(DEGREE=3);
		Title "Heavy Alcohol Consumption in the Past 30 Days - Female";
		WHERE PATIENT_GENDER = "F";
		RUN;

		PROC SGSCATTER DATA=KSBRFSS.TESTCROSSTAB2;
		format  TESTAGE TESTAGE. ROWPERCENT 9.1;
		PLOT RowPercent*TESTAGE / GROUP=PATIENT_GENDER REG=(DEGREE=3);
		Title "Heavy Alcohol Consumption in the Past 30 Days by Gender";
		RUN;
		/*Compare Scatter Plot of Cohort Group - Prevalence*/
	
		PROC SGSCATTER DATA=KSBRFSS.TESTCROSSTAB3;
		format AGEGROUP5 TEST5AGE.  ROWPERCENT 9.1;
		PLOT RowPercent*AGEGROUP5 / GROUP=PATIENT_GENDER REG=(DEGREE=3);
		Title "Heavy Alcohol Consumption in the Past 30 Days by Gender";
		RUN;

		PROC SGSCATTER DATA=KSBRFSS.TESTCROSSTAB4;
		format  COHORTGROUP5 COHORT. ROWPERCENT 9.1;
		PLOT RowPercent*COHORTGROUP5 / GROUP=PATIENT_GENDER REG=(DEGREE=3);
		Title "Heavy Alcohol Consumption in the Past 30 Days by Gender";
		RUN;


%macro brfssfreq (i=,var=);

proc surveyfreq data=ksbrfss.ks1116 NOMCAR;
format  COHORTGROUP5 COHORT. PERSDOC_ provider. HIGHRISK1 HIGHRISK3 HVYALCOHOL diabetes arthritis CHD heartattack cancer skin stroke 
        kidney depression copd asthma PHYHLTH_  MNTHLTH_ ANYALCOHOL disease. mcc_ mcc. genhlth_ health. employment workstatus. income2_ incomecat. educa_ educcat. marital_ marital. hlthpln1_ insurance. ;
tables PATIENT_GENDER*COHORTGROUP5*&VAR / ROW cl cv;
weight _LLCPWT6;
STRATA _STSTR;
ODS OUTPUT CROSSTABS=KSBRFSS.&VAR;

DATA ksbrfss.brfss&i (KEEP= COHORTPOPULATION PATIENT_GENDER LEVEL VARN F_&VAR PERCENT&i CV&i WgtFreq&i Freq&i);
SET KSBRFSS.&VAR;
DROP PERCENT StdErr LowerCl UpperCL _SkipLine;
IF F_COHORTGROUP5 NE "Total" AND F_&VAR NE "Total";
IF F_&VAR  IN ("Yes","Two or more chronic conditions",
			"Fair or Poor","Uninsured","Not currently married","No Work / Unable to Work/Student/Homemaker",
			"White, non-Hispanic","Less than $25,000","No physical activity or exercise in last 30 days",
			"Underweight/Overweight or Obese","Less than high school or High school graduate or G.E.D","No regular doctor/health-care provider");

LENGTH COHORTPOPULATION LEVEL $20.;
COHORTPOPULATION=TRIM(F_COHORTGROUP5);
RSE&i=RowStdErr/ROWPERCENT;
PERCENT&i = ROWPercent;
WgtFreq&i=INT(WgtFreq);
Freq&i=Frequency;
LEVEL=COMPRESS(F_&VAR);
VARN=&VAR+1;
*END;
label PERCENT&i = "Percent &var";

proc sort data=ksbrfss.brfss&i ;
by  PATIENT_GENDER COHORTPOPULATION VARN;
proc transpose data=ksbrfss.brfss&i out=ksbrfss.brfssw&i (DROP=_NAME_) prefix=&VAR;
by  PATIENT_GENDER COHORTPOPULATION;
WHERE PATIENT_GENDER IN ("M","F");
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
by  PATIENT_GENDER COHORTPOPULATION;
data ksbrfss.alldata;
set ksbrfss.brfssw0 (DROP=_LABEL_) ;

%do set = 1 %to 23;
proc sort data=ksbrfss.brfssw&SET;
by  PATIENT_GENDER COHORTPOPULATION;
data ksbrfss.alldata;
merge ksbrfss.alldata ksbrfss.brfssw&SET (DROP=_LABEL_) ;
by  PATIENT_GENDER COHORTPOPULATION;
RUN;
%END;
%mend;
%append;

