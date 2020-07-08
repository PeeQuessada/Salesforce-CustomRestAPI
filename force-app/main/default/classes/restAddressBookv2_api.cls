@RestResource(urlMapping='/AddressBookV2/*')
global without sharing class restAddressBookv2_api {
    @HttpPut
    global static restAddressBookv2_cls.ReturnApi upsertAddressBook() {
        String addressBookJSON = RestContext.request.requestBody.toString();
        List<restAddressBookv2_cls.AddressBook> lstAddressBook = (List<restAddressBookv2_cls.AddressBook>) (JSON.deserialize(addressBookJSON, List<restAddressBookv2_cls.AddressBook>.class));

        restAddressBookv2_cls.ReturnApi returnApi = restAddressBookv2_cls.createAddressBook(lstAddressBook);

        return returnApi;
    }
    /*
        [
            {
                "addressBook":"123445xx",
                "name":"nametest",
                "stateRegistration":"12345746",
                "internalStatus":"active",
                "city":"cityTest",
                "creditLimit":"1000",
                "parentAddress":""
            },
            {
                "addressBook":"1145255",
                "name":"nametest2",
                "stateRegistration":"12345748",
                "internalStatus":"active",
                "city":"cityTest",
                "creditLimit":"18000",
                "parentAddress":"123445xx"
            }
        ]
    */
}
