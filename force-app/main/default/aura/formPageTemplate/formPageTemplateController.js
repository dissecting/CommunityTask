({
    doInit : function(component, event, helper) {
        helper.handleInit(component, event, helper);
    },
    onInsert: function(component, event, helper) {
        let account = component.get("v.account");
        let contact = component.get("v.contact");
        helper.handleInsert(component, account, contact);
    },
    onLogout: function(component, event, helper) {
        helper.handleLogout(component, event, helper);
    }
})