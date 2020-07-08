@isTest
public class restAddressBookv2_tst {
    
    @isTest static void testUpsertAddressBook(){
        List<restAddressBookv2_cls.AddressBook> lstAddressBook = new List<restAddressBookv2_cls.AddressBook>();
        restAddressBookv2_cls.AddressBook addressBook1 = new restAddressBookv2_cls.AddressBook('123445xx', 'nametest', '12345746', 'active', 'cityTest', 10, '');
        restAddressBookv2_cls.AddressBook addressBook2 = new restAddressBookv2_cls.AddressBook('1145255', 'nametest2', '12345748', 'active', 'cityTest', 10, '');
        lstAddressBook.add(addressBook1);
        lstAddressBook.add(addressBook2);

        List<restAddressBookv2_cls.AddressBook> lstAddressBookUpdate = new List<restAddressBookv2_cls.AddressBook>();
        restAddressBookv2_cls.AddressBook addressBook11 = new restAddressBookv2_cls.AddressBook('123445xx', 'nametest', '12345746', 'active', 'cityTest2', 10, '');
        restAddressBookv2_cls.AddressBook addressBook21 = new restAddressBookv2_cls.AddressBook('1145255', 'nametest2', '12345748', 'active', 'cityTest2', 10, '');
        lstAddressBookUpdate.add(addressBook11);
        lstAddressBookUpdate.add(addressBook21);

        Bussines__c objBussiness = new Bussines__c();
        objBussiness.Name = 'Test';
        insert objBussiness;

        String FURLBASE = URL.getSalesforceBaseUrl().toExternalForm();
        String addressBookJSON = JSON.serialize(lstAddressBook);
        RestRequest request = new RestRequest();
        request.requestUri  = FURLBASE +'services/apexrest/AddressBookV2';
        request.httpMethod  = 'PUT';


        System.assertEquals(0, [SELECT Id FROM Account].size());
        System.assertEquals(0, [SELECT Id FROM BusinessDetail__c].size());
        System.assertEquals(0, [SELECT Id FROM ERPInformation__c].size());

        Test.startTest();

        //insert test
		request.requestBody = Blob.valueof(addressBookJSON);
        RestContext.request = request;
		restAddressBookv2_cls.ReturnApi returnApiInsert = restAddressBookv2_api.upsertAddressBook();

        System.assertEquals(2, [SELECT Id FROM Account].size());
        System.assertEquals(2, [SELECT Id FROM BusinessDetail__c].size());
        System.assertEquals(2, [SELECT Id FROM ERPInformation__c].size());

        System.assertEquals(2, returnApiInsert.successAddressBook.size());
        System.assertEquals(0, returnApiInsert.errorAddressBook.size());

        // update test
        String addressBookJSON2 = JSON.serialize(lstAddressBookUpdate);
		request.requestBody = Blob.valueof(addressBookJSON2);
        RestContext.request = request;
		restAddressBookv2_cls.ReturnApi returnApiUpdate = restAddressBookv2_api.upsertAddressBook();

        System.assertEquals(2, [SELECT Id FROM Account].size());
        System.assertEquals(2, [SELECT Id FROM BusinessDetail__c].size());
        System.assertEquals(2, [SELECT Id FROM ERPInformation__c].size());

        System.assertEquals(2, returnApiUpdate.successAddressBook.size());
        System.assertEquals(0, returnApiUpdate.errorAddressBook.size());

        Test.stopTest();   
    }

}
