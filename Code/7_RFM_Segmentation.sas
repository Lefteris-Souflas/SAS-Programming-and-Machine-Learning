/********************************************************************************
 * RFM Model Results Explanation
 *******************************************************************************/
/* Convert the CAS Table to SAS Data Set */
libname mycas cas;
data project.RFM_Results;   
   set mycas.SAS_JC_RFM_Results (keep = Customer_ID R F M _CLUSTER_ID_);  
run;
/* Find the 2 most important clusters created */
title 'Clusters Aggregated Results';
proc sql;
	SELECT _CLUSTER_ID_, COUNT(Customer_ID) as Population, 
		MEDIAN(R) as Average_Recency, MEDIAN(F) as Average_Frequency, 
		ROUND(AVG(M),0.01) as Average_Monetary
	FROM project.rfm_results
	GROUP BY _CLUSTER_ID_;
quit;
/* Find the customers that are clustered in the most important clusters */
proc sql noprint;
	CREATE TABLE project.cluster_1st_importance as (
	SELECT * FROM project.customers WHERE Customer_ID IN (
	SELECT Customer_ID
	FROM project.RFM_Results
	WHERE _CLUSTER_ID_ = 1));
	CREATE TABLE project.cluster_2nd_importance as (
	SELECT * FROM project.customers WHERE Customer_ID IN (
	SELECT Customer_ID
	FROM project.RFM_Results
	WHERE _CLUSTER_ID_ = 5));
quit;
/********************************************************************************
 * DEMOGRAPHIC CHARACTERISTICS
 *******************************************************************************/
/* Age */
proc sgplot data=Project.cluster_1st_importance;
   	vbar Age_Range;
   	xaxis display=(nolabel) values=('Very Young' 'Young' 'Middle Age' 'Mature' 'Old' 'Very Old');
	title "Distribution of Age in the 1st cluster";
run;
proc sgplot data=Project.cluster_2nd_importance;
   	vbar Age_Range;
   	xaxis display=(nolabel) values=('Very Young' 'Young' 'Middle Age' 'Mature' 'Old' 'Very Old');
	title "Distribution of Age in the 5th cluster";
run;
/* Gender */
proc gchart data=Project.cluster_1st_importance;
	donut Gender / clockwise discrete slice=outside value=outside percent=inside;
   	title "Distribution of Gender in the 1st cluster";
proc gchart data=Project.cluster_2nd_importance;
	donut Gender / clockwise discrete slice=outside value=outside percent=inside;
   	title "Distribution of Gender in the 5th cluster";
/* Residence */
proc sgplot data=Project.cluster_1st_importance;
   	vbar Region;
   	xaxis display=(nolabel);
	title "Distribution of Region of Residence in the 1st cluster";
run;
proc sgplot data=Project.cluster_2nd_importance;
   	vbar Region;
   	xaxis display=(nolabel);
	title "Distribution of Region of Residence in the 5th cluster";
run;
/********************************************************************************
 * BEHAVIOURAL CHARACTERISTICS
 *******************************************************************************/
proc sort data=project.rfm_results;
	by _CLUSTER_ID_;
run;
proc boxplot data=project.rfm_results(where=(_CLUSTER_ID_ in (1,5))); 
	plot R*_CLUSTER_ID_;
	title 'Box Plot for Recency Value';
run;
proc boxplot data=project.rfm_results(where=(_CLUSTER_ID_ in (1,5))); 
	plot F*_CLUSTER_ID_;
	title 'Box Plot for Frequency Value';
run;
proc boxplot data=project.rfm_results(where=(_CLUSTER_ID_ in (1,5))); 
	plot M*_CLUSTER_ID_;
	title 'Box Plot for Monetary Value';
run;