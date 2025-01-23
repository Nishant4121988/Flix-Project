@isTest
public class PermissionSetSwapperTest {
    
    // Method to create test Permission Sets and Permissions
    private static void createTestData() {
        // Create two Permission Sets: Basic_Access and Advanced_Access
        PermissionSet basicAccess = new PermissionSet(Name = 'BasicAccess', Label = 'Basic_Access');
        PermissionSet advancedAccess = new PermissionSet(Name = 'AdvancedAccess', Label = 'Advanced_Access');
        insert new List<PermissionSet>{ basicAccess, advancedAccess };
        
        // Create sample ObjectPermissions and FieldPermissions for Basic_Access
        ObjectPermissions basicObjPerm = new ObjectPermissions(
            ParentId = basicAccess.Id,
            SObjectType = 'Account',
            PermissionsCreate = false,
            PermissionsEdit = false,
            PermissionsDelete = false,
            PermissionsRead = true
        );
        
        FieldPermissions basicFieldPerm = new FieldPermissions(
            ParentId = basicAccess.Id,
            SObjectType = 'Account',
            Field = 'Account.Description',
            PermissionsRead = true,
            PermissionsEdit = false
        );
        
        // Create sample ObjectPermissions and FieldPermissions for Advanced_Access
        ObjectPermissions advancedObjPerm = new ObjectPermissions(
            ParentId = advancedAccess.Id,
            SObjectType = 'Account',
            PermissionsCreate = true,
            PermissionsEdit = true,
            PermissionsDelete = true,
            PermissionsRead = true
        );
        
        FieldPermissions advancedFieldPerm = new FieldPermissions(
            ParentId = advancedAccess.Id,
            SObjectType = 'Account',
            Field = 'Account.Description',
            PermissionsRead = true,
            PermissionsEdit = true
        );
        
        insert new List<SObject>{ basicObjPerm, basicFieldPerm, advancedObjPerm, advancedFieldPerm };
    }

    @isTest
    static void testSwapPermissions() {
        // Step 1: Create the test data
        createTestData();
        
        // Step 2: Get the permission set IDs
        PermissionSet basicAccess = [SELECT Id FROM PermissionSet WHERE Name = 'Basic_Access' LIMIT 1];
        PermissionSet advancedAccess = [SELECT Id FROM PermissionSet WHERE Name = 'Advanced_Access' LIMIT 1];
        
        // Step 3: Set up test environment by simulating a PermissionSetSwapper execution
        Test.startTest();
        
        // Execute the swapPermissions method
        PermissionSetSwapper.swapPermissions();
        
        // Step 4: Verify that the permissions were updated
        // Check for Basic_Access
        ObjectPermissions basicObjPerm = [SELECT PermissionsCreate, PermissionsEdit, PermissionsDelete 
                                            FROM ObjectPermissions 
                                            WHERE ParentId = :basicAccess.Id AND SObjectType = 'Account' 
                                            LIMIT 1];
        
        FieldPermissions basicFieldPerm = [SELECT PermissionsRead, PermissionsEdit 
                                             FROM FieldPermissions 
                                             WHERE ParentId = :basicAccess.Id AND Field = 'Account.Description' 
                                             LIMIT 1];
        
        // Assert that the object permissions have been swapped for Basic_Access
        System.assertEquals(basicObjPerm.PermissionsCreate, true, 'PermissionsCreate for Basic_Access should be true');
        System.assertEquals(basicObjPerm.PermissionsEdit, true, 'PermissionsEdit for Basic_Access should be true');
        System.assertEquals(basicObjPerm.PermissionsDelete, true, 'PermissionsDelete for Basic_Access should be true');
        
        // Assert that the field permissions have been swapped for Basic_Access
        System.assert(basicFieldPerm.PermissionsRead, 'PermissionsRead for Basic_Access should remain true');
        System.assertEquals(basicFieldPerm.PermissionsEdit, true, 'PermissionsEdit for Basic_Access should be true');
        
        // Check for Advanced_Access
        ObjectPermissions advancedObjPerm = [SELECT PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete 
                                            FROM ObjectPermissions 
                                            WHERE ParentId = :advancedAccess.Id AND SObjectType = 'Account' 
                                            LIMIT 1];
        
        FieldPermissions advancedFieldPerm = [SELECT PermissionsRead, PermissionsEdit 
                                             FROM FieldPermissions 
                                             WHERE ParentId = :advancedAccess.Id AND Field = 'Account.Description' 
                                             LIMIT 1];
        
        // Assert that the object permissions have been swapped for Advanced_Access
        System.assertEquals(advancedObjPerm.PermissionsCreate, false, 'PermissionsCreate for Advanced_Access should be false');
        System.assertEquals(advancedObjPerm.PermissionsEdit, false, 'PermissionsEdit for Advanced_Access should be false');
        System.assertEquals(advancedObjPerm.PermissionsDelete, false, 'PermissionsDelete for Advanced_Access should be false');
        
        // Assert that the field permissions have been swapped for Advanced_Access
        System.assert(advancedFieldPerm.PermissionsRead, 'PermissionsRead for Advanced_Access should remain true');
        System.assertEquals(advancedFieldPerm.PermissionsEdit, false, 'PermissionsEdit for Advanced_Access should be false');
        
        Test.stopTest();
    }

    @isTest
static void testSwapPermissionsWithInvalidField() {
    // Step 1: Create the test data
    createTestData();
    
    // Step 2: Mock the invalid field scenario
    // Instead of inserting invalid field data, we directly invoke isReadOnlyField with an invalid field
    String invalidField = 'Account.InvalidField'; // Invalid field name
    
    // Call isReadOnlyField to simulate the return false scenario
    Boolean isReadOnly = PermissionSetSwapper.isReadOnlyField(invalidField);
    
    // Assert that the method returns false for an invalid field
    System.assertEquals(isReadOnly, false, 'Expected isReadOnlyField to return false for an invalid field');
    
    // Step 3: Set up test environment by simulating a PermissionSetSwapper execution
    Test.startTest();
    
    // Execute the swapPermissions method
    PermissionSetSwapper.swapPermissions();
    
    Test.stopTest();
}

}