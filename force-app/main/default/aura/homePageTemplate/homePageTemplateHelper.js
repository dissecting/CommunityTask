({
    handleLogin: function(component, event) {
        let urlEvent = $A.get("e.force:navigateToURL");
        let loginUrl = 'https://' + window.location.hostname + '/mycompany/s/login';
        urlEvent.setParams({
          "url": loginUrl
        });
        urlEvent.fire();
        window.location.reload();
    },
    handleForm: function(component, event) {
        let urlEvent = $A.get("e.force:navigateToURL");
        let formPageUrl = 'https://' + window.location.hostname + '/mycompany/s/formpage';
        urlEvent.setParams({
          "url": formPageUrl
        });
        urlEvent.fire();
    }
})