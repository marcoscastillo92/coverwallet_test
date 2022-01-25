@RestResource(urlMapping='/Account/Sync')
global with sharing class AccountSync {
    
    @HttpPost
    global static void doPost() {
        Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());

        Map<String, Account> accountsByUUID = new Map<String, Account>();
        Map<String, Account> accountsMap = new Map<String, Account>();
        // Map<String, List<String>> uuidByContactEmail = new Map<String, List<String>>();
        Map<String, String> uuidByContactEmail = new Map<String, String>();
        Map<String, List<Contact>> contactsByAccUUID = new Map<String, List<Contact>>();
        Map<String, Contact> contactsByEmail = new Map<String, Contact>();
        List<Account> accountsToCreate = new List<Account>();
        List<Account> accountsToUpdate = new List<Account>();
        List<Contact> contactsToCreate = new List<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();

        if (requestBody.containsKey('accounts') && ( (List<Object>) requestBody.get('accounts')).size() > 0) {

            for (Object accBody : (List<Object>)requestBody.get('accounts')) {
                Map<String, Object> accInfo = (Map<String, Object>) accBody;
                String uuid = (String) accInfo.get('uuid');
                
                accountsMap.put(uuid, new Account(Name = (String) accInfo.get('company_name'), AnnualRevenue = (Decimal) accInfo.get('annual_revenue'), NumberEmployees__c = (Decimal) accInfo.get('number_employees'), uuid__c = uuid));
                
                List<Object> contactsBody = (List<Object>) accInfo.get('contacts');

                for (Object contactBody : contactsBody) {
                    Map<String, Object> contactInfo = (Map<String, Object>) contactBody;
                    Contact contactObj = new Contact(FirstName = (String) contactInfo.get('first_name'), LastName = (String) contactInfo.get('last_name'), Email = (String) contactInfo.get('email'));
                    
                    if (contactsByAccUUID.containsKey(uuid)) {
                        contactsByAccUUID.get(uuid).add(contactObj);
                    } else {
                        contactsByAccUUID.put(uuid, new List<Contact>{ contactObj });
                    }

                    // if (uuidByContactEmail.containsKey(contactObj.Email)) {
                    //     uuidByContactEmail.get(contactObj.Email).add(uuid);
                    // } else {
                    //     uuidByContactEmail.put(contactObj.Email, new List<String>{ uuid });
                    // }
                    uuidByContactEmail.put(contactObj.Email, uuid);
                }
            }

            if (accountsMap.size() > 0) {
                List<Account> accList = [ SELECT Id, uuid__c, AnnualRevenue, NumberEmployees__c, Name FROM Account WHERE uuid__c IN :accountsMap.keySet() ];
                List<Contact> allContacts = [ SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE Email IN :uuidByContactEmail.keySet() ];

                for (Account acc : accList) {
                    accountsByUUID.put(acc.uuid__c, acc);
                }

                for (Contact contObj : allContacts) {
                    contactsByEmail.put(contObj.Email, contObj);
                }

                for (Account acc : accountsMap.values()) {
                    if (accountsByUUID.containsKey(acc.uuid__c)) {
                        acc.Id = accountsByUUID.get(acc.uuid__c).Id;
                        accountsToUpdate.add(acc);
                    } else {
                        accountsToCreate.add(acc);
                    }

                    for (Contact contObj : contactsByAccUUID.get(acc.uuid__c)) {
                        if (contactsByEmail.containsKey(contObj.Email)) {
                            contObj.Id = contactsByEmail.get(contObj.Email).Id;
                            contactsToUpdate.add(contObj);
                        } else {
                            contactsToCreate.add(contObj);
                        }
                    }
                }

                //Insert and update each list if needed
                if (accountsToCreate.size() > 0) {
                    insert accountsToCreate;

                    //Add Id to each Account by uuid
                    for (Account acc : accountsToCreate) {
                        if (accountsByUUID.containsKey(acc.uuid__c)) {
                            accountsByUUID.get(acc.uuid__c).Id = acc.Id;
                        }
                    }
                }

                if (accountsToUpdate.size() > 0) {
                    update accountsToUpdate;
                }

                //Assign Account Id to each contact
                for (Contact contObj : contactsToCreate) {
                    if (uuidByContactEmail.containsKey(contObj.Email)) {
                        contObj.AccountId = accountsByUUID.get(uuidByContactEmail.get(contObj.Email)).Id;
                    }
                }

                for (Contact contObj : contactsToUpdate) {
                    if (uuidByContactEmail.containsKey(contObj.Email)) {
                        contObj.AccountId = accountsByUUID.get(uuidByContactEmail.get(contObj.Email)).Id;
                    }
                }

                if (contactsToCreate.size() > 0) {
                    insert contactsToCreate;
                }

                if (contactsToUpdate.size() > 0) {
                    update contactsToUpdate;
                }
            }
        }
    }
}
