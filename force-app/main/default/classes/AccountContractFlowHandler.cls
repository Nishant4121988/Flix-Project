public class AccountContractFlowHandler {
    public class AccessDeniedException extends Exception {}

    @InvocableMethod(label='Create Account Contract and Link Clauses' description='Creates a new Account Contract and links Account Contract Clauses to it.')
    public static void createAccountContractAndLinkClauses(List<Request> requestList) {
        for (Request request : requestList) {
            Id accountId = request.accountId;
            
            // Validate create access for Account_Contract__c object
            if (!Schema.sObjectType.Account_Contract__c.isCreateable()) {
                throw new AccessDeniedException('No create access to Account_Contract__c object');
            }

            // Fetch the Account record
            Account acc = [SELECT Id, BillingCountry FROM Account WHERE Id = :accountId LIMIT 1];

            // Create the new Account Contract
            Account_Contract__c newContract = new Account_Contract__c(Account__c = accountId, Name = 'New Contract');
            insert newContract;

            // Validate update access for Account_Contract_Clause__c object
            if (!Schema.sObjectType.Account_Contract_Clause__c.isUpdateable()) {
                throw new AccessDeniedException('No update access to Account_Contract_Clause__c object');
            }

            // Fetch relevant Account Contract Clauses
            List<Account_Contract_Clause__c> clausesToUpdate = [
                SELECT Id, Name__c, Billing_Country__c
                FROM Account_Contract_Clause__c
                WHERE Account_Contract__r.Account__c = :accountId
                AND Billing_Country__c = :acc.BillingCountry
            ];
            
            // Link clauses to the new Account Contract
            for (Account_Contract_Clause__c clause : clausesToUpdate) {
                clause.Account_Contract__c = newContract.Id;
            }
            update clausesToUpdate;

            // Prepare content for the file
            String fileContent = 'Name\t\t\tBilling Country\n';
            for (Account_Contract_Clause__c clause : clausesToUpdate) {
                fileContent += clause.Name__c + '\t\t\t' + clause.Billing_Country__c + '\n';
            }

            // Validate create access for ContentVersion object
            if (!Schema.sObjectType.ContentVersion.isCreateable()) {
                throw new AccessDeniedException('No create access to ContentVersion object');
            }

            // Create the file and link it to the new Account Contract
            ContentVersion version = new ContentVersion();
            version.Title = 'Contract Clauses';
            version.PathOnClient = 'ContractClauses.txt';
            version.VersionData = Blob.valueOf(fileContent);
            version.FirstPublishLocationId = newContract.Id;
            insert version;
        }
    }

    public class Request {
        @InvocableVariable(label='Account Id' description='Id of the Account' required=true)
        public Id accountId;
    }
}