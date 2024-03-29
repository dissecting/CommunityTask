({
    handleInit : function(component) {
        var action = component.get("c.checkCommunityUser");
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                if (response.getReturnValue()) {
                  component.set("v.onFormBtn", $A.get("$Label.c.updateFormLabel"));
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
        var formPageUrl = window.location.hostname + $A.get("$Label.c.formPageUrl");
        urlEvent.setParams({
          "url": formPageUrl
        });
        urlEvent.fire();
    }
})