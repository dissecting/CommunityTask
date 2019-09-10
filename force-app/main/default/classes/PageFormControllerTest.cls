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
    }
    @isTest
    static void testInsertAccountAndContact() {
        Contact contact = new Contact (
            FirstName = 'TestFristName2',
            LastName = 'TestLastName2',
            Email__c = 'test2@uog.com'
        );
        Account account = new Account (
            Name = 'TestName2',
            FederalTaxId__c = '99999997'
        );
        Test.startTest();
        Id recordId = PageFormController.createAccountAndContact(account, contact);
        Test.stopTest();
        List<Contact> newContactList = new List<Contact>();
        newContactList = [
            SELECT FirstName, LastName, Email__c
            FROM Contact
            WHERE LastName = 'TestLastName2'
        ];
        System.assertEquals(newContactList[0].id, recordId);
    }
    @isTest
    static void testInsertAccountAndUpdateContact() {
        List<Contact> contactList = new List<Contact>();
        contactList = [
            SELECT Name, LastName, Email__c
            FROM Contact
        ];
        List<Account> accountList = new List<Account>();
        accountList = [
            SELECT Name, FederalTaxId__c
            FROM Account
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
        Test.startTest();
        Id recordId = PageFormController.createAccountAndContact(account, contact);
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