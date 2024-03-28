/********************************************************************************
 * Market Basket Analysis in the whole dataset
 *******************************************************************************/
/* Market Basket based only on sales and not on  returns transactions */
/* Identify associations of product categories */
proc sql noprint;
	create table project.market_basket as (
	select invoice_id, 'Product Type'n as Product_Category 
	from project.basket a, project.products b
	where a.product_id = b.product_id and 
		invoice_id in (select invoice_id from project.sales));
quit;
/* Load market_basket dataset to CAS */
cas casauto;
caslib;
libname mycas cas;
data mycas.market_basket;            
   set project.market_basket;
run;
/* Market Basket Analysis Procedure */
ods noproctitle;
proc mbanalysis data=mycas.MARKET_BASKET items=4 
		conf=0.05 pctsupport=0.05 lift=1;
	target Product_Category;
	customer Invoice_ID;
	output outrule=mycas.MBA_RESULTS;
run;
/* Convert the CAS Table to SAS Data Set */
data project.MBA_Results;   
	set mycas.MBA_RESULTS;
run;
/* Print top 10 product category associations */
proc sort data=project.MBA_Results;
	by descending Lift; 
run;
proc print data=project.MBA_Results(obs=10) noobs;
	var Rule Lift;
	title "Top 10 Product Categories Associations";
	format Lift 4.2;
run;
/********************************************************************************
 * Market Basket Analysis in the two most important clusters
 *******************************************************************************/
proc sql noprint;
	create table project.market_basket_cluster_1 as
	select invoice_id, 'Product Type'n as Product_Category 
	from project.basket a, project.products b
	where a.product_id = b.product_id and 
		invoice_id in (select invoice_id from project.sales c where 
		customer_id in (select customer_id from project.cluster_1st_importance));
	create table project.market_basket_cluster_2 as
	select invoice_id, 'Product Type'n as Product_Category 
	from project.basket a, project.products b
	where a.product_id = b.product_id and 
		invoice_id in (select invoice_id from project.sales c where 
		customer_id in (select customer_id from project.cluster_2nd_importance));
quit;
data mycas.market_basket_cluster_1;            
   set project.market_basket_cluster_1;
run;
data mycas.market_basket_cluster_2;            
   set project.market_basket_cluster_2;
run;
/* Market Basket Analysis Procedure */
ods noproctitle;
proc mbanalysis data=mycas.market_basket_cluster_1 items=4 
		conf=0.05 pctsupport=0.05 lift=1;
	target Product_Category;
	customer Invoice_ID;
	output outrule=mycas.MBA_RESULTS_CLUSTER_1;
run;
ods noproctitle;
proc mbanalysis data=mycas.market_basket_cluster_2 items=4 
		conf=0.05 pctsupport=0.05 lift=1;
	target Product_Category;
	customer Invoice_ID;
	output outrule=mycas.MBA_RESULTS_CLUSTER_2;
run;
/* Convert the CAS Table to SAS Data Set */
data project.MBA_Results_cluster_1;   
	set mycas.MBA_RESULTS_CLUSTER_1;
run;
data project.MBA_Results_cluster_2;   
	set mycas.MBA_RESULTS_CLUSTER_2;
run;
/* Print top 10 product category associations for the 1st cluster */
proc sort data=project.MBA_Results_cluster_1;
	by descending Lift; 
run;
proc print data=project.MBA_Results_cluster_1(obs=10) noobs;
	var Rule Lift;
	title "Top 10 Product Categories Associations in the 1st Cluster";
	format Lift 4.2;
run;
/* Print top 10 product category associations for the 2nd cluster */
proc sort data=project.MBA_Results_cluster_2;
	by descending Lift; 
run;
proc print data=project.MBA_Results_cluster_2(obs=10) noobs;
	var Rule Lift;
	title "Top 10 Product Categories Associations in the 2nd Cluster";
	format Lift 4.2;
run;