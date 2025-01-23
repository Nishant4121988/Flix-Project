import { LightningElement, api, wire } from 'lwc'; // Import necessary modules from LWC
import getAccountContractClauses from '@salesforce/apex/AccountContractController.getAccountContractClauses'; // Import Apex method
import createAccountContractAndLinkClauses from '@salesforce/apex/AccountContractController.createAccountContractAndLinkClauses'; // Import another Apex method
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import toast event for notifications
import { NavigationMixin } from 'lightning/navigation'; // Import navigation mixin for navigating to different pages

// Define the LWC component
export default class AccountContractClauses extends NavigationMixin(LightningElement) {
    @api recordId; // API decorator to expose the recordId property
    clauses = []; // Initialize clauses array

    // Wire decorator to call the getAccountContractClauses Apex method with the accountId
    @wire(getAccountContractClauses, { accountId: '$recordId' })
    wiredClauses({ error, data }) {
        if (data) {
            // Map the received data to add URLs for each clause
            this.clauses = data.map(clause => ({
                ...clause, // Spread operator to include all clause properties
                url: `/lightning/r/Account_Contract_Clause__c/${clause.Id}/view` // Construct URL for each clause
            }));
        } else if (error) {
            // Dispatch an error toast if there is an issue
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading clauses',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }

    // Method to handle the proceed action
    handleProceed() {
        // Map the clauses array to get an array of clause IDs
        const clauseIds = this.clauses.map(clause => clause.Id);
    
        // Call the createAccountContractAndLinkClauses Apex method
        createAccountContractAndLinkClauses({ accountId: this.recordId, clauseIds })
            .then(() => {
                // Dispatch a success toast if the contract and clauses are created successfully
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account Contract and Clauses have been created and linked successfully!',
                        variant: 'success',
                    })
                );
    
                // Navigate to the newly created Account Contract record page
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'Account_Contract__c',
                        actionName: 'view',
                    },
                });
            })
            .catch(error => {
                // Dispatch an error toast if there is an issue creating the contract
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating contract',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    // Method to handle the close action
    handleClose() {
        // Dispatch a custom event to signal the close action
        this.dispatchEvent(new CustomEvent('close'));
        
        // Optionally, navigate to the Account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId, //use the current recordId.
                objectApiName: 'Account', // mention the objectAPI name.
                actionName: 'view' // mention the action name which you want to navigate in the current record.
            },
        });
    }
}