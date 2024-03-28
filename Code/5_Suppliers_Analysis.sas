/********************************************************************************
 * PERCENTAGE OF PRODUCTS SOLD BY SUPPLIER
 *******************************************************************************/
/* Supplier_ID column in Products table */
data project.products;
	set project.products;
	supplier_id = substr(SKU, 9, 1);
run;
/* Merge the relevant datasets */
proc sort data=project.products out=products_sorted;
	by supplier_id;
run;
proc sort data=project.suppliers out=suppliers_sorted;
	by supplier_id;
run;
data products_suppliers;
	merge products_sorted (in=a) suppliers_sorted (in=b);
	by supplier_id;
	if a and b;
run;
proc sort data=products_suppliers out=products_suppliers;
	by product_id;
run;
proc sort data=project.basket out=basket_sorted;
	by product_id;
run;
data basket_products_suppliers;
	merge products_suppliers (in=a) basket_sorted (in=b);
	by product_id;
	if a and b;
run;
proc sort data=basket_products_suppliers out=basket_products_suppliers;
	by invoice_id;
run;
proc sort data=project.sales out=sales_sorted;
	by invoice_id;
run;
data sales_basket_products_suppliers;
	merge basket_products_suppliers (in=a) sales_sorted (in=b);
	by invoice_id;
	if a and b;
run;
/* Sum of products per supplier */
proc freq data=sales_basket_products_suppliers;
	tables Supplier_Name / nocum out=Summary;
	weight Quantity;
	title "Percentage of Products Sold by Each Supplier";
run;
proc gchart data=Summary;
	pie3d Supplier_Name / sumvar=count clockwise discrete slice=outside value=outside percent=inside;
	format count comma7.; 
   	title "Percentage of Products Sold by Each Supplier";
/********************************************************************************
 * REVENUES OF PRODUCTS SOLD BY SUPPLIER
 *******************************************************************************/
/* Step 1: Merge the relevant datasets */
proc sort data=project.basket out=basket_sorted;
	by invoice_id;
run;
proc sort data=project.sales out=sales_sorted;
	by invoice_id;
run;
data basket_sales;
	merge basket_sorted (in=a) sales_sorted (in=b);
	by invoice_id;
	if a and b;
run;
proc sort data=basket_sales out=basket_sales_sorted;
	by product_id;
run;
proc sort data=project.products out=products_sorted;
	by product_id;
run;
data basket_sales_products;
	merge basket_sales_sorted (in=a) products_sorted (in=b);
	by product_id;
	if a and b;
run;
proc sort data=basket_sales_products out=basket_sales_products_sorted;
	by promotion_id;
run;
proc sort data=project.promotions out=promotions_sorted;
	by promotion_id;
run;
data bask_sales_prod_prom;
	merge basket_sales_products_sorted (in=a) promotions_sorted (in=b);
	by promotion_id;
	if a and b;
	/* Calculate the new variable Value_after_discount */
	Value_After_Discount=(1-Promotion)*Product_Price*Quantity;
	/* Format the new variable with two decimal places and no dollar sign */
	format Value_After_Discount COMMA8.2;
run;
proc sort data=bask_sales_prod_prom out=bask_sales_prod_prom;
	by supplier_id;
run;
proc sort data=project.suppliers out=suppliers_sorted;
	by supplier_id;
run;
data bask_sales_prod_prom_sup;
	merge bask_sales_prod_prom (in=a) suppliers_sorted (in=b);
	by supplier_id;
	if a and b;
run;
/* Step 2: Calculate Supplier_Revenues using PROC MEANS and OUTPUT statement */
proc means data=bask_sales_prod_prom_sup noprint nway;
	class Supplier_Name;
	var Value_After_Discount;
	output out=Supplier_Revenues(drop=_type_ _freq_) 
		sum(Value_After_Discount)=Supplier_Revenues;
run;
/* Bar chart with Revenues by Supplier */
proc sgplot data=Supplier_Revenues;
    vbar Supplier_Name / response=Supplier_Revenues datalabel dataskin=gloss categoryorder=respdesc;
	format Supplier_Revenues dollar15.2;
    xaxis label="Supplier";
    yaxis label="Revenues";
	title "Revenues of Products Sold by Each Supplier";
run;
/* The respective donut chart */
proc gchart data=Supplier_Revenues;
	donut Supplier_Name / sumvar=Supplier_Revenues clockwise discrete slice=outside value=outside percent=inside descending;
	format Supplier_Revenues dollar15.2;
   	title "Distribution of Revenues per Supplier";
/********************************************************************************
 * TOTAL REVENUE OF THE COMPANY W.R.T. ORIGINS OF PRODUCTS SOLD BY SUPPLIER
 *******************************************************************************/
/* Merge relevant datasets */
proc sort data=bask_sales_prod_prom_sup out=bask_sales_prod_prom_sup;
	by product_origin;
run;
proc sort data=project.product_origin out=product_origin_sorted;
	by code;
run;
data bask_sales_prod_prom_sup_or;
	merge bask_sales_prod_prom_sup (in=a) product_origin_sorted (rename=(Code=product_origin) in=b);
	by product_origin;
	if a and b;
run;
/* Create a cross-tabulation table using proc tabulate */
proc tabulate data=bask_sales_prod_prom_sup_or;
	class Country Supplier_Name;
	var Value_After_Discount;
	table Country='Country of Origin' all='Total', 
		(Supplier_Name='Supplier' all='Total')*Value_After_Discount=''*(sum=''*f=dollar15.2);
	title "Total Revenue by Product Origin & Supplier";	
run;