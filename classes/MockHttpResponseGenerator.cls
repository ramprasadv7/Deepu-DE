global class MockHttpResponseGenerator implements HttpCalloutMock {

global static HTTPResponse respond(HTTPRequest req ) {
	HttpResponse res = new HttpResponse();
	String json= '{"access_token" : "access","expires_in" : 3600,"id_token" : "id",  "refresh_token" : "token","token_type" : "Bearer"}';
	res.setHeader('Content-Type', 'application/json');
    res.setBody(json);
    res.setStatusCode(200); 
    res.setStatus('OK'); 
    return res;
}

global static HTTPResponse tokenResponse(HTTPRequest req ) {
	HttpResponse res = new HttpResponse();
	String json= '{"access_token" : "accessToken","expires_in" : 3600,"id_token" : "id","token_type" : "Bearer"}';
	res.setHeader('Content-Type', 'application/json');
    res.setBody(json);
    res.setStatusCode(200); 
    res.setStatus('OK'); 
    return res;
}

global static HTTPResponse deleteResponse(HTTPRequest req ) {
	HttpResponse res = new HttpResponse();
	String json= '{"error": {"errors": [{"domain": "global","reason": "deleted","message": "Resource has been deleted"}],"code": 410,"message": "Resource has been deleted"}}';
	res.setHeader('Content-Type', 'application/json');
    res.setBody(json);
    res.setStatusCode(401); 
    res.setStatus('Gone'); 
    return res;
}

global static HTTPResponse eventResponse(HTTPRequest req ) {
	HttpResponse res = new HttpResponse();
	String json = '{"kind": "calendar#event","etag": "2983899701792000","id": "u7e4cqnnhuegod9ejsob6r61to","status": "confirmed",';
 	json = json + '"htmlLink": "https://www.google.com/calendar/event?eid=dTdlNGNxbm5odWVnb2Q5ZWpzb2I2cjYxdG8gc2FuZGVlcHlhZGF2YWxsaTEyM0Bt",';
 	json = json +'"created": "2017-04-11T22:30:50.000Z","updated": "2017-04-11T22:30:50.896Z","summary": "Your Appointment With yadavalli Vishnu",';
 	json = json +'"creator": {"email": "sandeepyadavalli123@gmail.com", "displayName": "Vishnu Sandeep Yadavalli", "self": true},';
 	json = json +'"organizer": {"email": "sandeepyadavalli123@gmail.com","displayName": "Vishnu Sandeep Yadavalli","self": true},';
 	json = json +'"start": {"dateTime": "2017-04-11T19:00:00-07:00","timeZone": "America/Los_Angeles"},';
 	json = json +'"end": {"dateTime": "2017-04-11T20:00:00-07:00","timeZone": "America/Los_Angeles"},';
 	json = json +'"iCalUID": "u7e4cqnnhuegod9ejsob6r61to@google.com","sequence": 0,"reminders": {"useDefault": true}}';
	res.setHeader('Content-Type', 'application/json');
    res.setBody(json);
    res.setStatusCode(200); 
    res.setStatus('OK'); 
    return res;
}
}