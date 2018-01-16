public class AppointmentSchedulerController
{
	public List<Specialization__c> specializations {get;set;}
	public List<Physician__c> physicians {get;set;}
	public String selectedPhysicianId{get;set;}
	public Physician__c selectedPhysician{get;set;}
	public List<SelectOption> phyOptions{get;set;}
	public String calenderId{get;set;}
	public Contact contactForAppointment{get;set;}
	public Event newEvent{get;set;}
	public String selectedSp;
	public String appointmentCost{get;set;}
	public List<LightningMessage > pageMessages{get;set;}

	public AppointmentSchedulerController()
	{
		pageMessages = new List<LightningMessage >();
		newEvent = new Event();
		String contactId = Apexpages.currentPage().getParameters().get('id');
		specializations = [SELECT Id, Name, Cost__c FROM Specialization__c];
		if(contactId != null)
			contactForAppointment = [SELECT Id, Name FROM Contact WHERE Id =: contactId];
	}

	public pageReference showPhysicians()
	{
		pageMessages = new List<LightningMessage >();
		String spId = Apexpages.currentPage().getParameters().get('spId');
		selectedSp = Apexpages.currentPage().getParameters().get('spName');
		appointmentCost = Apexpages.currentPage().getParameters().get('spCost');
		system.debug(spId);
		system.debug(appointmentCost);
		physicians = [Select Id, Name, Calender_Id__c,Access_Token__c, Access_Token_Last_retrieved__c FROM Physician__c Where Specialization__c =: spId];
		phyOptions = new List<SelectOption>();
		phyOptions.add(new SelectOption('--none--','--None--'));
		for(Physician__c thePhy : physicians)
		{
			phyOptions.add(new SelectOption(thePhy.Id, thePhy.Name));				
		}
		return null;
	}

	public pageReference updateCalender()
	{
		system.debug(selectedPhysicianId);
		for(Physician__c thePhy : physicians)
		{
			if(thePhy.Id == selectedPhysicianId)
			{
				calenderId = thePhy.Calender_Id__c;
				selectedPhysician = thePhy;
			}
		}
		return null;
	}

	public pageReference scheduleEvent()
	{
		system.debug(appointmentCost);
		pageMessages = new List<LightningMessage >();
		try
		{
		String startTime = Apexpages.currentPage().getParameters().get('startTime');
		String endTime = Apexpages.currentPage().getParameters().get('endTime');
		newEvent.StartDateTime = Datetime.valueOf((startTime+':00').replace('T',' '));
		newEvent.EndDateTime = Datetime.valueOf((endTime+':00').replace('T',' '));
		if(newEvent.StartDateTime <= system.now())
		{
			pageMessages.add(LightningMessageFactory.createMessage('error' , 'Start Time shold be greater than current time'));
			return null; 
		}
		newEvent.Subject = 'Your Appointment With '+contactForAppointment.Name;
		newEvent.WhatId = selectedPhysicianId;
		newEvent.WhoId = contactForAppointment.Id;
		newEvent.Google_Calender_Id__c = selectedPhysician.Calender_Id__c;
		String description = 'Contact Name:'+contactForAppointment.Name+'\n';
		description = description + 'Start :'+(newEvent.StartDateTime).format('MM/dd/yyyy HH:mm:ss','America/Los_Angeles')+'\n';
		description = description + 'End :'+(newEvent.EndDateTime).format('MM/dd/yyyy HH:mm:ss','America/Los_Angeles')+'\n';
		description = description + 'Department :'+selectedSp+'\n';
		newEvent.Description = description;
		Boolean updatePhy = false;
		system.debug(newEvent);
		/* since i am using the same calender id i will be refresing everytime i make a call*/
			GoogleApiService.fromScheduler = true;
			selectedPhysician = GoogleApiService.getRefreshToken(selectedPhysicianId);
			updatePhy = true;
		// if using different ids refresh only once very hour
		if(selectedPhysician.Access_Token_Last_retrieved__c < system.now().addHours(-1))
		{
			GoogleApiService.fromScheduler = true;
			selectedPhysician = GoogleApiService.getRefreshToken(selectedPhysicianId);
			updatePhy = true;
		}

		Http eventHttp = new Http();
	    String eventbody = '{"start": {"dateTime": "'+startTime+':00-07:00'+'","timeZone": "America/Los_Angeles"},"end": {"dateTime": "'+endTime+':00-07:00'+'","timeZone": "America/Los_Angeles"}';
	    eventbody = eventbody + ',"summary": "'+newEvent.Subject+'"}';
	    HttpRequest eventReq = new HttpRequest();
	    eventReq.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+selectedPhysician.Calender_Id__c+'/events');
	    eventReq.setHeader('Content-Type','application/json');
	    eventReq.setHeader('Authorization','Bearer '+selectedPhysician.Access_Token__c);
	    eventReq.setMethod('POST');
	    eventReq.setBody(eventbody);
	    system.debug('REQUEST BODY'+eventbody);
	    HttpResponse eventRes;
	    if(!Test.isRunningTest())
	    	eventRes = eventHttp.send(eventReq); 
	    else
			eventRes = MockHttpResponseGenerator.eventResponse(eventReq); 
	    system.debug(selectedPhysician.Access_Token__c); 
	    system.debug('body'+eventRes.getbody());
	    system.debug('Response: '+eventRes);
	    EventResponse newRes = (EventResponse) System.JSON.deserialize(eventRes.getBody(), EventResponse.class);
	    newEvent.Google_Id__c = newRes.Id;

	    insert newEvent;
	    if(updatePhy)
	    	update selectedPhysician;
	    }
	    catch(DMLException dmlExp)
	    {
	    	pageMessages.add(LightningMessageFactory.createMessage('error' , 'Error scheduling apppointment. '+dmlExp)); 
	    }
	    catch(Exception exp)
	    {
	    	pageMessages.add(LightningMessageFactory.createMessage('error' , 'Error scheduling apppointment. '+exp)); 
	    }
	    system.debug(pageMessages);
		return null;
	}

}