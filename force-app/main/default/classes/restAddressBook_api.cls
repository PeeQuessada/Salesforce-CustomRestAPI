@RestResource(urlMapping='/AddressBook/*')
global without sharing class restAddressBook_api {
 
    @HttpPut
    global static restAPIAddressBook_cls.ReturnApi upsertAddressBook(List<restAPIAddressBook_cls.AddressBook> jsonAddressBooks) {
        restAPIAddressBook_cls.ReturnApi resultMehod = restAPIAddressBook_cls.upsertAddressBook(jsonAddressBooks);
        return resultMehod;
    }
    /*
        {
            "jsonAddressBooks" : [
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
        }
    */

}