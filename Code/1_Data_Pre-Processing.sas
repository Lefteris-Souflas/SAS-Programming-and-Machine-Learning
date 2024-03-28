/********************************************************************************
 * INVOICE TOTAL ITEMS
 *******************************************************************************/
/* Step 1: Merge the relevant datasets */
proc sort data=project.basket out=basket_sorted;
	by invoice_id;
run;
proc sort data=project.invoice out=invoice_sorted;
	by invoice_id;
run;
data basket_invoice;
	merge basket_sorted (in=b) invoice_sorted (in=i);
	by invoice_id;
	if i;
run;
proc sort data=basket_invoice out=basket_invoice_sorted;
	by product_id;
run;
proc sort data=project.products out=products_sorted;
	by product_id;
run;
data basket_invoice_products;
	merge basket_invoice_sorted (in=b) products_sorted (in=p);
	by product_id;
	if b;
run;
/* Step 2: Calculate the number of SKU's for each invoice using PROC SQL */
proc sql noprint;
	create table project.Invoice_Total_Items as select Invoice_ID, COUNT(SKU) as 
		Invoice_Total_Items from basket_invoice_products group by Invoice_ID;
quit;
/* Step 3: Print the first 10 observations of the new dataset */
proc print data=project.Invoice_Total_Items(obs=10);
run;
/********************************************************************************
 * INVOICE TOTAL VALUE
 *******************************************************************************/
/* Step 1: Merge the relevant datasets */
proc sort data=basket_invoice_products 
		out=basket_invoice_products_sorted;
	by promotion_id;
run;
proc sort data=project.promotions out=promotions_sorted;
	by promotion_id;
run;
data bask_inv_prod_prom;
	merge basket_invoice_products_sorted (in=a) promotions_sorted (in=b);
	by promotion_id;
	if a;
	/* Calculate the new variable Value_after_discount */
	Value_After_Discount=(1-Promotion)*Product_Price*Quantity;
	/* Format the new variable with two decimal places and no dollar sign */
	format Value_After_Discount COMMA8.2;
run;
/* Step 2: Calculate Invoice_Total_Value using PROC MEANS and OUTPUT statement */
proc means data=Bask_Inv_Prod_Prom noprint nway;
	class Invoice_ID;
	var Value_After_Discount;
	output out=Project.Invoice_Total_Value(drop=_type_ _freq_) 
		sum(Value_After_Discount)=Invoice_Total_Value;
run;
/********************************************************************************
 * INVOICE DIVISION
 *******************************************************************************/
data Project.Sales Project.Returns;
	set Project.Invoice;
	if Operation='Sale' then
		output Project.Sales;
	else if Operation='Return' then
		output Project.Returns;
run;
/********************************************************************************
 * CUSTOMER'S AGE
 *******************************************************************************/
data Project.Customers;
	set Project.Customers;
	/* Filter valid ages (1910 < age < 2001) */
	where Year_Of_Birth > 1910 and Year_Of_Birth < 2001;
	/* Create a valid birth date using Day, Month, and Year */
	Birth_Date=mdy(Month_Of_Birth, Day_Of_Birth, Year_Of_Birth);
	/* Calculate the age based on the valid birth date
	and adjust for not having reached the birthday for that year */
	Age=floor(intck('year', Birth_Date, '01JAN2019'd) - (Day(Birth_Date) > 1 or 
		Month(Birth_Date) > 1));
run;