public class ContactHandler {
    //send receipt as Email to billing account
    public static void afterCreateGenerateReceipt(List<Contact>newConList){
        try{
            Set<Id> accountIdSet= new Set<Id>();
            Map<Id,String> accId2BillingEmailMap = new Map<Id,String>();
            
            //used to generate billing email, pro company one email for each apex transaction,
            //where all user are listed
            Map<Id,List<Contact>> accountId2ContactListMap = new Map<Id,List<Contact>>();
            
            for(Contact con: newConList){
                String conAccId = con.AccountId;
                if(String.isNotBlank(conAccId)){
                    accountIdSet.add(conAccId);
                    if(accountId2ContactListMap.containsKey(conAccId)){
                        List<Contact> currentContactList = accountId2ContactListMap.get(conAccId);
                        currentContactList.add(con);
                    }
                    else{
                        accountId2ContactListMap.put(conAccId, new List<Contact>{con});
                    }
                }
            }
            for(Account acc: [select id from Account where id in:accountIdSet and billing_email__c!=null]){
                accId2BillingEmailMap.put(acc.id, acc.Billing_Email__c);
            }
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.Email> allMails = new List<Messaging.Email>();
            
            for(Id accId : accountId2ContactListMap.keySet()){         
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {accId2BillingEmailMap.get(accId)};
                message.optOutPolicy = 'SEND';
                message.subject = 'Billing for new Subscribers';
                String emailHTMLStr = '<p>you own me bucks for the following new users</p>';
                for(Contact con: accountId2ContactListMap.get(accId)){
                    emailHTMLStr += '<br>Lastname: '+ con.lastname + ' Email: '+con.Email;
                }
                message.htmlBody = emailHTMLStr;
                allMails.add(message);
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail( allMails );            
            
        }
        catch(Exception e){
            system.debug('ex ' +e);
        }

    }
}