public class PermissionSetSwapper {
    public static void swapPermissions() {
        try {
            // Fetch Permission Sets
            Map<String, Id> permSetMap = new Map<String, Id>();
            for (PermissionSet ps : [
                SELECT Id, Name 
                FROM PermissionSet 
                WHERE Name IN ('Basic_Access', 'Advanced_Access')
            ]) {
                permSetMap.put(ps.Name, ps.Id);
            }

            // Fetch Object Permissions
            List<ObjectPermissions> objPerms = [
                SELECT Id, ParentId, SObjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete
                FROM ObjectPermissions
                WHERE ParentId IN :permSetMap.values()
            ];

            // Fetch Field Permissions
            List<FieldPermissions> fieldPerms = [
                SELECT Id, ParentId, SObjectType, Field, PermissionsRead, PermissionsEdit
                FROM FieldPermissions
                WHERE ParentId IN :permSetMap.values()
            ];

            // Create maps to hold the permissions
            Map<String, ObjectPermissions> basicObjPermsMap = new Map<String, ObjectPermissions>();
            Map<String, ObjectPermissions> advancedObjPermsMap = new Map<String, ObjectPermissions>();
            Map<String, FieldPermissions> basicFieldPermsMap = new Map<String, FieldPermissions>();
            Map<String, FieldPermissions> advancedFieldPermsMap = new Map<String, FieldPermissions>();

            // Populate the maps
            for (ObjectPermissions op : objPerms) {
                if (op.ParentId == permSetMap.get('Basic_Access')) {
                    basicObjPermsMap.put(op.SObjectType, op);
                } else if (op.ParentId == permSetMap.get('Advanced_Access')) {
                    advancedObjPermsMap.put(op.SObjectType, op);
                }
            }

            for (FieldPermissions fp : fieldPerms) {
                if (fp.ParentId == permSetMap.get('Basic_Access')) {
                    basicFieldPermsMap.put(fp.SObjectType + '.' + fp.Field, fp);
                } else if (fp.ParentId == permSetMap.get('Advanced_Access')) {
                    advancedFieldPermsMap.put(fp.SObjectType + '.' + fp.Field, fp);
                }
            }

            // Swap Object Permissions
            List<ObjectPermissions> objectPermissionsToUpdate = new List<ObjectPermissions>();

            for (String sObjectType : basicObjPermsMap.keySet()) {
                if (advancedObjPermsMap.containsKey(sObjectType)) {
                    ObjectPermissions basicPerm = basicObjPermsMap.get(sObjectType);
                    ObjectPermissions advancedPerm = advancedObjPermsMap.get(sObjectType);

                    // Swap the permissions
                    Boolean tempCreate = basicPerm.PermissionsCreate;
                    Boolean tempEdit = basicPerm.PermissionsEdit;
                    Boolean tempDelete = basicPerm.PermissionsDelete;

                    basicPerm.PermissionsCreate = advancedPerm.PermissionsCreate;
                    basicPerm.PermissionsEdit = advancedPerm.PermissionsEdit;
                    basicPerm.PermissionsDelete = advancedPerm.PermissionsDelete;

                    advancedPerm.PermissionsCreate = tempCreate;
                    advancedPerm.PermissionsEdit = tempEdit;
                    advancedPerm.PermissionsDelete = tempDelete;

                    objectPermissionsToUpdate.add(basicPerm);
                    objectPermissionsToUpdate.add(advancedPerm);
                }
            }

            if (!objectPermissionsToUpdate.isEmpty()) {
                update objectPermissionsToUpdate;
                System.debug('Object permissions updated: ' + objectPermissionsToUpdate.size());
            }

            // Swap Field Permissions
            List<FieldPermissions> fieldPermissionsToUpdate = new List<FieldPermissions>();

            for (String fieldKey : basicFieldPermsMap.keySet()) {
                if (advancedFieldPermsMap.containsKey(fieldKey)) {
                    FieldPermissions basicPerm = basicFieldPermsMap.get(fieldKey);
                    FieldPermissions advancedPerm = advancedFieldPermsMap.get(fieldKey);

                    // Swap the permissions
                    Boolean tempEdit = basicPerm.PermissionsEdit;

                    basicPerm.PermissionsEdit = advancedPerm.PermissionsEdit;
                    advancedPerm.PermissionsEdit = tempEdit;

                    fieldPermissionsToUpdate.add(basicPerm);
                    fieldPermissionsToUpdate.add(advancedPerm);
                }
            }

            if (!fieldPermissionsToUpdate.isEmpty()) {
                update fieldPermissionsToUpdate;
                System.debug('Field permissions updated: ' + fieldPermissionsToUpdate.size());
            }

            System.debug('Permissions successfully swapped for Basic_Access and Advanced_Access.');
        } catch (Exception e) {
            System.debug('Error while swapping permissions: ' + e.getMessage());
            throw e; // Re-throw the exception to ensure proper error handling
        }
    }

    Public static Boolean isReadOnlyField(String fieldName) {
        try {
            String objectName = fieldName.substringBefore('.');
            String simpleFieldName = fieldName.substringAfter('.');
            Map<String, SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

            if (fieldsMap.containsKey(simpleFieldName)) {
                return !fieldsMap.get(simpleFieldName).getDescribe().isUpdateable();
            }
            return false; // Return false if field not found
        } catch (Exception ex) {
            return false; // Return false if error occurs
        }
    }
}
