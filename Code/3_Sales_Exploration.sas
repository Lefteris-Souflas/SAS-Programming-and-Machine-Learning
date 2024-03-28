/********************************************************************************
 * LEVEL OF SALES AND RETURNS
 *******************************************************************************/
/* Merge the relevant datasets */
proc sort data=project.invoice_total_value out=invoice_value_sorted;
	by invoice_id;
run;
proc sort data=project.invoice out=invoice_sorted;
	by invoice_id;
run;
data sales_returns_value;
	merge invoice_value_sorted (in=a) invoice_sorted (in=b);
	by invoice_id;
	if a and b;
run;
/* Query */
proc sql noprint;
	create table sales_returns_aggr_value as 
	select Operation, ROUND(Total_Value, 0.01) as Total_Value from
	(select Operation, SUM(Invoice_Total_Value) as Total_Value 
	from sales_returns_value group by Operation);
quit;
/* Create a bar chart for sales and returns */
proc sgplot data=sales_returns_aggr_value;
    vbar Operation / response=Total_Value datalabel;
    xaxis label="Operation";
    yaxis label="Total Value";
    title "Monetary Value by Operation";
run;
/********************************************************************************
 * AVERAGE BASKET SIZE
 *******************************************************************************/
/* Merge the relevant datasets */
proc sort data=project.invoice_total_items out=invoice_items_sorted;
	by invoice_id;
run;
proc sort data=project.sales out=sales_sorted;
	by invoice_id;
run;
data sales_items_value;
	merge sales_sorted (in=a) invoice_items_sorted (in=b) invoice_value_sorted (in=c);
	by invoice_id;
	if a and b and c;
run;
proc sort data=sales_items_value out=sales_items_value_sorted;
	by payment_method;
run;
proc sort data=project.payment_method out=payment_method_sorted;
	by code;
run;
data sales_items_value;
	merge sales_items_value_sorted (in=a) payment_method_sorted (in=b rename=code=payment_method);
	by payment_method;
	if a and b;
run;
/* Queries */
proc sql noprint;
	create table basket_over_time as
	select Date, ROUND(AVG(Invoice_Total_Items)) as Avg_Items, 
	ROUND(AVG(Invoice_Total_Value), 0.01) as Avg_Value from
	(select put(InvoiceDate, YYMMS.) as Date, 
	Invoice_Total_Items, Invoice_Total_Value
	from sales_items_value) group by Date;
	create table basket_by_payment as
	select Method as Payment_Method, ROUND(AVG(Invoice_Total_Items)) as Avg_Items, 
	ROUND(AVG(Invoice_Total_Value), 0.01) as Avg_Value
	from sales_items_value group by Method;
	select ROUND(AVG(Avg_Items)) into :avg_Avg_Items
    from basket_over_time;
    select ROUND(AVG(Avg_Value),0.01) into :avg_Avg_Value
    from basket_over_time;
quit;
/* Create line charts for average basket size over time */
proc sgplot data=basket_over_time;
    series x=Date y=Avg_Items;
    xaxis label="Month";
    yaxis label="Number of SKUs" min=10 max=20;
    refline &avg_Avg_Items / lineattrs=(pattern=dash) 
    label="Average Basket Size:&avg_Avg_Items" labelpos=max;
    title "Average Basket Size Over Time";
run;
proc sgplot data=basket_over_time;
    series x=Date y=Avg_Value;
    xaxis label="Month";
    yaxis label="Basket Monetary Value" min=500 max=1200;
    refline &avg_Avg_Value / lineattrs=(pattern=dash) 
    label="Average Basket Value:&avg_Avg_Value" labelpos=max;
    title "Average Basket Monetary Value Over Time";
run;
/* Create bar charts for the average basket size by payment method */
proc sgplot data=basket_by_payment;
    vbar Payment_Method / response=Avg_Items datalabel;
    xaxis label="Payment Method";
    yaxis label="Number of SKUs";
    title "Average Basket Size by Payment Method";
run;
proc sgplot data=basket_by_payment;
    vbar Payment_Method / response=Avg_Value datalabel;
    xaxis label="Payment Method";
    yaxis label="Basket Monetary Value";
    title "Average Basket Monetary Value by Payment Method";
/********************************************************************************
 * TOP PRODUCTS
 *******************************************************************************/
/* Merge relevant datasets */
proc sort data=sales_items_value out=sales_items_value_sorted;
	by invoice_id;
run;
proc sort data=project.basket out=basket_sorted;
	by invoice_id;
run;
data basket_sales_value;
	merge sales_items_value_sorted (in=a) basket_sorted (in=b);
	by invoice_id;
	if a and b;
run;
proc sort data=basket_sales_value out=basket_sales_value_sorted;
	by product_id;
run;
proc sort data=project.products out=products_sorted;
	by product_id;
run;
data basket_products_sales_value;
	merge basket_sales_value_sorted (in=a) products_sorted (in=b);
	by product_id;
	if a and b;
run;
/* Report for top products and subtotal sales by product type */
proc sql;
   title "Top Products per Product Line and Product Type";
   SELECT a.'Product Line'n, a.'Product Type'n, Subtotal_Sales, Product as Top_Product, 
   Product_ID as Top_Product_ID, SKU as Top_Product_SKU, Product_Sales as Top_Product_Sales
   FROM (select 'Product Line'n, 'Product Type'n, c.Product_ID, Product, 
   	SKU, SUM(Quantity) as Product_Sales
   	from project.sales a, project.basket b, project.products c
   	where a.Invoice_ID = b.Invoice_ID and b.product_ID = c.product_ID
   	group by 'Product Line'n, 'Product Type'n, c.Product_ID, Product, SKU) a, 
   	(select 'Product Line'n, 'Product Type'n, sum(Quantity) as Subtotal_Sales
    from basket_products_sales_value a
    group by 'Product Line'n, 'Product Type'n) b
   WHERE a.'Product Line'n = b.'Product Line'n AND a.'Product Type'n = b.'Product Type'n
   GROUP BY a.'Product Line'n, a.'Product Type'n
   HAVING MAX(Product_Sales) = Product_Sales
   UNION
   SELECT 'Product Line'n, '~~~SUM~~~', SUM(Quantity), '~~~', '~~~', '~~~', . 
   FROM project.sales a, project.basket b, project.products c
   WHERE a.Invoice_ID = b.Invoice_ID and b.product_ID = c.product_ID
   GROUP BY 'Product Line'n;
quit;
/********************************************************************************
 * REVENUES BY REGION
 *******************************************************************************/
/* Merge relevant datasets */
/* Customers, Sales, Invoice_Total_Value */
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
proc sort data=customers_sales out=customers_sales_sorted;
	by invoice_id;
run;
proc sort data=project.Invoice_Total_Value out=Invoice_Total_Value_sorted;
	by invoice_id;
run;
data customers_sales_value;
	merge customers_sales_sorted (in=a) Invoice_Total_Value_sorted (in=b);
	by invoice_id;
	if a and b;
/* Query */
proc sql noprint;
 CREATE TABLE Region_Revenues as
 	SELECT Region, SUM(Invoice_Total_Value) as Revenues
 	FROM customers_sales_value
 	GROUP BY Region;
 CREATE TABLE Date_Region_Revenues as
 	SELECT put(InvoiceDate, YYMMS.) as Date, Region, SUM(Invoice_Total_Value) as Revenues
 	FROM customers_sales_value
 	GROUP BY put(InvoiceDate, YYMMS.), Region;
quit;
/* Graphs */
/* Pie chart */
proc gchart data=Region_Revenues;
  pie Region / sumvar=Revenues;
  title "Revenues Contribution of each Region";
run;
/* Create lines chart for revenues per region over time */
proc sort data=Date_Region_Revenues;
    by Date;
run;
proc sgplot data=Date_Region_Revenues;
    series x=Date y=Revenues / group=Region datalabel=Region;
    xaxis label="Month";
    yaxis label="Revenues";
    title "Revenues per Region Over Time";
run;
/********************************************************************************
 * TOP REGION BY GENDER
 *******************************************************************************/
/* Query */
proc sql noprint;
 CREATE TABLE Gender_SP_Revenues as
 	SELECT Gender, Region, SUM(Invoice_Total_Value) as Revenues
 	FROM customers_sales_value
 	WHERE Region = 'SP'
 	GROUP BY Gender, Region
 	ORDER BY Gender DESC;
/* Pie chart */
proc gchart data=Gender_SP_Revenues;
  pie Gender / sumvar=Revenues;
  title "Revenues Contribution of SP by Gender";