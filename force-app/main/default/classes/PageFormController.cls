public without sharing class PageFormController {

    @AuraEnabled
    public static Id createAccountAndContact(ContactWithAccount accountAndContact,
                                            List<String> fileNameList,
                                            List<String> base64DataList,
                                            List<String> contentTypeList,
                                            List<Id> deletedAttachIdsList) {
        Id recordId;
        Id accountId;
        Boolean isNotEmpty = !fileNameList.isEmpty()
            && !base64DataList.isEmpty()
            && !contentTypeList.isEmpty();

        if (accountAndContact == null || checkMissedFields(accountAndContact)) {
            throw new AuraHandledException(label.errMsgFieldsMustBeFilled);
        }
        if (checkIncorrectAssign(accountAndContact)) {
            throw new AuraHandledException(label.errMsgContactsIncorrectAssign);
        }

        try {
            if (getUserId() != null) {
                accountId = upsertAccount(accountAndContact, getUserId());
                if (!checkDuplicateContact(accountAndContact).isEmpty()) {
                    recordId = updateContact(accountAndContact, checkDuplicateContact(accountAndContact));
                    deleteAttachment(deletedAttachIdsList);
                } else {
                    recordId = insertContact(accountAndContact, accountId, getUserId());
                }
                if (recordId != null && checkUserType()) {
                    createNewCummunityUser(accountAndContact, recordId);
                }
                if (isNotEmpty) {
                    createAttachment(fileNameList, base64DataList, contentTypeList, recordId);
                }
            }
        } catch (DMLException e){
            throw new AuraHandledException(e.getDMLMessage(0));
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return recordId;
    }

    private static Id upsertAccount(ContactWithAccount accountAndContact, Id ownerId) {
        Account newAccount = new Account(
            Name = accountAndContact.account.Name,
            FederalTaxId__c = accountAndContact.account.FederalTaxId__c,
            OwnerId = ownerId
        );
        upsert newAccount FederalTaxId__c;

        return newAccount.Id;
    }

    private static Boolean checkMissedFields(ContactWithAccount accountAndContact) {
        Boolean isBlank = String.isBlank(accountAndContact.contact.FirstName)
            || String.isBlank(accountAndContact.contact.LastName)
            || String.isBlank(accountAndContact.contact.Email__c)
            || String.isBlank(accountAndContact.account.FederalTaxId__c)
            || String.isBlank(accountAndContact.account.Name);

        return isBlank;
    }

    private static Boolean checkIncorrectAssign(ContactWithAccount accountAndContact) {
        Boolean isError = false;
        String email = accountAndContact.contact.Email__c;
        List<Contact> listOfContacts = [
            SELECT Email__c, Account.FederalTaxId__c
            FROM Contact
            WHERE Email__c = :email
                AND Account.FederalTaxId__c != :accountAndContact.account.FederalTaxId__c
        ];
        if (!listOfContacts.isEmpty()) {
            isError = true;
        }

        return isError;
    }

    private static Id insertContact(ContactWithAccount accountAndContact, Id accountId, Id ownerId) {
        Contact newContact = new Contact(
            FirstName = accountAndContact.contact.FirstName,
            LastName = accountAndContact.contact.LastName,
            Email__c = accountAndContact.contact.Email__c,
            AccountId = accountId,
            OwnerId = checkUserType() ? ownerId: accountAndContact.contact.OwnerId
        );
        insert newContact;

        return newContact.Id;
    }

    private static Id getUserId() {
        List<User> userList = [
            SELECT UserRoleId
            FROM User
            WHERE UserRoleId != null
        ];

        return userList[0].Id;
    }

    private static Id updateContact(ContactWithAccount accountAndContact, List<Contact> contactList) {
        for (Contact cont : contactList) {
            cont.FirstName = accountAndContact.contact.FirstName;
            cont.LastName = accountAndContact.contact.LastName;
            cont.Email__c = accountAndContact.contact.Email__c;
            cont.Account.FederalTaxId__c = accountAndContact.account.FederalTaxId__c;
        }
        update contactList;

        return contactList[0].Id;
    }

    private static List<Contact> checkDuplicateContact(ContactWithAccount accountAndContact) {
        String email = accountAndContact.contact.Email__c;
        List<Contact> contactList = [
            SELECT Email__c, Account.FederalTaxId__c
            FROM Contact
            WHERE Email__c = :email
                AND Account.FederalTaxId__c = :accountAndContact.account.FederalTaxId__c
        ];

        return contactList;
    }

    private static void createNewCummunityUser(ContactWithAccount accountAndContact, Id recordId) {
        List<Profile> profileList = [
            SELECT UserLicense.Name
            FROM Profile
            WHERE UserLicense.Name = 'Customer Community Login'
        ];
        List<Organization> orgList = [
        	SELECT LanguageLocaleKey, TimeZoneSidKey, DefaultLocaleSidKey
            FROM Organization
        ];
        String nickName = accountAndContact.contact.Email__c.substring(0, accountAndContact.contact.Email__c.indexOf('@'));
        String aliasName = accountAndContact.contact.FirstName;

        aliasName = aliasName.left(1);
        aliasName += accountAndContact.contact.LastName;
        aliasName = aliasName.left(8);
        nickName += Datetime.now().getTime();
        User newUser = new User (
            Alias = aliasName,
            Email = accountAndContact.contact.Email__c,
            Emailencodingkey = 'UTF-8',
            Firstname = accountAndContact.contact.FirstName,
            Lastname = accountAndContact.contact.LastName,
            Languagelocalekey = orgList[0].LanguageLocaleKey,
            Localesidkey = orgList[0].DefaultLocaleSidKey,
            ContactId = recordId,
            Timezonesidkey = orgList[0].TimeZoneSidKey,
            Username = accountAndContact.contact.Email__c.right(70) + '.' + aliasName,
            CommunityNickname = nickName,
            ProfileId = profileList[0].Id,
            IsActive = true
        );
        insert newUser;
    }

    private static Boolean checkUserType() {
        String userType = UserInfo.getUserType();
        Boolean isGuest = userType == 'Guest';

        return isGuest;
    }

    @AuraEnabled
    public static ContactWithAccount getAssignedContact() {
        ContactWithAccount contactWithAccount = new ContactWithAccount();

        if (!checkUserType()) {
            List<User> userList = [
                SELECT UserName, ContactId
                FROM User
                WHERE UserName = :UserInfo.getUsername()
            ];
            List<Contact> contactList = [
                SELECT FirstName, LastName, Email__c, AccountId
                FROM Contact
                WHERE Id = :userList[0].ContactId
            ];
            List<Account> accountList = [
                SELECT Name, FederalTaxId__c
                FROM Account
                WHERE Id = :contactList[0].AccountId
            ];
            List<Attachment> listOfAttachments = [
                SELECT Name, ParentId
                FROM Attachment
                WHERE ParentId = :contactList[0].Id
            ];

            for (Attachment currentAttachment : listOfAttachments) {
                contactWithAccount.attachmentIdsList.add(currentAttachment.Id);
                contactWithAccount.attachmentNamesList.add(currentAttachment.Name);
            }

            contactWithAccount.contact = contactList[0];
            contactWithAccount.account = accountList[0];
            contactWithAccount.recordId = contactList[0].Id;
        }

        return contactWithAccount;
    }

    @AuraEnabled
    public static Boolean checkCommunityUser() {
        String userType = UserInfo.getUserType();
        Boolean isCommunityUser = userType == 'CspLitePortal';

        return isCommunityUser;
    }

    private static void createAttachment (List<String> fileNameList, List<String> base64DataList, List<String> contentTypeList, Id recordId) {
        List<String> newDataList = new List<String>();
        for (String base64Data : base64DataList) {
            newDataList.add(EncodingUtil.urlDecode(base64Data, 'UTF-8'));
        }
        List<Attachment> attachmentList = new List<Attachment>();
        for (Integer i = 0; i < fileNameList.size(); i++) {
            Attachment currentAttachment = new Attachment();
            currentAttachment.Body = EncodingUtil.base64Decode(newDataList[i]);
            currentAttachment.Name = fileNameList[i];
            currentAttachment.parentId = recordId;
            currentAttachment.ContentType = contentTypeList[i];
            attachmentList.add(currentAttachment);
        }

        insert attachmentList;
    }

    private static void deleteAttachment (List<Id> deletedAttachIdsList) {
        List<Attachment> attachmentList = [
            SELECT Id
            FROM Attachment
            WHERE Id IN :deletedAttachIdsList
        ];

        delete attachmentList;
    }

    public class ContactWithAccount {

        @AuraEnabled
        public Account account { get; set; }
        @AuraEnabled
        public Contact contact { get; set; }
        @AuraEnabled
        public Id recordId { get; set; }
        @AuraEnabled
        public List<Id> attachmentIdsList { get; set; }
        @AuraEnabled
        public List<Id> deletedAttachIdsList { get; set; }
        @AuraEnabled
        public List<String> attachmentNamesList  { get; set; }

        public ContactWithAccount() {
            attachmentIdsList = new List<Id>();
            attachmentNamesList = new List<String>();
            deletedAttachIdsList = new List<String>();
        }
    }
}