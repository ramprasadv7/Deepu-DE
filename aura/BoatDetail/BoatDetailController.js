({
	onFullDetails : function (component, event, helper) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": v.Id,
      });
    navEvt.fire();
}
})