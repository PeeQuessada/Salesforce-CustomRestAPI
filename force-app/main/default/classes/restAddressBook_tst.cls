@isTest
public class restAddressBook_tst {
    
    @isTest static void testUpsertAddressBook(){
        List<restAPIAddressBook_cls.AddressBook> lstAddressBook = new List<restAPIAddressBook_cls.AddressBook>();
        restAPIAddressBook_cls.AddressBook addressBook1 = new restAPIAddressBook_cls.AddressBook('123445xx', 'nametest', '12345746', 'active', 'cityTest', 10, '');
        restAPIAddressBook_cls.AddressBook addressBook2 = new restAPIAddressBook_cls.AddressBook('1145255', 'nametest2', '12345748', 'active', 'cityTest', 10, '');
        lstAddressBook.add(addressBook1);
        lstAddressBook.add(addressBook2);

        System.assertEquals(0, [SELECT Id FROM Account].size());
        System.assertEquals(0, [SELECT Id FROM BusinessDetail__c].size());
        System.assertEquals(0, [SELECT Id FROM ERPInformation__c].size());

        Bussines__c objBussiness = new Bussines__c();
        objBussiness.Name = 'Test';
        insert objBussiness;

        Test.startTest();

        restAPIAddressBook_cls.ReturnApi resultMehod = restAddressBook_api.upsertAddressBook(lstAddressBook);

        System.assertEquals(2, [SELECT Id FROM Account].size());
        System.assertEquals(2, [SELECT Id FROM BusinessDetail__c].size());
        System.assertEquals(2, [SELECT Id FROM ERPInformation__c].size());

        System.assertEquals(2, resultMehod.successAddressBook.size());
        System.assertEquals(0, resultMehod.errorAddressBook.size());

        Test.stopTest();

        
    }

    @isTest static void testUpsertAddressBookError(){
        List<restAPIAddressBook_cls.AddressBook> lstAddressBook = new List<restAPIAddressBook_cls.AddressBook>();
        restAPIAddressBook_cls.AddressBook addressBook1 = new restAPIAddressBook_cls.AddressBook('123445xx', 'nametest', '12345746', 'active', 'cityTest', 10, '');
        restAPIAddressBook_cls.AddressBook addressBook2 = new restAPIAddressBook_cls.AddressBook('1145255', '', '12345748', 'active', 'cityTest', 10, '');
        lstAddressBook.add(addressBook1);
        lstAddressBook.add(addressBook2);

        System.assertEquals(0, [SELECT Id FROM Account].size());
        System.assertEquals(0, [SELECT Id FROM BusinessDetail__c].size());
        System.assertEquals(0, [SELECT Id FROM ERPInformation__c].size());

        Bussines__c objBussiness = new Bussines__c();
        objBussiness.Name = 'Test';
        insert objBussiness;

        Test.startTest();

        restAPIAddressBook_cls.ReturnApi resultMehod = restAddressBook_api.upsertAddressBook(lstAddressBook);

        System.assertEquals(1, [SELECT Id FROM Account].size());
        System.assertEquals(1, [SELECT Id FROM BusinessDetail__c].size());
        System.assertEquals(1, [SELECT Id FROM ERPInformation__c].size());

        System.assertEquals(1, resultMehod.successAddressBook.size());
        System.assertEquals(1, resultMehod.errorAddressBook.size());

        Test.stopTest();

        
    }
}