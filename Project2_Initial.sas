/*
https://www.sas.com/content/dam/SAS/en_us/doc/event/analytics-experience-2016/fitting-evaluating-logistic-regression-models-magnify-analyticsolutions.pdf
*/

data bank;
infile '/home/u36612003/bank-additional-full.csv' dlm=';' firstobs=2;
input age job  $ marital $ education $ default $ housing $ loan $ concact $ month $ day_of_week $ duration campaign pdays previous poutcome campaign emp_var_rate cons_conf_idx euribor3m nr_employed y $;
run;

/* Tes/*
https://www.sas.com/content/dam/SAS/en_us/doc/event/analytics-experience-2016/fitting-evaluating-logistic-regression-models-magnify-analyticsolutions.pdf
*/

data bank;
infile '/home/u36612003/bank-additional-full.csv' dlm=';' firstobs=2;
input age job  $ marital $ education $ default $ housing $ loan $ concact $ month $ day_of_week $ duration campaign pdays previous poutcome emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
run;

/* Test train split */

proc surveyselect data=bank rate=.3 outall out=bankSplit;
   run;

DATA test;
   SET bankSplit;
   IF Selected = 1 ;
RUN;

DATA train;
   SET bankSplit;
   IF Selected = 0 ;
RUN;


proc print data = test(obs=10); 
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

Including most variables
AUC = 0.7590
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y;
MODEL y = age job marital education housing loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed  / LACKFIT CTABLE;
score data=test out=mypreds;
TITLE 'Bank Data Analysis';
RUN;

proc print data=mypreds(obs=10);
run;

/*
https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2019/3337-2019.pdf
*/

/*
reduce model to include only the stuf with low p value
take out : age marital education euribor3m

AUC = 0.7586
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y;
MODEL y = job housing loan previous emp_var_rate cons_price_idx cons_conf_idx nr_employed  / LACKFIT CTABLE;
score data=test out=mypreds;
TITLE 'Bank Data Analysis';
RUN;


/*

remove housing
AUC = 0.7585
*/


PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y;
MODEL y = job loan previous emp_var_rate cons_price_idx cons_conf_idx nr_employed  / LACKFIT CTABLE;
score data=test out=mypreds;
TITLE 'Bank Data Analysis';
RUN;


/* 

remove loan
AUC = 0.7582
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y;
MODEL y = job previous emp_var_rate cons_price_idx cons_conf_idx nr_employed  / LACKFIT CTABLE;
score data=test out=mypreds;
TITLE 'Bank Data Analysis';
RUN;




