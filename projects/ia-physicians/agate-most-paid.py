import agate

tester = agate.TypeTester(force={
	'Physician_First_Name': agate.Text(),
	'Physician_Last_Name': agate.Text(),
	'Recipient_Primary_Business_Street_Address_Line1': agate.Text(),
	'Recipient_City': agate.Text(),
	'Recipient_Zip_Code': agate.Text(),
	'Physician_Specialty': agate.Text(),
	'Physician_Profile_ID': agate.Number(),
	'Total_Amount_of_Payment_USDollars': agate.Number(),
	'General': agate.Number(),
	'Research': agate.Number()
})

column_renames = {
	'Physician_First_Name': 'fn',
	'Physician_Last_Name': 'ln',
	'Recipient_Primary_Business_Street_Address_Line1': 'add',
	'Recipient_City': 'city',
	'Recipient_Zip_Code': 'zip',
	'Physician_Specialty': 'spec',
	'Physician_Profile_ID': 'id',
	'Total_Amount_of_Payment_USDollars': 'd',
	'General': 'g',
	'Research': 'r'
}

table = agate.Table.from_csv('edits/payments/most-paid-02-trim.csv', column_types=tester).rename(column_names=column_renames)

table.to_csv('edits/payments/most-paid-03-rename.csv')