@isTest
private class AccountContractControllerTest {
    
    @isTest
    static void testGetAccountContractClauses() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'USA');
        insert testAccount;

        Account_Contract__c testContract = new Account_Contract__c(Account__c = testAccount.Id, Name = 'Test Contract');
        insert testContract;

        Account_Contract_Clause__c clause1 = new Account_Contract_Clause__c(
            Name__c = 'Clause 1', 
            Billing_Country__c = 'USA', 
            Account_Contract__c = testContract.Id
        );
        Account_Contract_Clause__c clause2 = new Account_Contract_Clause__c(
            Name__c = 'Clause 2', 
            Billing_Country__c = 'USA', 
            Account_Contract__c = testContract.Id
        );
        insert new List<Account_Contract_Clause__c>{clause1, clause2};

        Test.startTest();
        List<Account_Contract_Clause__c> result = AccountContractController.getAccountContractClauses(testAccount.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(2, result.size(), 'Expected 2 clauses');
        System.assertEquals('Clause 1', result[0].Name__c);
        System.assertEquals('USA', result[0].Billing_Country__c);
        System.assertEquals('Clause 2', result[1].Name__c);
        System.assertEquals('USA', result[1].Billing_Country__c);
    }

    @isTest
    static void testCreateAccountContractAndLinkClauses() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'USA');
        insert testAccount;

        Account_Contract_Clause__c clause1 = new Account_Contract_Clause__c(
            Name__c = 'Clause 1',
            Billing_Country__c = 'USA'
        );
        Account_Contract_Clause__c clause2 = new Account_Contract_Clause__c(
            Name__c = 'Clause 2',
            Billing_Country__c = 'USA'
        );
        insert new List<Account_Contract_Clause__c>{clause1, clause2};

        Test.startTest();
        AccountContractController.createAccountContractAndLinkClauses(testAccount.Id, new List<Id>{clause1.Id, clause2.Id});
        Test.stopTest();

        // Verify the contract
        Account_Contract__c newContract = [SELECT Id, Account__c FROM Account_Contract__c WHERE Account__c = :testAccount.Id LIMIT 1];
        System.assertNotEquals(null, newContract, 'Expected contract to be created');
        System.assertEquals(testAccount.Id, newContract.Account__c, 'Expected contract to be linked to test account');

        // Verify clauses are updated
        List<Account_Contract_Clause__c> updatedClauses = [SELECT Id, Account_Contract__c FROM Account_Contract_Clause__c WHERE Id IN :new List<Id>{clause1.Id, clause2.Id}];
        System.assertEquals(2, updatedClauses.size(), 'Expected 2 clauses to be updated');
        for (Account_Contract_Clause__c clause : updatedClauses) {
            System.assertEquals(newContract.Id, clause.Account_Contract__c, 'Expected clause to be linked to new contract');
        }
    }
	
    @isTest
    static void testAccessDeniedExceptionForBillingCountry() {
        // Create a restricted user
        Profile restrictedProfile = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - API Only Integrations' LIMIT 1];
        User restrictedUser = new User(
            Alias = 'testuser',
            Email = 'restricteduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Restricted',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = restrictedProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'restricteduser' + System.currentTimeMillis() + '@example.com'
        );
        insert restrictedUser;
        
        System.runAs(restrictedUser) {
            // Create test Account
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;

            Test.startTest();
            try {
                // Simulate access denied to BillingCountry field
                AccountContractController.getAccountContractClauses(testAccount.Id);
                System.assert(false, 'Expected AccessDeniedException for inaccessible BillingCountry field');
            } catch (AccountContractController.AccessDeniedException ex) {
                System.assert(True,ex.getMessage().contains('No access to BillingCountry field on Account'));
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testAccessDeniedExceptionForAccountContractClauseObject() {
        // Create a restricted user
        Profile restrictedProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User restrictedUser = new User(
            Alias = 'testuser',
            Email = 'restricteduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Restricted',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = restrictedProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'restricteduser' + System.currentTimeMillis() + '@example.com'
        );
        insert restrictedUser;
        
        System.runAs(restrictedUser) {
            // Create test Account
            Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'USA');
            insert testAccount;
            
            Test.startTest();
            try {
                // Simulate access denied to Account_Contract_Clause__c object
                AccountContractController.getAccountContractClauses(testAccount.Id);
                System.assert(false, 'Expected AccessDeniedException for inaccessible Account_Contract_Clause__c object');
            } catch (AccountContractController.AccessDeniedException ex) {
                System.assert(ex.getMessage().contains('No access to Account_Contract_Clause__c object'), 'Unexpected exception message');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testAccessDeniedExceptionForCreateAccountContract() {
        // Create a restricted user
        Profile restrictedProfile = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - API Only Integrations' LIMIT 1];
        User restrictedUser = new User(
            Alias = 'testuser',
            Email = 'restricteduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Restricted',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = restrictedProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'restricteduser' + System.currentTimeMillis() + '@example.com'
        );
        insert restrictedUser;
        
        System.runAs(restrictedUser) {
            // Create test Account
            Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'USA');
            insert testAccount;
            
            Test.startTest();
            try {
                // Simulate create access denied for Account_Contract__c object
                AccountContractController.createAccountContractAndLinkClauses(testAccount.Id, new List<Id>());
                System.assert(false, 'Expected AccessDeniedException for inaccessible Account_Contract__c object');
            } catch (AccountContractController.AccessDeniedException ex) {
                System.assert(ex.getMessage().contains('No create access to Account_Contract__c object'), 'Unexpected exception message');
            }
            Test.stopTest();
        }
    }
     @isTest
    static void testFormatNameAndBillingCountry() {
        // Create test data
        String name = 'Test Clause Name Example';
        String billingCountry = 'USA';
        Integer nameColumnWidth = 20;

        // Call the method directly for testing
        String result = AccountContractController.formatNameAndBillingCountry(name, billingCountry, nameColumnWidth);

        // Assertions
        System.assert(result != null, 'The result should not be null');
        System.assert(result.contains('Test Clause Name Example'), 'The formatted result should contain the name');
        System.assert(result.contains('USA'), 'The formatted result should contain the billing country');
        System.assert(result.contains('\n'), 'The formatted result should contain a newline');
    }
    
     @isTest
    static void testPadStringForLongInput() {
        // Create a string longer than the specified length
        String longString = 'This is a very long string';
        Integer length = 10;  // Set the length limit

        // Call the padString method directly to test the substring logic
        String result = AccountContractController.padString(longString, length);

        // Assertions to ensure that the substring logic is working as expected
        System.assertEquals('This is a ', result, 'The string should be truncated to 10 characters');
    }
	    
}