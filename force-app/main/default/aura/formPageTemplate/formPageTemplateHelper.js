({
    handleInit : function(component) {
        var action = component.get("c.getAssignedContact");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getState());
            if (state === "SUCCESS") {
                component.set("v.accountAndContact", response.getReturnValue());
                component.set("v.fileNameExistList", response.getReturnValue().attachmentNamesList);
                component.set("v.fileIdsExistList", response.getReturnValue().attachmentIdsList);
                if (response.getReturnValue().recordId != undefined) {
                    component.set("v.isDisabled", true);
                    component.set("v.executeBtn", "Update");
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                var isVF = component.get("v.isVF");
                if (!isVF) {
                    component.find("notifLib").showToast({
                        "variant": "error",
                        "header": "Error!",
                        "message": errors[0].message
                    });
                } else {
                    component.set("v.isError", true);
                    component.set("v.msg", errors[0].message);
                }
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    handleInsert: function(component, accountAndContact, fileNameList, contentTypeList, base64DataList, deletedIdsList) {
        var action = component.get("c.createAccountAndContact");
        var isVF = component.get("v.isVF");
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
                if (!isVF) {
                    component.find("notifLib").showToast({
                        "variant": "success",
                        "header": "Success!",
                        "message": "Record created/updated successfully!"
                    });
                } else {
                    component.set("v.isConfirm", true);
                    component.set("v.isError", false);
                    component.set("v.msg", errors[0].message);
                }

                window.location.reload(true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (!isVF) {
                    component.find("notifLib").showToast({
                        "variant": "error",
                        "header": "Error!",
                        "message": errors[0].message
                    });
                } else {
                    component.set("v.isConfirm", false);
                    component.set("v.isError", true);
                    component.set("v.msg", errors[0].message);
                }
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
    },

    handleShow: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },

    handleHide: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
    },

    handleCheckInput: function (component, federalTaxIdValue) {
        var federalTaxId = component.get("v.accountAndContact.account.FederalTaxId__c");
        var digitCount = component.get("v.digitCount");
        var isVF = component.get("v.isVF");
        if ((!Number(federalTaxIdValue) && federalTaxIdValue != 0) || federalTaxIdValue.includes(".") || federalTaxIdValue.includes(" ")) {
            if (!isVF) {
                component.find("notifLib").showToast({
                    "variant": "error",
                    "header": "Error!",
                    "message": "Federal Tax Id should be eight-digit!"
                });
            } else {
                component.set("v.isConfirm", false);
                component.set("v.isError", true);
                component.set("v.msg", "Federal Tax Id should be eight-digit!");
            }
            component.set("v.accountAndContact.account.FederalTaxId__c", federalTaxId.substring(0, federalTaxId.length - 1));
            federalTaxId = federalTaxId.substring(0, federalTaxId.length - 1);
        }

        digitCount = federalTaxId.length == 8 ? "" : digitCount;
        digitCount = federalTaxId.length == 7 ? "*" : digitCount;
        digitCount = federalTaxId.length == 6 ? "**" : digitCount;
        digitCount = federalTaxId.length == 5 ? "***" : digitCount;
        digitCount = federalTaxId.length == 4 ? "****" : digitCount;
        digitCount = federalTaxId.length == 3 ? "*****" : digitCount;
        digitCount = federalTaxId.length == 2 ? "******" : digitCount;
        digitCount = federalTaxId.length == 1 ? "*******" : digitCount;
        digitCount = federalTaxId.length < 1 ? "********" : digitCount;
        component.set("v.digitCount", digitCount);
    }
})