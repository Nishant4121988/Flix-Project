public with sharing class AccountContractController {
    public class AccessDeniedException extends Exception {}

    @AuraEnabled(cacheable=true)
    public static List<Account_Contract_Clause__c> getAccountContractClauses(Id accountId) {
        // Validate read access for Account object
        if (!Schema.sObjectType.Account.fields.BillingCountry.isAccessible()) {
            throw new AccessDeniedException('No access to BillingCountry field on Account');
        }

        // Validate read access for Account_Contract_Clause__c object
        if (!Schema.sObjectType.Account_Contract_Clause__c.isAccessible()) {
            throw new AccessDeniedException('No access to Account_Contract_Clause__c object');
        }

        // Fetch the billing country of the account
        Account acc = [SELECT BillingCountry FROM Account WHERE Id = :accountId LIMIT 1];
        
        // Fetch the Account Contract Clauses related to the Account's Billing Country
        return [
            SELECT Id, Name__c, Billing_Country__c
            FROM Account_Contract_Clause__c
            WHERE Account_Contract__r.Account__r.Id = :acc.Id AND Billing_Country__c = :acc.BillingCountry
        ];
    }

    @AuraEnabled
    public static void createAccountContractAndLinkClauses(Id accountId, List<Id> clauseIds) {
        // Validate create access for Account_Contract__c object
        if (!Schema.sObjectType.Account_Contract__c.isCreateable()) {
            throw new AccessDeniedException('No create access to Account_Contract__c object');
        }

        Account_Contract__c newContract = new Account_Contract__c(Account__c = accountId, Name = 'New Contract');
        insert newContract;

        // Validate update access for Account_Contract_Clause__c object
        if (!Schema.sObjectType.Account_Contract_Clause__c.isUpdateable()) {
            throw new AccessDeniedException('No update access to Account_Contract_Clause__c object');
        }

        List<Account_Contract_Clause__c> clausesToUpdate = [
            SELECT Id, Name__c, Billing_Country__c
            FROM Account_Contract_Clause__c
            WHERE Id IN :clauseIds
        ];
        for (Account_Contract_Clause__c clause : clausesToUpdate) {
            clause.Account_Contract__c = newContract.Id;
        }
        update clausesToUpdate;

        // Prepare content for the file with multi-line formatting for Name column
        String fileContent = 'Name                       \tBilling Country\n'; // Adjusted spacing for titles
        for (Account_Contract_Clause__c clause : clausesToUpdate) {
            fileContent += formatNameAndBillingCountry(clause.Name__c, clause.Billing_Country__c, 27); // Adjusted column width
        }

        // Validate create access for ContentVersion object
        if (!Schema.sObjectType.ContentVersion.isCreateable()) {
            throw new AccessDeniedException('No create access to ContentVersion object');
        }

        ContentVersion version = new ContentVersion();
        version.Title = 'Contract Clauses';
        version.PathOnClient = 'ContractClauses.txt';
        version.VersionData = Blob.valueOf(fileContent);
        version.FirstPublishLocationId = newContract.Id;
        insert version;
    }

    // Helper method to format Name and Billing Country into multi-line format
    Public static String formatNameAndBillingCountry(String name, String billingCountry, Integer nameColumnWidth) {
        List<String> lines = new List<String>();
        Integer length = name.length();
        for (Integer i = 0; i < length; i += nameColumnWidth) {
            lines.add(name.substring(i, Math.min(i + nameColumnWidth, length)).trim());
        }

        String formattedText = '';
        for (Integer i = 0; i < lines.size(); i++) {
            if (i == 0) {
                formattedText += padString(lines[i], nameColumnWidth) + '\t' + billingCountry + '\n';
            } else {
                formattedText += padString(lines[i], nameColumnWidth) + '\t\n';
            }
        }
        return formattedText;
    }

    // Helper method to pad strings to a fixed width
    public static String padString(String input, Integer length) {
        if (input.length() > length) {
            return input.substring(0, length);
        }
        return input + ' '.repeat(length - input.length());
    }
}