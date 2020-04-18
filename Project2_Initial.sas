/*
https://www.sas.com/content/dam/SAS/en_us/doc/event/analytics-experience-2016/fitting-evaluating-logistic-regression-models-magnify-analyticsolutions.pdf

useful for understanding how to use ROC curves for train vs test(validation)
https://support.sas.com/kb/39/724.html
https://support.sas.com/kb/52/973.html
*/

data train5050;
infile '/home/u36612003/bank_train_50_50NoQuotes.csv' dlm=',' firstobs=2;
input rownum age job  $ marital $ education $ default $ housing $ loan $ contact $ month $ day_of_week $ duration campaign pdays previous poutcome $ emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
run;

data test9010;
infile '/home/u36612003/bank_test_90_10NoQuotes.csv' dlm=',' firstobs=2;
input rownum age job  $ marital $ education $ default $ housing $ loan $ contact $ month $ day_of_week $ duration campaign pdays previous poutcome $ emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
run;

data test5050;
infile '/home/u36612003/bank_test_50_50NoQuotes.csv' dlm=',' firstobs=2;
input rownum age job  $ marital $ education $ default $ housing $ loan $ contact $ month $ day_of_week $ duration campaign pdays previous poutcome $ emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
run;

data train9010Orig;
infile '/home/u36612003/bank_train_90_10NoQuotes.csv' dlm=',' firstobs=2;
input rownum age job  $ marital $ education $ default $ housing $ loan $ contact $ month $ day_of_week $ duration campaign pdays previous poutcome $ emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
run;

proc surveyselect data=train5050 rate=.75 out=train5050SmallOrig;



proc contents data=train5050;
run;

/* Test train split */


/* 
feature engineering - separate field for if the pdays = 999
This feature indicates that the applicant has not previously been contanted

*/

data train;
 set train5050;
 if pdays = 999 then NoPriorContact = 'yes';
 else NoPriorContact = 'no';
 if job = 'blue-col' then  Blue_Collar = 'yes';
 else Blue_Collar = 'no';
 if job = 'retired ' then  Retired = 'yes';
 else Retired = 'no';
 if job = 'student ' then  Student = 'yes';
 else Student = 'no';
 if job = 'services' then  Services = 'yes';
 else Services = 'no';
 if job = 'entrepre' then Entrepre = 'yes';
 else Entrepre = 'no';
 if job = 'housemai' then HouseMaid = 'yes';
 else HouseMaid = 'no';
 if marital = 'unknown ' then MaritalUnknown = 'yes';
 else MaritalUnknown = 'no';
 if marital = 'single ' then MaritalSingle = 'yes';
 else MaritalSingle = 'no';
 if education = 'illitera' then EducationIlliterate = 'yes';
 else EducationIlliterate = 'no';
 if education = 'universi' then EducationUniversity = 'yes';
 else EducationUniversity = 'no';
 if education = 'unknown' then EducationUnknown = 'yes';
 else EducationUnknown = 'no';
 if default = 'no' then DefaultNo  = 'yes';
 else DefaultNo = 'no';
 if poutcome = 'success' then poutcomeSuccess = 'yes';
 else poutcomeSuccess = 'no';
 if day_of_week = 'mon' then Monday = 'yes';
 else Monday = 'no';
 if day_of_week = 'thu' then Thursday = 'yes';
 else Thursday = 'no';
 if month in ('dec', 'mar', 'oct','sep') then HighMonth = 'yes';
 else HighMonth = 'no';
 if y = 'yes' then yNum = 1;
 else yNum = -1;
run;

data test9010FS;
 set test9010;
 if pdays = 999 then NoPriorContact = 'yes';
 else NoPriorContact = 'no';
 if job = 'blue-col' then  Blue_Collar = 'yes';
 else Blue_Collar = 'no';
 if job = 'retired ' then  Retired = 'yes';
 else Retired = 'no';
 if job = 'student ' then  Student = 'yes';
 else Student = 'no';
 if job = 'services' then  Services = 'yes';
 else Services = 'no';
 if job = 'entrepre' then Entrepre = 'yes';
 else Entrepre = 'no';
 if job = 'housemai' then HouseMaid = 'yes';
 else HouseMaid = 'no';
 if marital = 'unknown ' then MaritalUnknown = 'yes';
 else MaritalUnknown = 'no';
 if marital = 'single ' then MaritalSingle = 'yes';
 else MaritalSingle = 'no';
 if education = 'illitera' then EducationIlliterate = 'yes';
 else EducationIlliterate = 'no';
 if education = 'universi' then EducationUniversity = 'yes';
 else EducationUniversity = 'no';
 if education = 'unknown' then EducationUnknown = 'yes';
 else EducationUnknown = 'no';
 if default = 'no' then DefaultNo  = 'yes';
 else DefaultNo = 'no';
 if poutcome = 'success' then poutcomeSuccess = 'yes';
 else poutcomeSuccess = 'no';
 if day_of_week = 'mon' then Monday = 'yes';
 else Monday = 'no';
 if day_of_week = 'thu' then Thursday = 'yes';
 else Thursday = 'no';
 if month in ('dec', 'mar', 'oct','sep') then HighMonth = 'yes';
 else HighMonth = 'no';
run;


data test;
 set test9010;
 if pdays = 999 then NoPriorContact = 'yes';
 else NoPriorContact = 'no';
 if job = 'blue-col' then  Blue_Collar = 'yes';
 else Blue_Collar = 'no';
 if job = 'retired ' then  Retired = 'yes';
 else Retired = 'no';
 if job = 'student ' then  Student = 'yes';
 else Student = 'no';
 if job = 'services' then  Services = 'yes';
 else Services = 'no';
 if job = 'entrepre' then Entrepre = 'yes';
 else Entrepre = 'no';
 if job = 'housemai' then HouseMaid = 'yes';
 else HouseMaid = 'no';
 if marital = 'unknown ' then MaritalUnknown = 'yes';
 else MaritalUnknown = 'no';
 if marital = 'single ' then MaritalSingle = 'yes';
 else MaritalSingle = 'no';
 if education = 'illitera' then EducationIlliterate = 'yes';
 else EducationIlliterate = 'no';
 if education = 'universi' then EducationUniversity = 'yes';
 else EducationUniversity = 'no';
 if education = 'unknown' then EducationUnknown = 'yes';
 else EducationUnknown = 'no';
 if default = 'no' then DefaultNo  = 'yes';
 else DefaultNo = 'no';
 if poutcome = 'success' then poutcomeSuccess = 'yes';
 else poutcomeSuccess = 'no';
 if day_of_week = 'mon' then Monday = 'yes';
 else Monday = 'no';
 if day_of_week = 'thu' then Thursday = 'yes';
 else Thursday = 'no';
 if month in ('dec', 'mar', 'oct','sep') then HighMonth = 'yes';
 else HighMonth = 'no';
run;

data train9010;
 set train9010Orig;
 if pdays = 999 then NoPriorContact = 'yes';
 else NoPriorContact = 'no';
 if job = 'blue-col' then  Blue_Collar = 'yes';
 else Blue_Collar = 'no';
 if job = 'retired ' then  Retired = 'yes';
 else Retired = 'no';
 if job = 'student ' then  Student = 'yes';
 else Student = 'no';
 if job = 'services' then  Services = 'yes';
 else Services = 'no';
 if job = 'entrepre' then Entrepre = 'yes';
 else Entrepre = 'no';
 if job = 'housemai' then HouseMaid = 'yes';
 else HouseMaid = 'no';
 if marital = 'unknown ' then MaritalUnknown = 'yes';
 else MaritalUnknown = 'no';
 if marital = 'single ' then MaritalSingle = 'yes';
 else MaritalSingle = 'no';
 if education = 'illitera' then EducationIlliterate = 'yes';
 else EducationIlliterate = 'no';
 if education = 'universi' then EducationUniversity = 'yes';
 else EducationUniversity = 'no';
 if education = 'unknown' then EducationUnknown = 'yes';
 else EducationUnknown = 'no';
 if default = 'no' then DefaultNo  = 'yes';
 else DefaultNo = 'no';
 if poutcome = 'success' then poutcomeSuccess = 'yes';
 else poutcomeSuccess = 'no';
 if day_of_week = 'mon' then Monday = 'yes';
 else Monday = 'no';
 if day_of_week = 'thu' then Thursday = 'yes';
 else Thursday = 'no';
 if month in ('dec', 'mar', 'oct','sep') then HighMonth = 'yes';
 else HighMonth = 'no';
run;


data train5050Small;
 set train5050SmallOrig;
 if pdays = 999 then NoPriorContact = 'yes';
 else NoPriorContact = 'no';
 if job = 'blue-col' then  Blue_Collar = 'yes';
 else Blue_Collar = 'no';
 if job = 'retired ' then  Retired = 'yes';
 else Retired = 'no';
 if job = 'student ' then  Student = 'yes';
 else Student = 'no';
 if job = 'services' then  Services = 'yes';
 else Services = 'no';
 if job = 'entrepre' then Entrepre = 'yes';
 else Entrepre = 'no';
 if job = 'housemai' then HouseMaid = 'yes';
 else HouseMaid = 'no';
 if marital = 'unknown ' then MaritalUnknown = 'yes';
 else MaritalUnknown = 'no';
 if marital = 'single ' then MaritalSingle = 'yes';
 else MaritalSingle = 'no';
 if education = 'illitera' then EducationIlliterate = 'yes';
 else EducationIlliterate = 'no';
 if education = 'universi' then EducationUniversity = 'yes';
 else EducationUniversity = 'no';
 if education = 'unknown' then EducationUnknown = 'yes';
 else EducationUnknown = 'no';
 if default = 'no' then DefaultNo  = 'yes';
 else DefaultNo = 'no';
 if poutcome = 'success' then poutcomeSuccess = 'yes';
 else poutcomeSuccess = 'no';
 if day_of_week = 'mon' then Monday = 'yes';
 else Monday = 'no';
 if day_of_week = 'thu' then Thursday = 'yes';
 else Thursday = 'no';
 if month in ('dec', 'mar', 'oct','sep') then HighMonth = 'yes';
 else HighMonth = 'no';
run;



proc print data = test(obs=100); 
run;

proc print data = train(obs=10); 
run;

proc print data = train9010(obs=10); 
run;


/*
Add variable for no previous contact (pdays = 999)
*/


/* do logistic regression with SAS */


/*
proc glmselect data=train plots=all;
   class job marital education default housing loan concact month day_of_week y;
   model y = age job marital education default housing loan concact month day_of_week duration campaign pdays previous poutcome campaign emp_var_rate cons_conf_idx euribor3m nr_employed  / selection=FORWARD(select=CV CHOOSE=CV) stats=all;
   output out = results p = Predict;
run;
*/

/*

Including all variables except duration
Not including duration because it is not available in advance
AUC train = 0.8026
AUC test = 0.7836
AIC = 6951.001
*/



PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education default housing contact month day_of_week campaign pdays loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
remove housing
AUC train = 0.8024
AUC test = 0.7837
AIC = 6950.797
*/



PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education contact month day_of_week campaign pdays loan previous emp_var_rate cons_price_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
remove loan
AUC train = 0.8024
AUC test = 0.7839
AIC = 6947.569
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education contact month day_of_week campaign pdays previous emp_var_rate cons_price_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
remove previous
AUC train = 0.8024
AUC test = 0.7839
AIC = 6945.648
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education contact month day_of_week campaign pdays emp_var_rate cons_price_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
remove nr_employed
AUC train = 0.8023
AUC test = 0.7839
AIC = 6943.774
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education contact month day_of_week campaign pdays emp_var_rate cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
remove marital
AUC train = 0.8022
AUC test = 0.7842
AIC = 6939.320
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job education contact month day_of_week campaign pdays emp_var_rate cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
remove pdays
AUC train = 0.8021
AUC test =0.7836
AIC = 
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job education contact month day_of_week campaign emp_var_rate cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
remove education (entirely)
this increase AUC test
AUC train = 0.8013
AUC test =0.7871
AIC = 6934.008
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job contact month day_of_week campaign emp_var_rate cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
replace day_of_week with Monday, Thursday
this increase AUC test
AUC train = 0.8011
AUC test =0.7868
AIC = 6934.008
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome Monday Thursday;
MODEL y(event='yes') = age job contact month Monday Thursday campaign emp_var_rate cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
remove Thursday
this increase AUC test
AUC train = 0.8012
AUC test = 0.7868
AIC = 6929.801
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome Monday Thursday;
MODEL y(event='yes') = age job contact month Monday campaign emp_var_rate cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
remove job and add retired, enterpeneur, housemai
this increase AUC test
AUC train = 0.8012
AUC test = 0.7865
AIC = 6929.801
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome Monday Thursday Retired Entrepre HouseMaid ;
MODEL y(event='yes') = age Retired Entrepre HouseMaid contact month Monday campaign emp_var_rate cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*

Check VIF for this model
emp_var_rate VIF = 27
euribor3m VIF = 19.2
*/

PROC REG DATA=train;
MODEL yNum = age campaign emp_var_rate cons_price_idx euribor3m / VIF; 
run;


/*
remove emp_var_rate
this increase AUC test
AUC train = 0.7987
AUC test = 0.7830
AIC = 6995.817
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome Monday Thursday Retired Entrepre HouseMaid ;
MODEL y(event='yes') = age Retired Entrepre HouseMaid contact month Monday campaign cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
Check VIF again without emp_var_rate
all of the VIF's are < 1.5
*/
PROC REG DATA=train;
MODEL yNum = age campaign cons_price_idx euribor3m / VIF; 
run;



/****
*********
Same model but using 9010 for training
*/


PROC LOGISTIC DATA = train9010 DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome Monday Thursday Retired Entrepre HouseMaid ;
MODEL y(event='yes') = age Retired Entrepre HouseMaid contact month Monday campaign cons_price_idx euribor3m poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;





/*
**************************************** RESTART *******************************
Try based on a model chosen from looking at the EDA
AUC Train = 0.7952
AUC Test = 0.7795
AIC = 7099.226
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Blue_Collar Retired Student MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
Remove previous
AUC Train = 0.7952
AUC Test = 0.7795
AIC = 7024.740
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Blue_Collar Retired Student MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
Remove marital unknown
AUC Train = 0.7952
AUC Test = 0.7798
AIC = 7022.865
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Blue_Collar Retired Student MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
Remove EducationIlliterate
AUC Train = 0.7952
AUC Test = 0.7821
AIC = 7022.865
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Blue_Collar Retired Student MaritalSingle EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
Remove Blue_Colloar
AUC Train = 0.7948
AUC Test = 0.7828
AIC = 7022.865
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Retired Student MaritalSingle EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
Remove euribor3m
AUC Train = 0.7949
AUC Test = 0.7828
AIC = 7019.337
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx nr_employed Retired Student MaritalSingle EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
Remove poutcome
AUC Train = 0.7918
AUC Test = 0.7817
AIC = 7065.142
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx nr_employed Retired Student MaritalSingle EducationUniversity EducationUnknown DefaultNo contact HighMonth/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
Remove Student
AUC Train = 0.7914
AUC Test = 0.7814
AIC = 7065.296
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx nr_employed Retired MaritalSingle EducationUniversity EducationUnknown DefaultNo contact HighMonth/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
Check VIF again - emp_var_rate has VIF of 23
*/
PROC REG DATA=train;
MODEL yNum = pdays emp_var_rate cons_price_idx cons_conf_idx nr_employed / VIF; 
run;


/*
Remove emp_var_rate
AUC Train = 0.7873
AUC Test = 0.7781
AIC = 7145.799
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
format Retired Student MaritalSingle EducationIlliterate EducationIlliterate EducationUniversity EducationUnknown EducationUnknown DefaultNo HighMonth;
class job marital education default housing loan month day_of_week y Blue_Collar Retired(ref='yes')  Student(ref='yes')  NoPriorContact MaritalUnknown MaritalSingle(ref='yes') EducationIlliterate(ref='yes') EducationUniversity(ref='yes') EducationUnknown(ref='yes') DefaultNo(ref='yes') contact poutcome HighMonth(ref='yes');
MODEL y(event='yes') = pdays cons_price_idx cons_conf_idx nr_employed Retired MaritalSingle EducationUniversity EducationUnknown DefaultNo contact HighMonth/ aggregate LACKFIT details CTABLE outroc=trainroc;
effectplot;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
Check VIF without emp_var_rate
*/
PROC REG DATA=train;
MODEL yNum = pdays cons_price_idx cons_conf_idx nr_employed / VIF; 
run;

/*
Check the plots of residuals
*/

ods graphics on;
PROC LOGISTIC DATA = train DESCENDING plots=ALL;
format Retired Student MaritalSingle EducationIlliterate EducationIlliterate EducationUniversity EducationUnknown EducationUnknown DefaultNo HighMonth;
class job marital education default housing loan month day_of_week y Blue_Collar Retired(ref='yes')  Student(ref='yes')  NoPriorContact MaritalUnknown MaritalSingle(ref='yes') EducationIlliterate(ref='yes') EducationUniversity(ref='yes') EducationUnknown(ref='yes') DefaultNo(ref='yes') contact poutcome HighMonth(ref='yes');
MODEL y(event='yes') = pdays cons_price_idx cons_conf_idx nr_employed Retired MaritalSingle EducationUniversity EducationUnknown DefaultNo contact HighMonth/  IPLOTS INFLUENCE outroc=trainroc;
RUN;

/*
Adding this to check outliers in particular. This is super slow
*/
ods graphics on;
PROC LOGISTIC DATA = train DESCENDING plots=ALL;
format Retired Student MaritalSingle EducationIlliterate EducationIlliterate EducationUniversity EducationUnknown EducationUnknown DefaultNo HighMonth;
class job marital education default housing loan month day_of_week y Blue_Collar Retired(ref='yes')  Student(ref='yes')  NoPriorContact MaritalUnknown MaritalSingle(ref='yes') EducationIlliterate(ref='yes') EducationUniversity(ref='yes') EducationUnknown(ref='yes') DefaultNo(ref='yes') contact poutcome HighMonth(ref='yes');
MODEL y(event='yes') = pdays cons_price_idx cons_conf_idx nr_employed Retired MaritalSingle EducationUniversity EducationUnknown DefaultNo contact HighMonth/ INFLUENCE IPLOTS outroc=trainroc;
effectplot;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;



PROC LOGISTIC DATA = train DESCENDING plots=ALL;
format Retired Student MaritalSingle EducationIlliterate EducationIlliterate EducationUniversity EducationUnknown EducationUnknown DefaultNo HighMonth;
class job marital education default housing loan month day_of_week y Blue_Collar Retired(ref='yes')  Student(ref='yes')  NoPriorContact MaritalUnknown MaritalSingle(ref='yes') EducationIlliterate(ref='yes') EducationUniversity(ref='yes') EducationUnknown(ref='yes') DefaultNo(ref='yes') contact poutcome HighMonth(ref='yes');
MODEL y(event='yes') = age education / INFLUENCE IPLOTS outroc=trainroc;
TITLE 'Bank Data Analysis';
RUN;

/*
using a small dataset to see if we get the influence diagrams
*/

proc print data=train5050Small;

PROC LOGISTIC DATA = train5050Small DESCENDING plots=ALL;
format Retired Student MaritalSingle EducationIlliterate EducationUniversity EducationUnknown EducationUnknown DefaultNo HighMonth;
class job marital education default housing loan month day_of_week y Blue_Collar Retired(ref='yes')  Student(ref='yes')  NoPriorContact MaritalUnknown MaritalSingle(ref='yes') EducationIlliterate(ref='yes') EducationUniversity(ref='yes') EducationUnknown(ref='yes') DefaultNo(ref='yes') contact poutcome HighMonth(ref='yes');
MODEL y(event='yes') = pdays cons_price_idx cons_conf_idx nr_employed Retired MaritalSingle EducationUniversity EducationUnknown DefaultNo contact HighMonth / INFLUENCE IPLOTS outroc=trainroc;
TITLE 'Bank Data Analysis';
RUN;

/*
item 2961 is has high leverage... Why?
*/



/*
add partial option
*/

PROC LOGISTIC DATA = train5050Small DESCENDING  plots=ALL;
format Retired Student MaritalSingle EducationIlliterate EducationUniversity EducationUnknown EducationUnknown DefaultNo HighMonth;
class job marital education default housing loan month day_of_week y Blue_Collar Retired(ref='yes')  Student(ref='yes')  NoPriorContact MaritalUnknown MaritalSingle(ref='yes') EducationIlliterate(ref='yes') EducationUniversity(ref='yes') EducationUnknown(ref='yes') DefaultNo(ref='yes') contact poutcome HighMonth(ref='yes');
MODEL y(event='yes') = age education / partial outroc=trainroc;
TITLE 'Bank Data Analysis';
RUN;


/*****
redo the previous but using 9010 training set
*/

PROC LOGISTIC DATA = train9010 DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome HighMonth;
MODEL y(event='yes') = pdays cons_price_idx cons_conf_idx nr_employed Retired MaritalSingle EducationUniversity EducationUnknown DefaultNo contact HighMonth/ LACKFIT CTABLE clodds=both outroc=trainroc;
score data=test out=testpred outroc=testroc;
output out=pred p=phat lower=lcl upper=ucl 
	predprob=(individual crossvalidate);
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;








/*
***************************************************
USE FEATURE SELECTION
*****************************************
*/

/*
Helpful : https://www.youtube.com/watch?v=qHoK783Gtzo
build sas models using forward selection
Train AUC = 0.7995
Test AUC = 0.7884
AIC = 7477.885
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education default housing contact month day_of_week campaign pdays loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / selection=forward LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
backward
Train AUC = 0.7955
Test AUC = 0.7883
AIC = 6951.001
*/
PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education default housing contact month day_of_week campaign pdays loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / selection=backward LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;



/*
stepwise
Train AUC = 0.7955
Test AUC = 0.7883
AIC = 7477.885
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education default housing contact month day_of_week campaign pdays loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / selection=stepwise LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
**********************************************************************
Redo test with 90/10 training data
*/

/*
Helpful : https://www.youtube.com/watch?v=qHoK783Gtzo
build sas models using forward selection
Train AUC = 0.7954
Test AUC = 0.7902
AIC = 17157.381
*/

PROC LOGISTIC DATA = train9010 DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education default housing contact month day_of_week campaign pdays loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / selection=forward LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
backward
Train AUC = 0.7956
Test AUC = 0.7903
AIC = 15921.901
*/
PROC LOGISTIC DATA = train9010 DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education default housing contact month day_of_week campaign pdays loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / selection=backward LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;



/*
stepwise
Train AUC = 0.7956
Test AUC = 0.7903
AIC = 17157.381
*/

PROC LOGISTIC DATA = train9010 DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education default housing contact month day_of_week campaign pdays loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / selection=stepwise LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

