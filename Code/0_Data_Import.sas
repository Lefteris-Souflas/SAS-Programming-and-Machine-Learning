/********************************************************************************
* Basket 
********************************************************************************/
%web_drop_table(PROJECT.BASKET);
FILENAME REFFILE '/home/u62678062/sasuser.v94/SAS_Project/Basket.xlsx';
PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=PROJECT.BASKET;
	GETNAMES=YES;
RUN;
data project.basket;
	set project.basket;
	if not missing(Invoice_ID) and not missing(Product_ID) and not 
		missing(Promotion_ID) and not missing(Quantity);
	temp1=put(Invoice_ID, best5.);
	temp2=put(Product_ID, best3.);
	temp3=put(Promotion_ID, best1.);
	drop Invoice_ID Product_ID Promotion_ID;
	rename temp1=Invoice_ID temp2=Product_ID temp3=Promotion_ID;
run;
/********************************************************************************
* Customers 
********************************************************************************/
%web_drop_table(PROJECT.CUSTOMERS);
FILENAME REFFILE '/home/u62678062/sasuser.v94/SAS_Project/Customers.csv';
PROC IMPORT DATAFILE=REFFILE DBMS=CSV OUT=PROJECT.CUSTOMERS;
	GETNAMES=YES;
	GUESSINGROWS = MAX;
RUN;
data project.Customers;
	set project.Customers;
	temp1=put(Customer_ID, best5.);
	temp2=put(Postal_Code, best5.);
	drop Customer_ID Postal_Code;
	rename temp1=Customer_ID temp2=Postal_Code;
run;
/********************************************************************************
* Invoice 
********************************************************************************/
%web_drop_table(PROJECT.INVOICE);
FILENAME REFFILE '/home/u62678062/sasuser.v94/SAS_Project/Invoice.csv';
PROC IMPORT DATAFILE=REFFILE DBMS=DLM OUT=PROJECT.INVOICE;
	DELIMITER=";";
	GETNAMES=YES;
	GUESSINGROWS = MAX;
RUN;
data project.Invoice;
	set project.Invoice;
	temp1=put(Invoice_ID, best5.);
	temp2=put(Customer_ID, best5.);
	temp3=put(Payment_Method, best1.);
	drop Invoice_ID Customer_ID Payment_Method;
	rename temp1=Invoice_ID temp2=Customer_ID temp3=Payment_Method;
run;
/********************************************************************************
* Payment_Method 
********************************************************************************/
%web_drop_table(PROJECT.payment_method);
FILENAME REFFILE '/home/u62678062/sasuser.v94/SAS_Project/Payment_Method.csv';
PROC IMPORT DATAFILE=REFFILE DBMS=DLM OUT=PROJECT.payment_method;
	DELIMITER=";";
	GETNAMES=YES;
	GUESSINGROWS = MAX;
RUN;
data project.Payment_Method;
	set project.Payment_Method;
	temp1=put(Code, best1.);
	drop Code;
	rename temp1=Code;
run;
/********************************************************************************
* Product_Origin 
********************************************************************************/
%web_drop_table(PROJECT.PRODUCT_ORIGIN);
FILENAME REFFILE '/home/u62678062/sasuser.v94/SAS_Project/Product_Origin.xlsx';
PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=PROJECT.PRODUCT_ORIGIN;
	GETNAMES=YES;
RUN;
data project.Product_Origin;
	set project.Product_Origin;
	temp1=put(Code, best1.);
	drop Code;
	rename temp1=Code;
run;
/********************************************************************************
* Products 
********************************************************************************/
%web_drop_table(PROJECT.Products);
FILENAME REFFILE '/home/u62678062/sasuser.v94/SAS_Project/Products.csv';
PROC IMPORT DATAFILE=REFFILE DBMS=CSV OUT=PROJECT.Products;
	GETNAMES=YES;
	GUESSINGROWS = MAX;
RUN;
data project.Products;
	set project.Products;
	temp1=put(Product_ID, best3.);
	temp2=put(SKU, best19.);
	temp3=put(Product_Origin, best1.);
	drop Product_ID SKU Product_Origin;
	rename temp1=Product_ID temp2=SKU temp3=Product_Origin;
run;
/********************************************************************************
* Promotions 
********************************************************************************/
%web_drop_table(PROJECT.PROMOTIONS);
FILENAME REFFILE '/home/u62678062/sasuser.v94/SAS_Project/Promotions.xlsx';
PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=PROJECT.PROMOTIONS;
	GETNAMES=YES;
RUN;
data project.Promotions;
	set project.Promotions;
	temp1=put(Promotion_ID, best1.);
	drop Promotion_ID;
	rename temp1=Promotion_ID;
run;
/********************************************************************************
* Suppliers 
********************************************************************************/
%web_drop_table(PROJECT.SUPPLIERS);
FILENAME REFFILE '/home/u62678062/sasuser.v94/SAS_Project/Suppliers.xlsx';
PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=PROJECT.SUPPLIERS;
	GETNAMES=YES;
RUN;
data project.Suppliers;
	set project.Suppliers;
	temp1=put(Supplier_ID, best1.);
	drop Supplier_ID;
	rename temp1=Supplier_ID;
run;
