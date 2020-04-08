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
run;



proc print data = test(obs=100); 
run;

proc print data = train(obs=10); 
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
AUC train = 0.7889
AUC test = 0.7729
AIC = 7130.626
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education housing contact loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*

try removing education since the p values are so high
AUC Train = 0.7880
AUC Test = 0.7763
AIC = 7127.283
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital housing contact loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*

try removing marital since the p values are so high
AUC Train = 0.7875
AUC Test = 0.7762
AIC = 7124.386
*/


PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job housing contact loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*

try removing housing since the p values are so high
AUC Train = 0.7875
AUC Test = 0.7762
AIC = 7122.442
*/


PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job contact loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*

try removing loan since the p values are so high
AUC Train = 0.7874
AUC Test = 0.7765
AIC = 7119.788
*/


PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job contact previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;



/*

try removing previous since the p values are so high
AUC Train = 0.7823
AUC Test = 0.7762
AIC = 7118.195
*/


PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job contact emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;



/*
try removing education, and keep ; Blue_Collar, Entrepre, Retired, Services, Student   just since the p values are so high
AUC Train = 0.7872
AUC Test = 0.7767
AIC = 7118.195
*/


PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job education default housing loan contact month day_of_week y NoPriorContact poutcome Blue_Collar Entrepre Retired Services Student;
MODEL y(event='yes') = age contact emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome Blue_Collar Entrepre Retired Services Student / LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;









/*
**************************************** RESTART *******************************
Try based on a model chosen from looking at the EDA
AUC Train = 0.7894
AUC Test = 0.7775
AIC = 7099.226
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome;
MODEL y(event='yes') = pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Blue_Collar Retired Student MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
Remove previous because of low p value

AUC Train = 0.7894
AUC Test = 0.7775
AIC = 7097.226
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Blue_Collar Retired Student MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
Use MaritalSingle only since unknown was low p value

AUC Train = 0.7894
AUC Test = 0.7780
AIC = 7095.400
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Blue_Collar Retired Student MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
remove blue collar since low p value

AUC Train = 0.7895
AUC Test = 0.7785
AIC = 7093.580
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Retired Student MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
remove education illiterate since low p value

AUC Train = 0.7895
AUC Test = 0.7811
AIC = 7092.184
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan month day_of_week y Blue_Collar Retired Student  NoPriorContact MaritalUnknown MaritalSingle EducationIlliterate EducationUniversity EducationUnknown DefaultNo contact poutcome;
MODEL y(event='yes') = pdays emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed Retired Student MaritalSingle EducationUniversity EducationUnknown DefaultNo contact poutcome/ LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;


/*
Helpful : https://www.youtube.com/watch?v=qHoK783Gtzo
build sas models using forward selection
Train AUC = 0.7873
Test AUC = 0.7762
AIC = 7477.885
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education housing contact loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome  / selection=forward LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;

/*
backward
Train AUC = 0.7877
Test AUC = 0.7759
AIC = 7130.626
*/
PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education housing contact loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome  / selection=backward LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;



/*
stepwise
Train AUC = 0.7877
Test AUC = 0.7759
AIC = 17190.727
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan contact month day_of_week y NoPriorContact poutcome;
MODEL y(event='yes') = age job marital education housing contact loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed poutcome  / selection=stepwise LACKFIT details CTABLE outroc=trainroc;
score data=test out=testpred outroc=testroc;
roc; roccontrast;
TITLE 'Bank Data Analysis';
RUN;




