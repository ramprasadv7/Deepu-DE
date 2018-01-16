@RestResource(urlMapping='/orion/ramsPOC')
// URI TEXT  /services/apexrest/orion/ramsPOC
global class OrionPOC 
{
	@HttpPost
    global static String samplePost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String PostNoteBody = req.requestBody.toString();
        system.debug(PostNoteBody);
        return 'Recived Post Message :'+ PostNoteBody + ' .Thanks for sending a message. You called the POST Method. This is a proof of concept for orion integration.';
    }
    
    @HttpGet
    global static String sampleGet()
    {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String PostNoteBody = req.requestBody.toString();
        system.debug(PostNoteBody);
        return 'Recived Post Message :'+ PostNoteBody+ ' .Thanks for sending a message. You called the GET Method. This is a proof of concept for orion integration.';
    }
}