public with sharing class AccountHelper {
    
    @AuraEnabled
    public static List<Account> getAccountsByName(String name){
        try {
            String nameWildcards = '%' + name + '%';
            return [ SELECT Id, Name FROM Account WHERE Name LIKE :nameWildcards];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Map<String, String>> getAccountFields(String fields){
        try {
            List<Object> requestedFields = (List<Object>)JSON.deserializeUntyped(fields);
            Map<String, Schema.SObjectField> allFieldsMap = Schema.getGlobalDescribe().get('Account').getDescribe().Fields.getMap();
            List<Map<String, String>> result = new List<Map<String, String>>();

            for (Object keyObj : requestedFields) {
                String key = (String) keyObj;
                if (allFieldsMap.containsKey(key)) {
                    Schema.SObjectField field = allFieldsMap.get(key);
                    Map<String, String> fieldObj = new Map<String, String>();
                    fieldObj.put('label', field.getDescribe().getLabel());
                    fieldObj.put('fieldName', (String) field.getDescribe().getName());
                    result.add(fieldObj);
                }
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
