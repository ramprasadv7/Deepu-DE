public class EmailHelper
{
    public static void sendEmail(string body, String subject, List<String> toEmails, List<String> toCCEmails)
        {
            system.debug(body);
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            String[] toAddresses = toEmails;
            String[] toCcAddresses = toCCEmails; 
            mail.setToAddresses(toAddresses);
            mail.setCCAddresses(toccAddresses);
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    
        }
 }