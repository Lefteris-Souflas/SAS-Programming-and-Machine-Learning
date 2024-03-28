/********************************************************************************
 * PERCENTAGE OF PRODUCTS PER PROMOTION EXISTENCE OR NOT
 *******************************************************************************/
/* Create a format */
proc format;
   value PromotionFormatFlag
   0 = 'No Promotion'
   0.1 = 'Promotion'
   0.2 = 'Promotion'
   0.3 = 'Promotion';
run;
/* Merge the relevant datasets */
proc sort data=project.promotions out=promotions_sorted;
	by promotion_id;
run;
proc sort data=project.basket out=basket_sorted;
	by promotion_id;
run;
data basket_promotions;
	merge promotions_sorted (in=a) basket_sorted (in=b);
	by promotion_id;
	if a and b;
run;
/* Frequency table with percentage of products by promotion */
proc freq data=basket_promotions noprint;
  tables Promotion / nocum out=Promotion_Freq;
  format Promotion PromotionFormatFlag.;
run;
/* Pie plot */
proc gchart data=Promotion_Freq;
	pie3d Promotion / sumvar=count clockwise discrete slice=outside value=outside percent=inside angle=23;
	format Promotion PromotionFormatFlag.;
	format count comma7.;
	pattern1 color=aquamarine;
	pattern2 color=lightgoldenrodyellow;
	pattern3 color=orange;
	pattern4 color=skyblue;  
	title "Percentage of Products Sold with/without Promotion";
/********************************************************************************
 * PERCENTAGE OF PRODUCTS PER PROMOTION TYPE
 *******************************************************************************/
/* Create a format */
proc format;
   value PromotionFormat
   0 = 'No Promotion'
   0.1 = 'Promotion 10%'
   0.2 = 'Promotion 20%'
   0.3 = 'Promotion 30%';
run;
/* Frequency table with percentage of products by promotion */
proc freq data=basket_promotions noprint;
  tables Promotion / nocum out=Promotion_Freq;
  format Promotion PromotionFormat.;
run;
/* Create pie plot */
proc gchart data=Promotion_Freq;
	pie3d Promotion / sumvar=count clockwise discrete slice=outside value=outside percent=inside angle=23 invisible=0 ;
	format Promotion PromotionFormat.;
	format count comma7.;
	pattern1 color=aquamarine;
	pattern2 color=lightgoldenrodyellow;
	pattern3 color=orange;
	pattern4 color=skyblue;    
   	title "Percentage of Products Sold on Each Promotion Type";
/********************************************************************************
 * DISTRIBUTION OF SALES PER DAY OF THE WEEK
 *******************************************************************************/
/* Merge the relevant datasets */
data Sales_Merged;
   merge Project.Sales(in=a) Project.Invoice_Total_Items(in=b);
   by Invoice_ID;
   if a and b;
run;
/* Extract the day of the week using the weekday function */
data Sales_Merged;
   set Sales_Merged;
   SaleDay = weekday(InvoiceDate);
   format SaleDay weekdate9.;
run;
/* Sum of distinct SKUs per weekday */
proc means data=Sales_Merged sum mean noprint nway;
    class SaleDay;
    var Invoice_Total_Items;
    output out=Summary(drop= _type_ _freq_) 
	n(Invoice_Total_Items)=Total_Sale_Transactions 
	sum(Invoice_Total_Items)=Total_Invoice_Distinct_Items
	mean(Invoice_Total_Items)=Average_Invoice_Distinct_Items;
run;
/* Extract the day of the week using the weekday function */
data Sales_Merged;
	set Sales_Merged;
	SaleDay = weekday(InvoiceDate);
	format SaleDay weekdate9.;
	format Average_Invoice_Distinct_Items comma4.1;
run;
/* Print Report */
proc print data=Summary;
   title "Distribution of Sales per Weekday";
run;
/* Pie chart with sale transactions per weekday */
proc gchart data=Summary;
	donut SaleDay / sumvar=Total_Sale_Transactions clockwise discrete slice=outside value=outside percent=inside angle=0;
	format Total_Sale_Transactions comma5.;
	pattern1 color=aquamarine;
	pattern2 color=lightgoldenrodyellow;
	pattern3 color=orange;
	pattern4 color=skyblue;
	pattern5 color=chocolate;
	pattern6 color=gray; 
   	title "Distribution of Sales per Weekday";
/* Bar chart with total invoice distinct items per weekday */
proc sgplot data=Summary;
    vbar SaleDay / response=Total_Invoice_Distinct_Items datalabel;
	format Total_Invoice_Distinct_Items comma6.;
    xaxis label="Weekday";
    yaxis label="Total Invoice Distinct Items";
	title "Total Invoice Distinct Items per Weekday";
run;
/* Bar chart with weekday's distinct items per invoice */
proc sgplot data=Summary;
    vbar SaleDay / response=Average_Invoice_Distinct_Items datalabel;
	format Average_Invoice_Distinct_Items comma4.1;
    xaxis label="Weekday";
    yaxis label="Distinct items per invoice";
	title "Average Invoice Distinct Items per Weekday";
run;