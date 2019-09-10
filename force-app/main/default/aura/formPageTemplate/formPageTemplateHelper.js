({
    handleInit : function(component, event) {
        let action = component.get("c.getAssignedContact");
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log(response.getState());
            if (state === "SUCCESS") {
                component.set("v.contact", response.getReturnValue().contact);
                component.set("v.account", response.getReturnValue().account);
                component.set("v.recordId", response.getReturnValue().recordId);
                component.set("v.fileIds", response.getReturnValue().attachIds);
                console.log(response.getReturnValue().attachIds);
                if (response.getReturnValue().recordId != undefined) {
                    component.set("v.isDisabled", true);
                    component.set("v.executeBtn", "Update");
                }
                component.set("v.isError", false);
                component.set("v.isConfirm", false);
            } else if (state === "ERROR") {
                let errors = response.getError();
                component.set("v.isConfirm", false);
                component.set("v.isError", false);
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    handleInsert: function(component, account, contact) {
        let action = component.get("c.createAccountAndContact");
        action.setParams({
            account: account,
            contact: contact
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log(response.getState());
            if (state === "SUCCESS") {
                component.set("v.recordId", response.getReturnValue());
                component.set("v.msg", 'Record created/updated successfully!');
                component.set("v.isError", false);
                component.set("v.isConfirm", true);
            } else if (state === "ERROR") {
                let errors = response.getError();
                component.set("v.msg", errors[0].message);
                component.set("v.isConfirm", false);
                component.set("v.isError", true);
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    handleLogout: function(component, event) {
        let urlEvent = $A.get("e.force:navigateToURL");
        let logoutUrl = 'https://' + window.location.hostname + '/mycompany/secur/logout.jsp';
        urlEvent.setParams({
          "url": logoutUrl
        });
        urlEvent.fire();
    }
})