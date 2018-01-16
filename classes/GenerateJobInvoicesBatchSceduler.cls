global class GenerateJobInvoicesBatchSceduler implements Schedulable {
  
    global void execute(SchedulableContext SC)
    {
        Database.executeBatch(new GenerateJobInvoicesBatch(),100);
    }
    
}