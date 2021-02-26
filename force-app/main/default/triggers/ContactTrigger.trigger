trigger ContactTrigger on Contact (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        ContactHandler.afterCreateGenerateReceipt(trigger.new);
    }
}