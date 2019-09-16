({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    onInsert: function(component, event, helper) {
        var accountAndContact = component.get("v.accountAndContact");
        var fileNameList = component.get("v.fileNameList");
        var contentTypeList = component.get("v.contentTypeList");
        var base64DataList = component.get("v.base64DataList");
        var deletedIdsList = component.get("v.deletedIdsList");
        helper.handleInsert(component, accountAndContact, fileNameList, contentTypeList, base64DataList, deletedIdsList);
    },

    onRemove: function(component, event, helper) {
        var indexVar = event.getSource().get("v.tabindex");
        helper.handleRemove(component, indexVar);
    },

    onDelete: function(component, event, helper) {
        var indexVar = event.getSource().get("v.tabindex");
        helper.handleDelete(component, indexVar);
    },

    onFileUploaded: function(component, event, helper) {
        helper.handleShow(component);
        var files = component.get("v.fileToBeUploaded");
        if (files && files.length > 0) {
            var file = files[0];
            var reader = new FileReader();
            reader.onloadend = function() {
                var dataURL = reader.result;
                var content = dataURL.match(/,(.*)$/)[1];
                helper.handleUpload(component, file, content);
                helper.handleHide(component);
            }
            reader.readAsDataURL(file);
        } else {
            helper.handleHide(component);
        }
    }
})