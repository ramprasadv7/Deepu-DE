public class JobService {

    public List<Jobs__c> findExecutedTasks(List<Jobs__c> updatedJobs, Map<Id,Jobs__c> oldJobsMap)
    {
        List<Jobs__c> executedJobs = new List<Jobs__c>();
        List<Jobs__c> jobsToInsert = new List<Jobs__c>();
        for(Jobs__c theJob : updatedJobs)
            if(theJob.Status__c == 'Executed' && oldJobsMap.get(theJob.ID).Status__c != 'Executed')
            {
                executedJobs.add(theJob);
                If(theJob.Booking_Frequency__c != 'One Time')
                {
                    Jobs__c newRecurringJob = new Jobs__c();
                    newRecurringJob.Client__c = theJob.Client__c;
                    newRecurringJob.Job_Type__c = theJob.Job_Type__c;
                    newRecurringJob.Booking_Frequency__c = theJob.Booking_Frequency__c;
                    newRecurringJob.Status__c = 'Booked';
                    Integer frequencyDays = 0;
                    if(theJob.Booking_Frequency__c == 'Weekly')
                        frequencyDays = 7;
                    if(theJob.Booking_Frequency__c == 'Bi-weekly')
                        frequencyDays = 14;
                    if(theJob.Booking_Frequency__c == 'Monthly')
                        frequencyDays = 30;
                    newRecurringJob.Booking_Datetime__c = theJob.Booking_Datetime__c.addDays(frequencyDays);
                    jobsToInsert.add(newRecurringJob);
                }
            }
            	
        try
        {
            system.debug(jobsToInsert);
            Insert jobsToInsert;
        }
        catch(DMLException dmlExp)
        {
            //Do Something
        }
        return executedJobs;
        
    }
    
    public void processExecutedTasks(List<Jobs__c> executedJobs)
    {
        List<Id> jobIds = new List<Id>(new Map<Id, Jobs__c>(executedJobs).keySet());
        List<Assigned_Cleaner__c> assignedCleaners = new List<Assigned_Cleaner__c>();
        if(!jobIds.isEmpty())
            assignedCleaners = [SELECT ID, Revenue__c,Job__c, Job__r.Employee_Revenue__c, Job__r.Number_Of_Cleaners__c  FROM Assigned_Cleaner__c WHERE Job__r.Id In: jobIds];
        
        for(Assigned_Cleaner__c theAssignedCleaner : assignedCleaners)
        {
            theAssignedCleaner.Revenue__c = theAssignedCleaner.Job__r.Employee_Revenue__c/theAssignedCleaner.Job__r.Number_Of_Cleaners__c;
            theAssignedCleaner.Job_Executed_Date__c = system.today();
            theAssignedCleaner.Status__c = 'Executed'; 
        }
        
        try
        {
            Update assignedCleaners;
        }
        Catch(DMLException exp)
        {
            //send email or throw visual error
        }
    }
}