public with sharing class ContactTriggerHandler {
    
    public static void assingToUserByAccountPriority(List<Contact> newList, Map<Id, Contact> oldMap) {
        Boolean isInsert = oldMap.size() == 0;
        Set<Id> accountSet = new Set<Id>();
        List<Contact> contactList = new List<Contact>();

        for (Contact contactObj : newList) {
            // Only new contacts or with Account changed
            if ((isInsert || oldMap.get(contactObj.Id).AccountId != contactObj.AccountId) && contactObj.AccountId != null) {
                accountSet.add(contactObj.AccountId);
                contactList.add(contactObj);
            }
        }

        if (accountSet.size() > 0) {
            Map<Id, Account> accountsById = new Map<Id, Account>([ SELECT Id, OwnerId FROM Account WHERE Id IN :accountSet ]);

            for (Contact contactObj : contactList) {
                contactObj.OwnerId = accountsById.get(contactObj.AccountId).OwnerId;
            }
        }
    }
}
