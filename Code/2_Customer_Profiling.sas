/********************************************************************************
 * DEMOGRAPHIC CHARACTERISTICS
 *******************************************************************************/
proc freq data=Project.customers;
   tables Age Gender Region / nocum;
run;
/********************************************************************************
 * AGE RANGE VARIABLE
 *******************************************************************************/
data project.Customers;
   set Project.Customers;
   format Age_Range $10.; /* Define a custom format for Age_Range */
   if Age < 18 then Age_Range = "Under 18";
   else if Age >= 18 and Age <= 25 then Age_Range = "Very Young";
   else if Age >= 26 and Age <= 35 then Age_Range = "Young";
   else if Age >= 36 and Age <= 50 then Age_Range = "Middle Age";
   else if Age >= 51 and Age <= 65 then Age_Range = "Mature";
   else if Age >= 66 and Age <= 75 then Age_Range = "Old";
   else Age_Range = "Very Old";
run;
/********************************************************************************
 * BEHAVIORAL CHARACTERISTICS: Visits to the Stores
 *******************************************************************************/
/* Merge relevant datasets */
proc sort data=project.Customers out=Customers_sorted;
	by customer_id;
run;
proc sort data=project.Invoice out=Invoice_sorted;
	by customer_id;
run;
data customers_invoice;
	merge Customers_sorted (in=a) invoice_sorted (in=b);
	by customer_id;
	if a and b;
run;
/* Define a custom format for Age_Range */
proc format;
   value $age_group
   	  'Under 18' = '1'
      'Very Young' = '2'
      'Young' = '3'
      'Middle Age' = '4'
      'Mature' = '5'
      'Old' = '6'
      'Very Old' = '7';
run;
proc sql noprint;
	create table stores_visits as 
	select Age_Range, COUNT(*) as Stores_Visits 
	from customers_invoice group by Age_Range;
quit;
/* Apply the custom character format and create a new variable for sorting */
data stores_visits;
   set stores_visits;
   Sort_Order = input(put(Age_Range, $age_group.), $3.);
run;
/* Sort the data by Sort_Order while keeping the original Age_Range values */
proc sort data=stores_visits out=stores_visits;
   by Sort_Order;
run;
/* Delete the Sort_Order column */
data stores_visits;
   set stores_visits;
   drop Sort_Order;
run;
/********************************************************************************
 * BEHAVIORAL CHARACTERISTICS: Number of Distinct SKUs purchased
 *******************************************************************************/
/* Merge relevant datasets */
proc sort data=project.customers out=customers_sorted;
	by customer_id;
run;
proc sort data=project.sales out=sales_sorted;
	by customer_id;
run;
data customers_sales;
	merge customers_sorted (in=a) sales_sorted (in=b);
	by customer_id;
	if a and b;
run;
proc sort data=customers_sales out=customers_sales_sorted;
	by invoice_id;
run;
proc sort data=project.basket out=basket_sorted;
	by invoice_id;
run;
data customers_sales_basket;
	merge customers_sales_sorted (in=a) basket_sorted (in=b);
	by invoice_id;
	if a and b;
run;
proc sort data=customers_sales_basket out=customers_sales_basket_sorted;
	by product_id;
run;
proc sort data=project.products out=products_sorted;
	by product_id;
run;
data customers_sales_basket_products;
	merge customers_sales_basket_sorted (in=a) products_sorted (in=b);
	by product_id;
	if a and b;
run;
proc sql noprint;
	create table distinct_SKU as 
	select Age_Range, COUNT(DISTINCT SKU) as distinct_SKU 
	from customers_sales_basket_products group by Age_Range;
quit;
/* Apply the custom character format and create a new variable for sorting */
data distinct_SKU;
   set distinct_SKU;
   Sort_Order = input(put(Age_Range, $age_group.), $3.);
run;
/* Sort the data by Sort_Order while keeping the original Age_Range values */
proc sort data=distinct_SKU out=distinct_SKU;
   by Sort_Order;
run;
/* Delete the Sort_Order column */
data distinct_SKU;
   set distinct_SKU;
   drop Sort_Order;
run;
/********************************************************************************
 * BEHAVIORAL CHARACTERISTICS: Total cost of purchases
 *******************************************************************************/
/* Merge relevant datasets */
proc sort data=customers_sales out=customers_sales_sorted;
	by invoice_id;
run;
proc sort data=project.invoice_total_value out=invoice_total_value_sorted;
	by invoice_id;
run;
data customers_sales_value;
	merge customers_sales_sorted (in=a) invoice_total_value_sorted (in=b);
	by invoice_id;
	if a and b;
run;
proc sql noprint;
	create table total_purchase_cost as 
	select Age_Range, SUM(Invoice_Total_Value) as total_purchase_cost 
	from customers_sales_value group by Age_Range;
quit;
/* Apply the custom character format and create a new variable for sorting */
data total_purchase_cost;
   set total_purchase_cost;
   Sort_Order = input(put(Age_Range, $age_group.), $3.);
run;
/* Sort the data by Sort_Order while keeping the original Age_Range values */
proc sort data=total_purchase_cost out=total_purchase_cost;
   by Sort_Order;
run;
/* Delete the Sort_Order column */
data total_purchase_cost;
   set total_purchase_cost;
   drop Sort_Order;
   total_purchase_cost=round(total_purchase_cost, 0.01);
run;
/********************************************************************************
 * PERCENTAGES OF CUSTOMERS IN EACH AGE GROUP
 *******************************************************************************/
/* Frequency table with percentage of customers by age group */
proc freq data=project.Customers noprint;
  tables Age_Range / nocum out=Age_Group_Freq;
run;
/* Apply the custom character format and create a new variable for sorting */
data Age_Group_Freq;
   set Age_Group_Freq;
   Sort_Order = input(put(Age_Range, $age_group.), $3.);
run;
/* Sort the data by Sort_Order while keeping the original Age_Range values */
proc sort data=Age_Group_Freq out=Age_Group_Freq;
   by Sort_Order;
run;
/* Delete the Sort_Order column */
data Age_Group_Freq;
   set Age_Group_Freq;
   drop Sort_Order;
run;
/* Pie chart with percentage of customers by age group */
proc gchart data=Age_Group_Freq;
  pie Age_Range / sumvar=percent;
  title "Percentage of Customers by Age Group";
/********************************************************************************
 * BEHAVIORAL CHARACTERISTICS OF EACH AGE GROUP
 *******************************************************************************/
/* Pie chart with visits to the stores by age group */
proc gchart data=stores_visits;
  pie Age_Range / sumvar=stores_visits;
  title "Total Visits to the Stores by Age Group";
/* Pie chart with number of distinct SKUs purchased by age group */
proc gchart data=distinct_SKU;
  pie Age_Range / sumvar=distinct_SKU;
  title "Total Number of Distinct SKUs purchased by Age Group";
/* Pie chart with total cost of purchases by age group */
proc gchart data=total_purchase_cost;
  pie Age_Range / sumvar=total_purchase_cost;
  title "Total Cost of Purchases by Age Group";