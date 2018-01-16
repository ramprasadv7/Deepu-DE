public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    @future(callout=true)
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    public static void runWarehouseEquipmentSync(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        String ret = '';
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            system.debug( JSON.deserializeUntyped(response.getBody()));
            List<EquipmentWrapperFromJSON > results = ( List<EquipmentWrapperFromJSON >) JSON.deserialize(response.getBody(), List<EquipmentWrapperFromJSON >.class);
            system.debug(results);

            List<Product2> LstProduct = new List<Product2>();
            for(EquipmentWrapperFromJSON mapobj : results)
            { 

                Product2 product = new Product2();
                product.Name  = mapobj.equipment[0].Name; 
                product.Maintenance_Cycle__c = Integer.valueof(mapobj.equipment[0].maintenanceperiod);
                product.Cost__c = Decimal.valueOf(mapobj.equipment[0].Cost);
                product.Current_Inventory__c = Decimal.valueOf(mapobj.equipment[0].quantity);
                product.Lifespan_Months__c = Decimal.valueOf(mapobj.equipment[0].Lifespan); 
                product.Replacement_Part__c = boolean.valueOf(mapobj.equipment[0].replacement);
                product.Warehouse_SKU__c = mapobj.equipment[0].sku;
                product.ProductCode = mapobj.equipment[0].id;    
                LstProduct.add(product);
            }
            System.debug(LstProduct);
            upsert LstProduct;

        }
    }
}