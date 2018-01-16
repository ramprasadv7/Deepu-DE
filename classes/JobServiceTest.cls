@isTest
public class JobServiceTest 
{
    public static List<Account> newAccounts = new List<Account>();
    public static List<Cleaner__c> newCleaners = new List<Cleaner__c>();
    public static List<Jobs__c> newJobs = new List<Jobs__c>();
    public static List<Assigned_Cleaner__c> newAssignedCleaners = new List<Assigned_Cleaner__c>();
    public static Integer ACCOUNTSIZE = 5;
    public static Integer JOBSIZE = 2;
    static void setupData()
    {
        //create accounts
        for(Integer i=1; i<=ACCOUNTSIZE; i++)
        {
            Account newAccount = new Account(Name = 'Test Account '+i);
            newAccounts.add(newAccount);
        }
        insert newAccounts;
        
        //create Cleaners
        for(Integer i=1; i<=ACCOUNTSIZE; i++)
        {
            Cleaner__c newCleaner = new Cleaner__c();
            newCleaner.Name = 'Test Cleaner'+i;
            newCleaner.Active__c = true;
            newCleaners.add(newCleaner);
        }
        insert newCleaners;
        
        
        for(Account theAccount : newAccounts)
        {
            for(Integer i=1; i<=JOBSIZE; i++)
            {
                Jobs__c newJob = new Jobs__c();
                newJob.Client__c = theAccount.Id;
                newJob.Job_Type__c = 'Home';
                newJob.Booking_DateTime__c = system.now().addDays(2);
                newJob.Booking_Frequency__c = 'Monthly';
                newJob.Status__c = 'Booked';
                newJobs.add(newJob);
            }
        }
        insert newJobs;
        
        for(Jobs__c theJob : newJobs)
        {
            integer i =1;
            Assigned_Cleaner__c newCleaner = new Assigned_Cleaner__c();
            if(i>ACCOUNTSIZE)
                i=0;
            newCleaner.Cleaner__c = newCleaners[i].Id;
            newCleaner.Job__c = theJob.Id;
			i++;
            newAssignedCleaners.add(newCleaner);
        }
        insert newAssignedCleaners;
    }
    
    static testMethod Void ececuteJobsTest()
    {
        setupData();
        List<Id> jobIds = new List<Id>();
        for(Jobs__c theJob : newJobs)
        {
            theJob.Status__c = 'Executed';
            jobIds.add(theJob.ID);
        }
        
        Test.startTest();
        	update newJobs;
        Test.stopTest();
        
        List<Jobs__c> updatedJobs = [Select ID, Status__c FROm Jobs__c];
        system.assertEquals(JOBSIZE*ACCOUNTSIZE*2, updatedJobs.size(), 'Since jobs are weekly a new set of jobs should be created');
        
        List<Assigned_Cleaner__c> updatesAssignedCleaners = [SELECT Id, Status__c FROM Assigned_Cleaner__c];
        for(Assigned_Cleaner__c theCleaner : updatesAssignedCleaners)	
            system.assertEquals('Executed', theCleaner.Status__c);
    }
    
    static testMethod Void invoiceCreateBatchTest()
    {
        setupData();
        List<Id> jobIds = new List<Id>();
        for(Jobs__c theJob : newJobs)
        {
            theJob.Status__c = 'Executed';
            jobIds.add(theJob.ID);
        }
        update newJobs;
        
        Test.startTest();
        	Database.ExecuteBatch(new GenerateJobInvoicesBatch());
        Test.stopTest();
        
        List<Invoice__c> createdInvoices= [Select ID FROM Invoice__c];
        system.assertEquals(ACCOUNTSIZE,createdInvoices.Size() );
    }

}