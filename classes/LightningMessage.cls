public with sharing class LightningMessage 
    {
        
        public String msgType{get;set;}
        public String message{get;set;}
        public Boolean hasMessage{get;set;}
        public LightningMessage (){}
        public LightningMessage (String theMsgType , String theMessage) 
        {
            msgType = theMsgType;
            message = theMessage;
            hasMessage = true;
        }
    }