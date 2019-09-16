({
    handleInit : function(component) {
        var action = component.get("c.checkCommunityUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getState());
            if (state === "SUCCESS") {
                if (response.getReturnValue()) {
                  component.set("v.onFormBtn", "Update a Form");
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    handleForm: function() {
        var urlEvent = $A.get("e.force:navigateToURL");
        var formPageUrl = "https://" + window.location.hostname + "/mycompany/s/formpage";
        urlEvent.setParams({
          "url": formPageUrl
        });
        urlEvent.fire();
    }
})