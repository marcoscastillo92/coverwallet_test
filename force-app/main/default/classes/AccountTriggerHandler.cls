public with sharing class AccountTriggerHandler {
    
    public static void assingToUserByPriority(List<Account> newList, Map<Id, Account> oldMap) {
        
        Boolean isInsert = oldMap.size() == 0;
        Map<Id, Account> affectedAccs = new Map<Id, Account>();
        List<User> userList = [ SELECT Id, Name FROM User WHERE Name LIKE 'Agent%' AND Profile.Name = 'Standard Platform User' AND Profile.UserLicense.Name = 'Salesforce Platform' ];
        Map<String, User> userByPriority = new Map<String, User>();
        
        //Sorting users by priority to easy access
        for(User user : userList) {
            if (user.Name.contains('Loo') && !userByPriority.containsKey('Low')) {
                userByPriority.put('Low', user);
            } else if (user.Name.contains('Med') && !userByPriority.containsKey('Medium')) {
                userByPriority.put('Medium', user);
            } else if (user.Name.contains('HIj') && !userByPriority.containsKey('High')) {
                userByPriority.put('High', user);
            }
        }

        if(userByPriority.size() > 0) {

            for (Account acc : newList) {
                // Only new accounts or with AnnualRevenue changed
                if (isInsert || oldMap.get(acc.Id).AnnualRevenue != acc.AnnualRevenue) {
    
                    switch on acc.Priority__c {
                        when 'Low' {
                            acc.OwnerId = userByPriority.get('Low').Id;
                        }
                        when 'Medium' {
                            acc.OwnerId = userByPriority.get('Medium').Id;
                        }
                        when 'High' {
                            acc.OwnerId = userByPriority.get('High').Id;
                        }
                        when else {
                            System.debug('Priority-User correlation not defined -> ' + acc.Priority__c);
                        }
                    }

                    if (!isInsert) {
                        affectedAccs.put(acc.Id, acc);
                    }
                }
            }

            //Only in case of updated accounts
            if (affectedAccs.size() > 0) {
                List<Contact> contactsToUpdate = [ SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId IN :affectedAccs.values() ];

                for (Contact contactObj : contactsToUpdate) {
                    if (affectedAccs.containsKey(contactObj.AccountId)) {
                        contactObj.OwnerId = affectedAccs.get(contactObj.AccountId).OwnerId;
                    }
                }

                if (contactsToUpdate.size() > 0) {
                    update contactsToUpdate;
                }
            }
        }
    }
}
