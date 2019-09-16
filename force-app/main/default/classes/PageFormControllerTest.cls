@isTest
private class PageFormControllerTest {
    @testSetup
    static void prepareData() {
        Account account = new Account (
            Name = 'TestName3',
            FederalTaxId__c = '99999996'
        );
        insert account;
        Contact contact = new Contact (
            FirstName = 'TestFirstName1',
            LastName = 'TestLastName1',
            Email__c = 'test@uog.com',
            AccountId = account.Id
        );
        insert contact;
        String base64Data = EncodingUtil.urlDecode('MTIz', 'UTF-8');
        Attachment attachment = new Attachment(
            Body = EncodingUtil.base64Decode(base64Data),
            Name = 'test2.txt',
            ParentId = contact.Id,
            ContentType = 'text/plain'
        );
        insert attachment;
        List<Profile> profileGuestList = [
            SELECT UserType
            FROM Profile
            WHERE UserType = 'Guest'
        ];
        User userGuest = new User(
            Alias = 'newUser',
            Email = 'newuser1@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileGuestList[0].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'userGuest@t123estorg.com'
        );
        insert userGuest;
        List<Profile> profileCommunityList = [
            SELECT UserType
            FROM Profile
            WHERE UserType = 'CspLitePortal'
        ];
        User userCommunity = new User(
            Alias = 'newUser',
            Email = 'newuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = contact.Id,
            ProfileId = profileCommunityList[0].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'userCommunity@testorg.com'
        );
        insert userCommunity;
    }
    @isTest
    static void testInsertAccountAndContact() {
        PageFormController.ContactWithAccount accountAndContact = new PageFormController.ContactWithAccount();
        Contact contact = new Contact (
            FirstName = 'TestFristName2',
            LastName = 'TestLastName2',
            Email__c = 'test2222@uog.com'
        );
        Account account = new Account (
            Name = 'TestName22',
            FederalTaxId__c = '99299997'
        );
        List<Contact> contactList = [
            SELECT Id
            FROM Contact
        ];
        List<Attachment> listOfAttachments = [
            SELECT Name, ParentId
            FROM Attachment
            WHERE ParentId = :contactList[0].Id
        ];
        accountAndContact.account = account;
        accountAndContact.contact = contact;
        List<String> fileNameList = new List<String> {'test1.txt'};
        List<String> base64DataList = new List<String> {'MTIz'};
        List<String> contentTypeList = new List<String> {'text/plain'};
        List<Id> deletedAttachIdsList = new List<Id> {listOfAttachments[0].Id};
        List<User> userList = [
            SELECT UserName
            FROM User
            WHERE UserName = 'userGuest@t123estorg.com'
        ];

        System.runAs(userList[0]) {

            Test.startTest();
            Id recordId = PageFormController.createAccountAndContact(accountAndContact, fileNameList, base64DataList, contentTypeList, deletedAttachIdsList);
            Test.stopTest();

            List<Contact> newContactList = new List<Contact>();
            newContactList = [
                SELECT FirstName, LastName, Email__c
                FROM Contact
                WHERE LastName = 'TestLastName2'
            ];
            List<Account> newAccountList = new List<Account>();
            newAccountList = [
                SELECT Name, FederalTaxId__c
                FROM Account
                WHERE Name = 'TestName22'
                    AND FederalTaxId__c = '99299997'
            ];

            System.assertEquals(1, newAccountList.size());
            System.assertEquals(newContactList[0].id, recordId);
        }
    }

    @isTest
    static void testUpdateAccountAndContact() {
        PageFormController.ContactWithAccount accountAndContact = new PageFormController.ContactWithAccount();
        List<Contact> contactList = new List<Contact>();
        contactList = [
            SELECT Name, LastName, Email__c
            FROM Contact
        ];
        List<Attachment> listOfAttachments = [
            SELECT Name, ParentId
            FROM Attachment
            WHERE ParentId = :contactList[0].Id
        ];
        Contact contact = new Contact (
            FirstName = 'TestFristName4',
            LastName = 'TestLastName3',
            Email__c = 'test@uog.com'
        );
        Account account = new Account (
            Name = 'TestName3',
            FederalTaxId__c = '99999996'
        );
        accountAndContact.account = account;
        accountAndContact.contact = contact;
        List<String> fileNameList = new List<String> {'test1.txt'};
        List<String> base64DataList = new List<String> {'MTIz'};
        List<String> contentTypeList = new List<String> {'text/plain'};
        List<Id> deletedAttachIdsList = new List<Id> {listOfAttachments[0].Id};
        List<User> userList = [
            SELECT UserName
            FROM User
            WHERE UserName = 'userCommunity@testorg.com'
        ];

        System.runAs(userList[0]) {
            PageFormController.checkCommunityUser();
            PageFormController.getAssignedContact();
            Test.startTest();
            Id recordId = PageFormController.createAccountAndContact(accountAndContact, fileNameList, base64DataList, contentTypeList, deletedAttachIdsList);
            Test.stopTest();

            List<Contact> newContactList = new List<Contact>();
            newContactList = [
                SELECT FirstName, LastName, Email__c
                FROM Contact
                WHERE LastName = 'TestLastName3'
            ];

            System.assertEquals(newContactList[0].id, recordId);
        }
    }

    @isTest
    static void testInsertNotFilledRecords() {
        PageFormController.ContactWithAccount accountAndContact = new PageFormController.ContactWithAccount();
        Contact contact = new Contact (
            LastName = 'TestLastName2',
            Email__c = 'test2222@uog.com'
        );
        Account account = new Account (
            Name = 'TestName22',
            FederalTaxId__c = '99299997'
        );
        accountAndContact.account = account;
        accountAndContact.contact = contact;
        List<User> userList = [
            SELECT UserName
            FROM User
            WHERE UserName = 'userGuest@t123estorg.com'
        ];
        List<String> fileNameList = new List<String>();
        List<String> base64DataList = new List<String>();
        List<String> contentTypeList = new List<String>();
        List<Id> deletedAttachIdsList = new List<Id>();

        System.runAs(userList[0]) {

            Test.startTest();
            try {
                Id recordId = PageFormController.createAccountAndContact(accountAndContact, fileNameList, base64DataList, contentTypeList, deletedAttachIdsList);
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains(label.errMsgFieldsMustBeFilled));
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testIncorrectAssign() {
        PageFormController.ContactWithAccount accountAndContact = new PageFormController.ContactWithAccount();
        Contact contact = new Contact (
            FirstName = 'test123',
            LastName = 'TestLastName2',
            Email__c = 'test@uog.com'
        );
        Account account = new Account (
            Name = 'TestName22',
            FederalTaxId__c = '19299997'
        );
        accountAndContact.account = account;
        accountAndContact.contact = contact;
        List<User> userList = [
            SELECT UserName
            FROM User
            WHERE UserName = 'userGuest@t123estorg.com'
        ];
        List<String> fileNameList = new List<String>();
        List<String> base64DataList = new List<String>();
        List<String> contentTypeList = new List<String>();
        List<Id> deletedAttachIdsList = new List<Id>();

        System.runAs(userList[0]) {

            Test.startTest();
            try {
                Id recordId = PageFormController.createAccountAndContact(accountAndContact, fileNameList, base64DataList, contentTypeList, deletedAttachIdsList);
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains(label.errMsgContactsIncorrectAssign));
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testIncorrectFederalTaxId() {
        PageFormController.ContactWithAccount accountAndContact = new PageFormController.ContactWithAccount();
        Contact contact = new Contact (
            FirstName = 'test123',
            LastName = 'TestLastName2',
            Email__c = '123test@uog.com'
        );
        Account account = new Account (
            Name = 'TestName22',
            FederalTaxId__c = 'qqq'
        );
        accountAndContact.account = account;
        accountAndContact.contact = contact;
        List<User> userList = [
            SELECT UserName
            FROM User
            WHERE UserName = 'userGuest@t123estorg.com'
        ];
        List<String> fileNameList = new List<String>();
        List<String> base64DataList = new List<String>();
        List<String> contentTypeList = new List<String>();
        List<Id> deletedAttachIdsList = new List<Id>();

        System.runAs(userList[0]) {

            Test.startTest();
            try {
                Id recordId = PageFormController.createAccountAndContact(accountAndContact, fileNameList, base64DataList, contentTypeList, deletedAttachIdsList);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testIncorrectInsert() {
        PageFormController.ContactWithAccount accountAndContact = new PageFormController.ContactWithAccount();
        Contact contact = new Contact (
            FirstName = 'test123',
            LastName = 'TestLastName2',
            Email__c = '123test@uog.com'
        );
        Account account = new Account (
            Name = 'TestName22',
            FederalTaxId__c = '12345678'
        );
        accountAndContact.account = account;
        accountAndContact.contact = contact;
        List<User> userList = [
            SELECT UserName
            FROM User
            WHERE UserName = 'userGuest@t123estorg.com'
        ];

        System.runAs(userList[0]) {

            Test.startTest();
            try {
                Id recordId = PageFormController.createAccountAndContact(accountAndContact, null, null, null, null);
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
            Test.stopTest();
        }
    }
}