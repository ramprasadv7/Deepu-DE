global class GenerateJobInvoicesBatch implements Database.Batchable<sObject>
{
    String query;
    Date sysDate = System.Today();
	global GenerateJobInvoicesBatch()
    {
        Date queryMinDate;
        Date queryMaxDate = sysDate.addDays(-1);
        if(Test.isRunningTest())
        {
            queryMinDate = sysDate.addDays(-1);
            queryMaxDate = sysDate.addDays(1);
        }
        else if(sysDate.day() == 1)
        {
            queryMinDate = Date.newInstance(sysDate.year(),sysDate.Month()-1 , 15);
        }
        else If(sysDate.day() == 15)
        {
            queryMinDate = Date.newInstance(sysDate.Year(),sysDate.month(), 1);
        }
       
            
        query = 'SELECT ID, (SELECT ID, Job_Executed_Date__c, Revenue__c, Cleaner__c FROM Assigned_Cleaners__r';
        query = query + ' WHERE Job_Executed_Date__c >= '+String.ValueOf(queryMinDate)+' AND Job_Executed_Date__c <= '+String.ValueOf(queryMaxDate);
        query = query + ' AND Status__c = \'Executed\'),';
        query = query + 'Amount_Due__c FROM Cleaner__c';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Cleaner__C> scope)
    {
        List<Assigned_Cleaner__c> cleanersToupdate = new List<Assigned_Cleaner__c>();
        List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
        
        for(Cleaner__c theCleaner : scope)
        {
            Decimal amountDue = 0;
            for(Assigned_Cleaner__c theAssignedCleaner : theCleaner.Assigned_Cleaners__r)
            {
                amountDue = amountDue + theAssignedCleaner.Revenue__c;
                theAssignedCleaner.Status__c = 'Created';
            }
            Invoice__c newInvoice  = new Invoice__c();
            newInvoice.Cleaner__c = theCleaner.Id;
            newInvoice.Invoice_Amount__c = amountDue;
            newInvoice.Invoice_Date__c = system.Today();
            newInvoice.Status__c = 'Created';
            invoicesToInsert.add(newInvoice);
        }
        
        try
        {
            insert invoicesToInsert;
            update cleanersToUpdate;
        }
        catch(DMLException exp)
        {
            //do something
        }
    }
     global void finish(Database.BatchableContext BC) 
    {        
    }
}