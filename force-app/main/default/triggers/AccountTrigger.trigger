trigger AccountTrigger on Account (before insert, before update) {
    /**
     * Dejamos logica justa y necesaria para que si se amplía el trigger
     * no interfieran las nuevas modificaciones ni lo ya existente entre sí
     */
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.assingToUserByPriority(Trigger.new, new Map<Id, Account>());
        }
        if (Trigger.isUpdate) {
            AccountTriggerHandler.assingToUserByPriority(Trigger.new, Trigger.oldMap);
        }
    }
    
}