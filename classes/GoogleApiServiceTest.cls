@isTest
public class GoogleApiServiceTest{
	public static Specialization__c newSp;
	public static Physician__c newPhy;
	public static Contact newContact;
	public static Event newEvent;
	public static void setupData()
    {
    	newSp = new Specialization__c();
    	newSp.Name = 'TestSp';
    	newSp.Cost__c = 100;
    	insert newSp;

    	newPhy = new Physician__c(Name = 'TestPhy', Client_Secret__c = 'Secret', Client_Id__c = 'Id',
    											Auth_Code__c = 'code', Refresh_Token__c='testToken',Access_Token__c = 'testAccess',
    											Specialization__c = newSp.Id, Calender_Id__c = 'calenderId');
    	insert newPhy;

    	Account newAccount = new Account(Name = 'TestAccount');
    	insert newAccount;

    	newContact = new Contact(FirstName = 'testfName', LastName = 'Testlname', AccountId = newAccount.Id, 
    									Email = 'Test@test.com');
    	insert newContact;

    	newEvent = new Event(whoId = newContact.Id, whatId = newPhy.Id, Google_Id__c = 'testId',StartDateTime = system.now(),
    						EndDateTime = system.now().addHours(2));
    	insert newEvent;


    }

    static testMethod void getTokenURLRedirectTontroller_Test()
    {
    	PageReference pageRef = Page.URLRedirect;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'sffsdfsd124323fsdfsdf/32423wdsf');
        URLRedirectController newController = new URLRedirectController();
        Test.startTest();
        	newController.connect();
        	newController.checkForCode();
        Test.stopTest();
        String bodyPrint = 'Access Token :access'+'\n'+'Refresh Token:token';
        system.assertEquals(newController.bodyprint, bodyprint, 'These should be equal');
    }

    static testMethod void getRefreshToken_Test()
    {
    	setupData();
    	Test.startTest();
    		GoogleApiService.getRefreshToken(newPhy.Id);
    	Test.stopTest();

    	Physician__c updatedPhy = [SELECT ID, Access_Token__c, Access_Token_Last_retrieved__c FROM Physician__c];
    	system.assertEquals(updatedPhy.Access_Token__c, 'accessToken', 'Access token should match from mock http class');

    }

    static testMethod void deleteEvent_Test()
    {
    	setupData();
    	Test.startTest();
    		GoogleApiService.deleteEventFromGoogle(newEvent.Id);
    	Test.stopTest();

    	List<Event> deletedEvent = [SELECT ID FROM Event];
    	system.assertEquals(deletedEvent.size(), 0, 'event should be deleted');

    }

    static testMethod void appointmentSchedulerShowPhy_Test()
    {
    	setupData();
    	PageReference pageRef = Page.Appointment_Scheduler;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', newContact.Id);
        AppointmentSchedulerController theController = new AppointmentSchedulerController();
        pageRef.getParameters().put('spId', newSp.Id);
        pageRef.getParameters().put('spName', newSp.Name);
        theController.selectedPhysicianId = newPhy.Id;

        Test.startTest();
        	theController.showPhysicians();
        	theController.updateCalender();
        Test.stopTest();
        system.debug(theController.phyOptions);
        system.assertEquals(theController.phyOptions[1].getValue(), newPhy.Id);
    }

    static testMethod void appointmentScheduler_Test()
    {
    	setupData();
    	PageReference pageRef = Page.Appointment_Scheduler;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', newContact.Id);
        AppointmentSchedulerController theController = new AppointmentSchedulerController();
        pageRef.getParameters().put('startTime', '2017-04-28T09:00');
        pageRef.getParameters().put('endTime', '2017-04-28T10:00');
        theController.selectedPhysicianId = newPhy.Id;
        theController.showPhysicians();
        theController.selectedPhysician = newPhy;

        Test.startTest();
        	theController.scheduleEvent();
        Test.stopTest();
        List<Event> deletedEvent = [SELECT ID FROM Event];
    	system.assertEquals(deletedEvent.size(), 2, 'new event should be created');
    }
}