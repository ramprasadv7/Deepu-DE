public with sharing class LightningMessageFactory
{
    public static LightningMessage createMessage(String messageType , String messageBody)
    {
         return new LightningMessage (messageType  , messageBody); 
    }
    
    public static List<LightningMessage > clearMessage()
    {
        return new List<LightningMessage >();
    }
}