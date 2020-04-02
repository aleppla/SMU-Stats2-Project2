/*
https://www.sas.com/content/dam/SAS/en_us/doc/event/analytics-experience-2016/fitting-evaluating-logistic-regression-models-magnify-analyticsolutions.pdf
*/

data bank;
infile '/home/u36612003/bank-additional-full-NoQuotes.csv' dlm=';' firstobs=2;
input age job  $ marital $ education $ default $ housing $ loan $ concact $ month $ day_of_week $ duration campaign pdays previous poutcome emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
run;

proc contents data=bank;
run;

/* Test train split */


/* 
feature engineering - separate field for if the pdays = 999
This feature indicates that the applicant has not previously been contanted

 if findw(job,'blue-collar') then  Blue_Collar = 'Yes';
 else Blue_Collar = 'No';

*/

data bank2;
 set bank;
 if pdays = 999 then NoPriorContact = 'Yes';
 else NoPriorContact = 'No';
 if job = 'blue-col' then  Blue_Collar = 'Yes';
 else Blue_Collar = 'No';
 if job = 'retired ' then  Retired = 'Yes';
 else Retired = 'No';
 if job = 'student ' then  Student = 'Yes';
 else Student = 'No';
run;

proc surveyselect data=bank2 rate=.3 outall out=bankSplit;
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
AUC = 0.7658
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y NoPriorContact;
MODEL y = age job marital education housing loan previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed NoPriorContact / LACKFIT CTABLE;
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

AUC = 0.7639
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y NoPriorContact;
MODEL y = job housing loan previous emp_var_rate cons_price_idx cons_conf_idx nr_employed NoPriorContact  / LACKFIT CTABLE;
score data=test out=mypreds;
TITLE 'Bank Data Analysis';
RUN;


/*

remove housing
AUC = 0.7636
*/


PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y NoPriorContact;
MODEL y = job loan previous emp_var_rate cons_price_idx cons_conf_idx nr_employed NoPriorContact  / LACKFIT CTABLE;
score data=test out=mypreds;
TITLE 'Bank Data Analysis';
RUN;


/* 

remove loan
AUC = 0.7630
*/

PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y NoPriorContact;
MODEL y = job previous emp_var_rate cons_price_idx cons_conf_idx nr_employed NoPriorContact  / LACKFIT CTABLE;
score data=test out=mypreds;
TITLE 'Bank Data Analysis';
RUN;

/*
only use blue color, retired and student
AUC = 0.7621
*/


PROC LOGISTIC DATA = train DESCENDING plots=ALL;
class job marital education default housing loan concact month day_of_week y NoPriorContact Blue_Collar Student Retired;
MODEL y = previous emp_var_rate cons_price_idx cons_conf_idx nr_employed NoPriorContact  Blue_Collar Student Retired / LACKFIT CTABLE;
score data=test out=mypreds;
TITLE 'Bank Data Analysis';
RUN;