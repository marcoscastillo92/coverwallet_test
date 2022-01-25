trigger ContactTrigger on Contact (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ContactTriggerHandler.assingToUserByAccountPriority(Trigger.new, new Map<Id, Contact>());
        }
        if (Trigger.isUpdate) {
            ContactTriggerHandler.assingToUserByAccountPriority(Trigger.new, Trigger.oldMap);
        }
    }
}