public class PageFormController {
    @AuraEnabled
    public static Id createAccountAndContact(Account account, Contact contact) {
        Id recordId;
        if (checkMissedFields(account, contact)) {
            throw new AuraHandledException(label.errMsgFieldsMustBeFilled);
        }
        if (checkIncorrectAssign(account, contact)) {
            throw new AuraHandledException(label.errMsgContactsIncorrectAssign);
        }
        try {
            upsertAccount(account);
            if (checkDuplicateContact(account, contact).size() == 1) {
                recordId = updateContact(account, contact, checkDuplicateContact(account, contact));
            } else {
                recordId = insertContact(account, contact);
            }
            if (recordId != null && checkUserProfile()) {
                createNewCummunityUser(contact, recordId);
            }
        } catch (DMLException e){
            throw new AuraHandledException(e.getDMLMessage(0));
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return recordId;
    }

    private static void upsertAccount(Account account) {
        upsert account FederalTaxId__c;
    }
    private static Boolean checkMissedFields(Account account, Contact contact) {
        Boolean isBlank = String.isBlank(contact.FirstName)
            || String.isBlank(contact.LastName)
            || String.isBlank(contact.Email__c)
            || String.isBlank(account.FederalTaxId__c)
            || String.isBlank(account.Name);
        return isBlank;
    }
    private static Boolean checkIncorrectAssign(Account account, Contact contact) {
        Boolean isError = false;
        String email = contact.Email__c;
        List<Contact> listOfContacts = new List<Contact>();
        listOfContacts = [
            SELECT Email__c, Account.FederalTaxId__c
            FROM Contact
            WHERE Email__c =: email
                AND Account.FederalTaxId__c !=: account.FederalTaxId__c
        ];
        if (listOfContacts.size() == 1) {
            isError = true;
        }
        return isError;
    }
    private static Id insertContact(Account account, Contact contact) {
        Contact newContact = new Contact(
            FirstName = contact.FirstName,
            LastName = contact.LastName,
            Email__c = contact.Email__c,
            AccountId = account.Id
        );
        insert newContact;
        return newContact.Id;
    }
    private static Id updateContact(Account account, Contact contact, List<Contact> contactList) {
        for (Contact cont : contactList) {
            cont.FirstName = contact.FirstName;
            cont.LastName = contact.LastName;
            cont.Email__c = contact.Email__c;
            cont.Account.FederalTaxId__c = account.FederalTaxId__c;
        }
        update contactList;
        return contactList[0].Id;
    }
    private static List<Contact> checkDuplicateContact(Account account, Contact contact) {
        String email = contact.Email__c;
        List<Contact> contactList = new List<Contact>();
        contactList = [
            SELECT Email__c, Account.FederalTaxId__c
            FROM Contact
            WHERE Email__c =: email
                AND Account.FederalTaxId__c =: account.FederalTaxId__c
        ];
        return contactList;
    }
    private static void createNewCummunityUser(Contact contact, Id recordId) {
        List<Profile> profileList = new List<Profile>();
        profileList = [
            SELECT UserLicense.Name
            FROM Profile
            WHERE UserLicense.Name = 'Customer Community Login'
        ];
        String nick = contact.Email__c.substring(0, contact.Email__c.indexOf('@'));
        String aliasName = contact.FirstName;
        aliasName = aliasName.left(1);
        aliasName += contact.LastName;
        aliasName = aliasName.left(8);
        nick += Datetime.now().getTime();
        User newUser = new User (
            alias = aliasName,
            email = contact.Email__c,
            emailencodingkey = 'UTF-8',
            firstname = contact.FirstName,
            lastname = contact.LastName,
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            contactId = recordId,
            timezonesidkey = 'Asia/Dubai',
            username = contact.Email__c,
            CommunityNickname = nick,
            ProfileId = profileList[0].Id,
            IsActive = true
        );
        insert newUser;
    }
    private static Boolean checkUserProfile() {
        String userProfileName = [
            SELECT Name
            FROM Profile
            WHERE Id =: UserInfo.getProfileId()].Name
        ;
        Boolean isSystemAdmin = userProfileName == 'System Administrator';
        return isSystemAdmin;
    }
    @AuraEnabled
    public static ContactWithAccount getAssignedContact() {
        ContactWithAccount contactWithAccount = new ContactWithAccount();
        if (!checkUserProfile()) {
            List<User> userList = new List<User>();
            userList = [
                SELECT UserName, ContactId
                FROM User
                WHERE UserName =: UserInfo.getUsername()
            ];
            List<Contact> contactList = new List<Contact>();
            contactList = [
                SELECT FirstName, LastName, Email__c, AccountId
                FROM Contact
                WHERE Id =: userList[0].ContactId
            ];
            List<Account> accountList = new List<Account>();
            accountList = [
                SELECT Name, FederalTaxId__c
                FROM Account
                WHERE Id =: contactList[0].AccountId
            ];
            contactWithAccount.attachIds.addAll(getAttachIds(contactList[0].Id));
            contactWithAccount.contact = contactList[0];
            contactWithAccount.account = accountList[0];
            contactWithAccount.recordId = contactList[0].Id;
        }
        return contactWithAccount;
    }
    private static Set<Id> getAttachIds(Id contactId) {
        Set<Id> attachIdsSet = new Set<Id>();
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        contentDocumentLinkList = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId =: contactId
        ];
        for (ContentDocumentLink contentDoc : contentDocumentLinkList) {
            attachIdsSet.add(contentDoc.ContentDocumentId);
        }
        return attachIdsSet;
    }
    public class ContactWithAccount {

        @AuraEnabled
        public Account account { get; set; }
        @AuraEnabled
        public Contact contact { get; set; }
        @AuraEnabled
        public Id recordId { get; set; }
        @AuraEnabled
        public Set<Id> attachIds { get; set; }

        public ContactWithAccount() {
            attachIds = new Set<Id>();
        }
    }
}