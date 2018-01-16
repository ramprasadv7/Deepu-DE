@isTest
private class WarehouseCalloutServiceTest {
  // implement your mock callout test here
    testMethod Static void test(){
        List<EquipmentWrapperFromJSON> ListEWFS = new List<EquipmentWrapperFromJSON>();
        List<Product2> listProduct = new List<Product2>();
        Product2 p = new Product2();
        p.Replacement_Part__c = true;
        p.Name = 'testing';
        p.Cost__c = 10;
        p.Current_Inventory__c = 5;
        p.Lifespan_Months__c = 2;
        p.Maintenance_Cycle__c = 60;
        p.Warehouse_SKU__c = '10001';
        listProduct.add(p);

        insert listProduct;

        test.startTest();
            //ListEWFS = WarehouseCalloutService.wrapWquipment();
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            WarehouseCalloutService.runWarehouseEquipmentSync();
        test.stopTest();
        Upsert listProduct;
    }
    
    testmethod static void testMaintenenceTrigger()
    {
        case theCase = new Case();
        theCase.Type = 'Repair';
        insert theCase;
        
        theCase.Status = 'Closed';        
        update theCase;
    }
    
    testMethod Static void tesScedulet(){
        List<EquipmentWrapperFromJSON> ListEWFS = new List<EquipmentWrapperFromJSON>();
        List<Product2> listProduct = new List<Product2>();
        Product2 p = new Product2();
        p.Replacement_Part__c = true;
        p.Name = 'testing';
        p.Cost__c = 10;
        p.Current_Inventory__c = 5;
        p.Lifespan_Months__c = 2;
        p.Maintenance_Cycle__c = 60;
        p.Warehouse_SKU__c = '10001';
        listProduct.add(p);

        insert listProduct;

        test.startTest();
            //ListEWFS = WarehouseCalloutService.wrapWquipment();
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            System.schedule('ScheduleApexClassTest', CRON_EXP, new  WarehouseSyncSchedule());
        test.stopTest();
        Upsert listProduct;
    }
}