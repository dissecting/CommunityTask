({
    handleInit : function(component, event) {
        var action = component.get("c.getAssignedContact");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getState());
            if (state === "SUCCESS") {
                component.set("v.accountAndContact", response.getReturnValue());
                component.set("v.fileNameExistList", response.getReturnValue().attachmentNamesList);
                component.set("v.fileIdsExistList", response.getReturnValue().attachmentIdsList);
                component.set("v.isDisabled", true);
                component.set("v.executeBtn", "Update");
            } else if (state === "ERROR") {
                var errors = response.getError();
                component.find('notifLib').showToast({
                    "variant": "error",
                    "header": "Error!",
                    "message": errors[0].message
                });
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    handleInsert: function(component, accountAndContact, fileNameList, contentTypeList, base64DataList, deletedIdsList) {
        var action = component.get("c.createAccountAndContact");
        action.setParams({
            accountAndContact: accountAndContact,
            fileNameList: fileNameList,
            contentTypeList: contentTypeList,
            base64DataList: base64DataList,
            deletedAttachIdsList: deletedIdsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getState());
            if (state === "SUCCESS") {
                component.find("notifLib").showToast({
                    "variant": "success",
                    "header": "Success!",
                    "message": "Record created/updated successfully!"
                });
            } else if (state === "ERROR") {
                var errors = response.getError();
                component.find("notifLib").showToast({
                    "variant": "error",
                    "header": "Error!",
                    "message": errors[0].message
                });
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    handleUpload: function(component, file, base64Data) {
        var fileNames = component.get("v.fileNameList");
        var base64Dates = component.get("v.base64DataList");
        var contentTypes = component.get("v.contentTypeList");
        fileNames.push(file.name);
        base64Dates.push(base64Data);
        contentTypes.push(file.type);
        component.set("v.fileNameList", fileNames);
        component.set("v.base64DataList", base64Dates);
        component.set("v.contentTypeList", contentTypes);
    },

    handleRemove: function(component, indexVar) {
        var fileNames = component.get("v.fileNameList");
        var base64Dates = component.get("v.base64DataList");
        var contentTypes = component.get("v.contentTypeList");
        fileNames.splice(indexVar, 1);
        base64Dates.splice(indexVar, 1);
        contentTypes.splice(indexVar, 1);
        component.set("v.fileNameList", fileNames);
        component.set("v.base64DataList", base64Dates);
        component.set("v.contentTypeList", contentTypes);
    },

    handleDelete: function(component, indexVar) {
        var fileIds = component.get("v.fileIdsExistList");
        var newListIds = fileIds[indexVar];
        var deletedIds = component.get("v.deletedIdsList");
        var fileNames = component.get("v.fileNameExistList");
        deletedIds.push(newListIds);
        fileIds.splice(indexVar, 1);
        fileNames.splice(indexVar, 1);
        component.set("v.fileIdsExistList", fileIds);
        component.set("v.fileNameExistList", fileNames);
        component.set("v.deletedIdsList", deletedIds);
    }
})