trigger AccountAddressTrigger on Account (before insert) {
    for ( Account a : Trigger.new ) {
        if ( a.BillingPostalCode != NULL && a.Match_Billing_Address__c == true )
            a.shippingPostalCode = a.billingpostalcode;
    }
}