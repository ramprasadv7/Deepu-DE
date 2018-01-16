global class GoogleApiService{
	public static Boolean fromScheduler = false;
	public static final string GRANT_TYPE='&grant_type=refresh_token';

	webservice static Physician__c getRefreshToken(Id physicianId)
	{
		try
		{
			Physician__c phyToAuthorize = [SELECT Id, Access_Token__c, Access_Token_Last_retrieved__c, Client_Id__c, Client_Secret__c, 
											Refresh_Token__c, Auth_Code__c,Calender_Id__c FROm Physician__c Where Id =: physicianId];

			Http h = new Http();
			string body = 'client_secret='+phyToAuthorize.Client_Secret__c+GRANT_TYPE+'&refresh_token='+phyToAuthorize.Refresh_Token__c+'&client_id='+phyToAuthorize.Client_Id__c;
			HttpRequest req = new HttpRequest();
			req.setEndpoint(URLRedirectController.OAUTH_TOKEN_URL);
			req.setHeader('Content-Type','application/x-www-form-urlencoded');
			req.setMethod('POST');
			req.setBody(body);
			system.debug('REQUEST BODY'+body);
			HttpResponse res; 
			if(!Test.isRunningTest())
				res = h.send(req);
			else
				res = MockHttpResponseGenerator.tokenResponse(req);   
			system.debug('body'+res.getbody());
			system.debug('Response: '+res);

			AccessTokenClass  newToken = (AccessTokenClass) System.JSON.deserialize(res.getBody(), AccessTokenClass.class);
			phyToAuthorize.Access_Token__c = newToken.access_token;
			phyToAuthorize.Access_Token_Last_retrieved__c = Datetime.now();
			if(fromScheduler)
			{
				return phyToAuthorize;
			}
			else
			{
				update phyToAuthorize;
				return null;
			}
		}
		catch(Exception exp)
		{
			EmailHelper.sendEmail(exp.getMessage(), 'Failed to get refresh token', new List<String>{'vishnu@vishnuyadavalli.com'},null);
			return null;
		}
	}

	webservice static void deleteEventFromGoogle(Id eventId)
	{
		try
		{
			Event eventToDelete = [SELECT Id, Google_Id__c, WhatId FROM Event WHERE ID =: eventId];
			Physician__c phy = [Select Id, Calender_Id__c, Access_Token__c, Access_Token_Last_retrieved__c From Physician__c WHERE ID =: eventToDelete.WhatId];
			system.debug(eventToDelete+','+phy);
			Boolean updatePhy = false;
			if(phy.Access_Token_Last_retrieved__c < system.now().addHours(-1))
			{
				fromScheduler = true;
				phy = getRefreshToken(phy.Id);
				updatePhy = true;
			}

			Http h = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+phy.Calender_Id__c+'/events/'+eventToDelete.Google_Id__c);
			req.setHeader('Content-Type','application/x-www-form-urlencoded');
			req.setHeader('Authorization','Bearer '+phy.Access_Token__c);
			req.setMethod('DELETE');
			HttpResponse res;
			if(!Test.isRunningTest())
				res = h.send(req);
			else
				res = MockHttpResponseGenerator.deleteResponse(req);    
			system.debug('body'+res.getbody());
			system.debug('Response: '+res);

			delete eventToDelete;

			if(updatePhy)
				Update phy;
		}
		catch(Exception exp)
		{
			EmailHelper.sendEmail(exp.getMessage(), 'Failed to Delete Event', new List<String>{'vishnu@vishnuyadavalli.com'},null);
		}
	}
}