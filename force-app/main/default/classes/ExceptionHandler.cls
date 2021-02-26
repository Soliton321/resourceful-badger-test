/* 
 * Dependance:  multiple classes using ExceptionHandler.reportExceptionErrMsg(para1,para2)
 *  
*/
public class ExceptionHandler {

    public static void reportExceptionErrMsg(Exception ex, String email){
        String errMsg = '<p>Folgende Apex Exception:</p>';
        errMsg += ' <br> Fehler-Typ: ' + ex.getTypeName();
        errMsg += ' <br> betroffene Stelle: ' + ex.getStackTraceString();        
        errMsg += ' <br> Meldung: ' + ex.getMessage() +' <br><br> ';
        
        sendErrMsgEmail(new List<String>{errMsg},  email);
 
    }
    
    //overload method
    public static void reportExceptionErrMsg(List<Database.SaveResult> srList, String email){
        String OrgName = getOrgName();             
        String userLoginMail = UserInfo.getUserName();        
        List<String> errStrList = new List<String>();

            for(Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()){            
                        errStrList.add('Fehler: ' + err.getMessage() + ' in Feld ' +err.getFields() + ' StatusCode ' + err.getStatusCode()+  '<br><br>');
                    }                
                }
            }              
           sendErrMsgEmail(errStrList, email);         
    }
    
    private static String getOrgName(){
        String OrgName ='';
        if(userInfo.getOrganizationId()==null){
            OrgName = userInfo.getOrganizationId();           
        } 
        else{            
            OrgName = UserInfo.getUserName().substringAfterLast('.').toUpperCase();
        }   
        return OrgName;
    }    
    
    private static void sendErrMsgEmail(List<String> errStrList, String email){
        if(!errStrList.isEmpty()){
            String OrgName = getOrgName();             
            String userLoginMail = UserInfo.getUserName();        
            Messaging.SingleEmailMessage messageReporting = new Messaging.SingleEmailMessage();       

   
                    messageReporting.setToAddresses(new List<String>{email});
                    messageReporting.subject = 'Apex Exception aufgetreten in ' + OrgName ; 
                    String emailBody = '<p>Folgende Fehler ist verursacht durch:' + userLoginMail +'</p>';
                    for(String err: errStrList){
                        emailBody +=  ' <br> ' +err;
                    }                                           
                    messageReporting.htmlBody = emailBody;
                    Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {messageReporting};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);                                      


        }
    }    
    
}