*-------------------------------------------------------------------*
 *  Author:  Fan Xiong            <fanxiong0728@gmail.com>           *
 *-------------------------------------------------------------------*

 /*Below is a Series of Programming Steps to Implement a Faster Search of Distinct Words on Death Certificate Literals*/ 
  
/*Users will have to modify programming steps for your own data by inputing the correct path, libname, dataset name, and variables*/ 
 
/*General Idea: Use a table of unique words and their frequency to identify and classify terms for your data (old or new). Then use this table as a lookup on all death records*/ 
/* 	 	 	 	This method borrows from bag of words association machine learning algorithms where the purpose is to look for key words of interest and their dependencies based on their relative frequency.*/ 
/* 	 	 	 	It is difficult to identify a method that will be 
highly accurate. The initial word table building assumes death records with a drug poisoning underlying cause of death will have enough language variation to create a search algorithim*/ 
/* 	 	 	 	This method was developed to quickly extract drugs or 
substances mentioned among death certificates to educate coroners about why specificity is important.*/ 
 
 
/*How was this used? */ 
 
 	/*Brand name drugs and acryonyms were found among death certificates.*/  
 	/*Coroners were advised to use generic names or compounds, since brand name drugs may change purpose or compounds over time (i.e. not robust over time).*/ 
 
 	/*Acryonyms for street-drugs were found and coroners were advised to use chemical compounds closest to the drug or a generic drug class (e.g., Methamphtemine for Molly) since street names are not robust to changes over time.*/ 
 
 
/*Find the Most Common English Words*/ 
 
 	 	/*literals is a variable for CAUSE of DEATH sections desired to do the search*/ 
 
/*  
length word1-word100 $100.; array wdarray (*) word1-word100; do i = 1 to dim(wdarray); wdarray[i]=SCAN(literals,i," "); 
IF wdarray[i] IN 
("THE","BE","TO","OF","AND","A","IN","THAT","HAVE","I","IT","FOR","NOT","ON",
"WITH","HE","AS","YOU","DO", 
"AT","THIS","BUT","HIS","BY","FROM","THEY","WE","SAY","HER","SHE","OR","AN", "WILL","MU","ONE","ALL","WOULD","THERE","THEIR","WHAT","SO","UP","OUT","IF","
ABOUT","WHO","GET","WHICH","GO","ME","WHEN", 
"MAKE","CAN","LIKE","TIME","NO","JUST","HIM","KNOW","TALE","PEOPLE", "INTO","YEAR","YOUR","GOOD","SOME","COULD","THEM","SEE","OTHER","THAN","THEN" ,"NOW","LOOK","ONLY","COME","ITS","OVER","THINK","ALSO","BACK","AFTER","USE",
"TWO","HOW","OUR", 
"WORK","FIRST","WELL","WAY","EVEN","NEW","WANT","BECAUSE","ANY","THESE","GIVE
","DAY","MOST","US") THEN wdarray[i] = " "; 
END; 
 
*/ 
 
 
data temp.drugscan;
set temp.drugsearch;
where acmeuc_drugpois =1;

length word1-word100 $100.;
array wdarray (*) word1-word100;
do i = 1 to dim(wdarray);
wdarray[i]=STRIP(SCAN(literals,i,"| "));

IF wdarray[i] IN ("THE","BE","TO","OF","AND","A","IN","THAT","HAVE","I","IT","FOR","NOT","ON","WITH","HE","AS","YOU","DO",
"AT","THIS","BUT","HIS","BY","FROM","THEY","WE","SAY","HER","SHE","OR","AN",
"WILL","MU","ONE","ALL","WOULD","THERE","THEIR","WHAT","SO","UP","OUT","IF","ABOUT","WHO","GET","WHICH","GO","ME","WHEN",
"MAKE","CAN","LIKE","TIME","NO","JUST","HIM","KNOW","TALE","PEOPLE",
"INTO","YEAR","YOUR","GOOD","SOME","COULD","THEM","SEE","OTHER","THAN","THEN","NOW","LOOK","ONLY","COME","ITS","OVER","THINK","ALSO","BACK","AFTER","TWO","HOW","OUR",
"WORK","FIRST","WELL","WAY","EVEN","NEW","WANT","BECAUSE","ANY","THESE","GIVE","DAY","MOST","US") THEN wdarray[i] = " ";
END;
RUN;

/*SAS Macro to Output Individual Words by Position and Frequency of 
Mentions*/ 
%macro wordfreq; 
LIBNAME wordfreq "C:\TEMP\DIM\Word Freq Data"; 
%do col = 1 %to 100; 
proc freq data=temp.drugscan noprint; 
TABLE word&col / nopercent list out=wordfreq.word&col (DROP=PERCENT 
RENAME=(COUNT=WordCNT&col) RENAME=(Word&col=WORD)); where word&col  NE "    "; proc sort data=wordfreq.word&col; 
by word; RUN; 
%END; 
%MEND; 
 
%wordfreq; 
 
 
/*Append all word frequency table*/ 
 
DATA wordfreq.allfreq; set wordfreq.word1-wordfreq.word100; by word; 
/*Create a Summary Table at the Individual Word Level*/ 
 
proc summary data=wordfreq.allfreq NOPRINT THREADS CHARTYPE; 
CLASS WORD / ascending; 
TYPES WORD; 
VAR _NUMERIC_; 
OUTPUT OUT=wordfreq.allfreqmatrix (DROP=_TYPE_ _FREQ_)  
SUM=/autoname; 
RUN; 
 
 
DATa wordfreq.allfreqmatrix2; 
SET wordfreq.allfreqmatrix; by word; 
 
/*set the first mentioned of a word to zero*/ if first.word then do; 
/*add up the number of records mentioning the word*/ 
TotalFrequency=0; end; 
 
/*set all missing frequency zero*/ array freq (*) WordCNT1_Sum--WordCNT100_Sum; do i = 1 to dim(freq); 
if freq[i] = . then freq[i] = 0; 
ELSE TotalFrequency= freq[i]+TotalFrequency; end; RUN; 
 
 
/*Manually identify words as drugs, descriptors, etc*/ 
proc export data=wordfreq.allfreqmatrix2 OUTFILE="C:\TEMP\DIM\Word Freq Data\allfreqmatrix2.xls" dbms=xls replace;run; 
 
 
/*This lets you search only the number of unique words among death certificates rather than searching all death certificates*/ 
 
/*Import Data back into SAS*/ 
 
proc import datafile="C:\TEMP\DIM\Word Freq Data\allfreqmatrix2.xls" dbms=xls out=Wordfreq.foundwords replace; 
RUN; 
 
/*Remove missing words and remove leading and trailing blanks due to Excel encoding errrors*/ DATA Wordfreq.foundwords; set Wordfreq.foundwords; 
 
LENGTH SUBSTANCE DESCRIPTOR_PHRASE $35.; 
SUBSTANCE=COMPRESS(Substance_Mentioned," "); 
DESCRIPTOR_PHRASE=COMPRESS(Descriptor," "); 
IF WORD NE " "; 
RUN; 
 
/*macro variables for lookups*/ proc sql noprint; 
 
/*These macro variables can be used in a list for processing*/ 
select QUOTE(COMPRESS(SUBSTANCE))  INTO: SubstanceTerms SEPERATED BY "," FROM Wordfreq.foundwords WHERE MISSING(SUBSTANCE) = 0; 
select QUOTE(COMPRESS(DESCRIPTOR_PHRASE)) INTO: DescriptorTerms SEPERATED BY "," FROM Wordfreq.foundwords WHERE MISSING(DESCRIPTOR_PHRASE) = 0;  
/*These macro variables can be used in a regular expression for matching--> takes a long time and may lead to irregular results*/ 
 
select COMPRESS(SUBSTANCE)  INTO: SubstanceTerms2 SEPERATED BY "|" FROM Wordfreq.foundwords WHERE MISSING(SUBSTANCE) = 0; 
select COMPRESS(DESCRIPTOR_PHRASE) INTO: DescriptorTerms2 SEPERATED BY "|" FROM Wordfreq.foundwords WHERE MISSING(DESCRIPTOR_PHRASE) = 0; 
 
QUIT; 
 
 
/*Use this in a new SAS program among all death records*/  
/*Search for specific drugs among literals*/  
 
 	 	 	 	LENGTH word1-word100 $100.; 
 	 	 	 	array wdfreq (*) word1-word100; 
 	 	 	 	do i = 1 to dim(wdfreq); 
    /*literals is a variable for CAUSE of DEATH sections desired to do the search*/ 
 	 	 	 	 	wdfreq[i]=SCAN(literals,i," ");  	 	 	 	 	/*Search for Mentions of Drugs/Substances*/ 
 	 	 	 	 	IF MISSING(COMPRESS(wdfreq[i])) = 0 THEN DO; 
 	 	 	 	 	 	/*List processing*/ 
 	 	 	 	 	 	IF wdfreq[i] IN (&SubstanceTerms)  THEN 
SUBSTANCE_FOUND + 1; 
 	 	 	 	 	 	IF wdfreq[i] IN (&DescriptorTerms) THEN 
DESCRIPTOR_FOUND + 1; 
 
 	 	 	 	 	 	/*Regular Expression in SAS*/ 
 	 	 	 	 	 	*IF 
PRXMATCH("/&SubstanceTerms2/",wdfreq[i]) > 0 THEN SUBSTANCE_FOUND + 1; 
 	 	 	 	 	 	*IF 
PRXMATCH("/&DescriptorTerms2/",wdfreq[i]) > 0 THEN DESCRIPTOR_FOUND + 1; 
 	 	 	 	 	END; 
 	 	 	 	END; 
 
 	 	 	 	 
DRUGFOUND=0;DESCRIPTORS=0; 
IF SUBSTANCE_FOUND GE 1 THEN DRUGFOUND=1; /*found a drug/substance of interest*/ 
IF DESCRIPTOR_FOUND GE 1 THEN DESCRIPTORS=1; /*found a drug-related poisoning descriptor term*/ 
 
PROBABLE_DRM=0; 
IF DRUGFOUND = 1 AND DESCRIPTORS = 1 THEN CONFIRMED_DRM=1; 
 
SUSPECTED_DRM=0; 
IF DRUGFOUND = 1 AND DESCRIPTORS = 0 THEN PROBABLE_DRM=1; 
 
NOT_DRM=0; 
IF DRUGFOUND = 0 AND DESCRIPTORS = 1 THEN SUSPECTED_DRM=1; 
  
length ICD10_3 $3.; 
 
ICD10_3=COMPRESS(SUBSTR(ACME_UC,1,3)); acmeuc_drugpois=0; 
/*** all records in file are drug poisoning (overdose) deaths***/ if ("X40"<=ICD10_3<="X44" or "X60"<=ICD10_3<="X64" or ICD10_3="X85" or 
"Y10"<=ICD10_3<="Y14") THEN   
 acmeuc_drugpois=1;    	 	  	 	 	 
 
 EXCLUDE =0;  drugpois_related_=0; 
array mcod (*) acme_uc CAUSE_CATEGORY1-CAUSE_CATEGORY20; do i = 1 to dim(cod_codes); 
/*** all records in file are drug poisoning (overdose) related deaths***/ if ("X40"<=substr(mcod[i],1,3)<="X44" or "X60"<=substr(mcod[i],1,3)<="X64" or 
substr(mcod[i],1,3)="X85" or "Y10"<=substr(mcod[i],1,3)<="Y14") THEN   
 drugpois_related_=1;    	 	  	 	 	 
 
/*exclude other drugs/substances not of interest*/ 
IF (COMPRESS(SUBSTR(mcod[i],1,3)) IN 
("T36","T37","T38","T41","T44","T45","T46","T47","T49")) OR  
 	("T51" <= COMPRESS(SUBSTR(mcod[i],1,3)) <= "T65") THEN EXCLUDE =1; 
 	END; 
 
Interest=0; 
 	if EXCLUDE =0 and acmeuc_drugpois=1 then Interest=1; 
 
 
 	/*Frequency Analysis*/ 
 	 
PROC FREQ DATA=TEMP.FINALDRUGSCAN_COPY; 
TABLES PROBABLE_DRM SUSPECTED_DRM NOT_DRM acmeuc_drugpois drugpois_related_ / list; 
RUN; 
 
PROC FREQ DATA=TEMP.FINALDRUGSCAN_COPY; 
TABLES PROBABLE_DRM SUSPECTED_DRM NOT_DRM / list; 
WHERE drugpois_related_=1; 
RUN; 
 
PROC FREQ DATA=TEMP.FINALDRUGSCAN_COPY; 
TABLES PROBABLE_DRM SUSPECTED_DRM NOT_DRM / list; 
WHERE acmeuc_drugpois=1; 
RUN; 
 
PROC FREQ DATA=TEMP.FINALDRUGSCAN_COPY; 
TABLES PROBABLE_DRM SUSPECTED_DRM NOT_DRM acmeuc_drugpois/ list; 
WHERE Interest=1; 
RUN; 
 
 
PROC FREQ DATA=TEMP.FINALDRUGSCAN_COPY; 
TABLES PROBABLE_DRM*drugpois_related_ / agree; 
RUN; 
 
PROC FREQ DATA=TEMP.FINALDRUGSCAN_COPY; 
TABLES PROBABLE_DRM*acmeuc_drugpois / agree; 
RUN; 
 
PROC FREQ DATA=TEMP.FINALDRUGSCAN_COPY; 
TABLES PROBABLE_DRM*Interest / agree; 
RUN; 
 
PROC FREQ DATA=TEMP.FINALDRUGSCAN_COPY; 
TABLES PROBABLE_DRM*SUBSTANCE_FOUND / list; 
RUN; 
