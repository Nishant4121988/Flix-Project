Overview
This project involves three main challenges:

Lightning Web Component and File Creation

Permission Set Swapping

Custom Picklist and Flow

Challenge 1: Lightning Web Component and File Creation
For this challenge, the task was completed using a Lightning Web Component (LWC). The solution involves linking the displayed records (Account_Contract_Clause) to the newly created Account_Contract records. Additionally, a .txt file is generated and stored in the Account_Contract__c record created in this process. The file format can be adapted to .csv or .pdf based on requirements.

Challenge 2: Permission Set Swapping
This challenge can be approached manually or automatically via an Apex Class.

Manual Approach
Basic Access: Read permissions for Account, Account_Contract__c, and Account_Contract_Clause__c objects and their fields.

Advanced Access: Read, Create, Edit, and Delete permissions for the same objects and their fields.

Steps:

Export the current object and field permissions using Data Loader.

Modify the exported CSV files to swap the permissions between Basic Access and Advanced Access.

Update the permissions in Salesforce by loading the modified files using Data Loader.

Verify the changes to ensure successful swapping.

Automatic Approach (Apex)
An Apex class named PermissionSetSwapper is available in the GitHub repository ("Flix-Project"). A corresponding test class is provided for reference. This logic can be run using the Apex Execute Anonymous window.

Challenge 3: Custom Picklist and Flow
A custom picklist called ‘Status’ was created on the Account object with a corresponding Path. Additionally, a flow named ‘Account || Email to the Owner’ was set up to trigger an email whenever the status is updated, and the record's status change is assigned to the record owner.

Installation Instructions
1 . Clone the repository:
    git clone https://github.com/Nishant4121988/Flix-Project.git
    cd Flix-Project

2. Deploy the metadata to Salesforce:
    sfdx force:source:deploy -p src

Running Tests
Open the Salesforce Developer Console.

Navigate to Setup > Apex Test Execution.

Select the AccountContractControllerTest class and run the tests.
