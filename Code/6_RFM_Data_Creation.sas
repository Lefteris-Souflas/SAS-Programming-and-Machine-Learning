/********************************************************************************
 * RFM Data Creation
 *******************************************************************************/
/* The Product_Price, Quantity, and Promotion variables are used for the 
creation of the invoice_total_value dataset */
proc sql;
	CREATE TABLE Project.RFM_Data as (
	SELECT a.Customer_ID, 
		intck('WEEK', MAX(InvoiceDate), '16dec2011'd, 'C') as R, 
		COUNT(b.Invoice_ID) as F,
		SUM(Invoice_Total_Value) as M,
		-1 as T
	FROM project.customers a 
		INNER JOIN project.sales b ON a.customer_id=b.customer_id
		INNER JOIN project.invoice_total_value c ON b.invoice_id=c.invoice_id
	GROUP BY a.Customer_ID
	);
quit;
proc print data=project.rfm_data(obs=10) noobs;
	var Customer_ID R F M;
	title "Sample of 10 Customers' RFM Data";
run;