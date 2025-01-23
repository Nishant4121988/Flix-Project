Dear Veronika and Tanmay,

I would like to sincerely thank you for providing me with the opportunity to work on these challenges. It has been a truly enjoyable and rewarding experience, and I am hopeful that the solutions I've implemented meet your expectations.

Please allow me to provide a brief overview of how I approached each challenge:

Challenge 1: Lightning Web Component and File Creation

For this challenge, we have successfully completed the task using a Lightning Web Component. While this task can also be accomplished using Flow, I opted for LWC as Challenge 3 already involves working with Flow.

The solution involves linking the displayed records (Account_Contract_Clause) to the newly created Account_Contract records. Additionally, a .txt file is generated and stored in the Account_Contract__c record, which is created in this process. While I've implemented the .txt file generation, it is also possible to create .csv or .pdf files, depending on your requirements.

Challenge 2: Permission Set Swapping

This challenge can be approached in two ways: manually or automatically via an Apex Class.

Manual Approach:
You have already created the following permission sets:

Basic Access: Provides Read permissions for the Account, Account_Contract__c, and Account_Contract_Clause__c objects and their fields.
Advanced Access: Provides Read, Create, Edit, and Delete permissions for the same objects and their fields.
Steps for swapping permissions manually:

Export the current object and field permissions using Data Loader.
Modify the exported CSV files to swap the permissions between Basic Access and Advanced Access.
Update the permissions in Salesforce by loading the modified files using Data Loader.
Verify the changes to ensure that the permissions have been successfully swapped.
Automatic Approach (Apex):
For automating the process, I have written an Apex class named PermissionSetSwapper, which is available in the GitHub repository ("Flix-Project"). While I do not recommend directly using this in a production environment, I have also provided a corresponding test class for your reference.
If you prefer, you can also run the same logic directly using the Apex Execute Anonymous window.

Challenge 3: Custom Picklist and Flow

For this challenge, I have successfully created a custom picklist called ‘Status’ on the Account object and set up a corresponding Path for it. Additionally, I have created a flow named ‘Account || Email to the Owner’, which triggers an email whenever the status is updated and the record's status change is assigned to the record owner.

Once again, I truly appreciate the opportunity to work on this project. It was a great learning experience, and I hope the solutions provided meet your expectations. Please feel free to reach out if you have any further questions or if there are any additional tasks I can assist with.

Looking forward to hearing your feedback!
