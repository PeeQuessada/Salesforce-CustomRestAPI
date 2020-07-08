global with sharing class restAddressBookv2_cls {

    public static ReturnApi createAddressBook(List<AddressBook> lstAddressBook){

        Set<String> setAddressbookId = new Set<String>();
        for(AddressBook objAddressBook : lstAddressBook){
            setAddressbookId.add(objAddressBook.addressBook);
        }

        Map<String, String> mapAddressBookIdByAccountId        = new Map<String, String>();
        Map<String, String> mapAddressBookIdByBusinessDetailId = new Map<String, String>();
        Map<String, String> mapAddressBookIdByERPInformationId = new Map<String, String>();

        for(ERPInformation__c objERPInformation : [SELECT Id, ERPID__c, Account__c, BusinessDetail__c FROM ERPInformation__c WHERE ERPID__c IN :setAddressbookId ]){
            mapAddressBookIdByAccountId.put(objERPInformation.ERPID__c, objERPInformation.Account__c);
            mapAddressBookIdByBusinessDetailId.put(objERPInformation.ERPID__c, objERPInformation.BusinessDetail__c);
            mapAddressBookIdByERPInformationId.put(objERPInformation.ERPID__c, objERPInformation.Id);
        }

        Bussines__c objBussiness = [SELECT Id, Name FROM Bussines__c LIMIT 1];

        // Lista para criação de novos registros
        Map<String, Account> mapAccountInsert = new Map<String, Account>();
        Map<String, BusinessDetail__c> mapBusinessDetailInsert = new Map<String, BusinessDetail__c>();
        Map<String, ERPInformation__c> mapERPInformationInsert = new Map<String, ERPInformation__c>();

        // Lista para atualizar registros
        Map<String, Account> mapAccountUpdate = new Map<String, Account>();
        Map<String, BusinessDetail__c> mapBusinessDetailUpdate = new Map<String, BusinessDetail__c>();
        Map<String, ERPInformation__c> mapERPInformationUpdate = new Map<String, ERPInformation__c>();

        for(AddressBook objAddressBook : lstAddressBook){
            if(mapAddressBookIdByERPInformationId.containsKey(objAddressBook.addressBook)){
                Account objAccount = addressBookToAccount(objAddressBook, objBussiness);
                objAccount.Id = mapAddressBookIdByAccountId.get(objAddressBook.addressBook);
                mapAccountUpdate.put(objAddressBook.addressBook, objAccount);

                BusinessDetail__c objBusinessDetail = addressBookToBussinessDetail(objAddressBook, objBussiness);
                objBusinessDetail.Id = mapAddressBookIdByBusinessDetailId.get(objAddressBook.addressBook);
                mapBusinessDetailUpdate.put(objAddressBook.addressBook, objBusinessDetail);

                ERPInformation__c objERPInformation = addressBookToErpInformation(objAddressBook, objBussiness);
                objERPInformation.Id = mapAddressBookIdByERPInformationId.get(objAddressBook.addressBook);
                mapERPInformationUpdate.put(objAddressBook.addressBook, objERPInformation);
            } else{
                mapAccountInsert.put(objAddressBook.addressBook, addressBookToAccount(objAddressBook, objBussiness));
                mapBusinessDetailInsert.put(objAddressBook.addressBook, addressBookToBussinessDetail(objAddressBook, objBussiness));
                mapERPInformationInsert.put(objAddressBook.addressBook, addressBookToErpInformation(objAddressBook, objBussiness));
            }
        }

        // instance wrapper return api 
        returnApi returnAddressBook = new returnApi();
        
        // Atualização de addressbook
        Set<String> setAccountIdUpdate = new Set<String>();
        Set<String> setBusinessDetailIdUpdate = new Set<String>();
        Set<String> setERPInformationIdUpdate = new Set<String>();
        Set<String> setAddressbookUpdate   = new Set<String>();

        // Atualiza as contas
        List<Database.SaveResult> resultAccount = Database.update(mapAccountUpdate.values(), false);

        // verifica as contas que não foram atualizadas para não atualizar os registros de BusinessDetail e ERPInformation
        for (Integer i = 0; i < resultAccount.size(); i++) {
            if(resultAccount[i].isSuccess())
                setAccountIdUpdate.add(resultAccount[i].getId());
        }
        for(String addressBook : mapAccountUpdate.keySet()){
            Account objAccount = mapAccountUpdate.get(addressBook);
            if(!setAccountIdUpdate.contains(objAccount.Id)){
                mapBusinessDetailUpdate.remove(addressBook);
                mapERPInformationUpdate.remove(addressBook);
            } 
        }   
        
        // Atualiza os businessDetail
        List<Database.SaveResult> resultBusinessDetail = Database.update(mapBusinessDetailUpdate.values(), false);

        // verifica os businessDetail que não foram atualizadas para não atualizar os registros de ERPInformation
        for (Integer i = 0; i < resultBusinessDetail.size(); i++) {
            if(resultBusinessDetail[i].isSuccess())
                setBusinessDetailIdUpdate.add(resultBusinessDetail[i].getId());
            
        }
        for(String addressBook : mapBusinessDetailUpdate.keySet()){
            BusinessDetail__c objBusinessDetail = mapBusinessDetailUpdate.get(addressBook);
            if(!setBusinessDetailIdUpdate.contains(objBusinessDetail.Id))
                mapERPInformationUpdate.remove(addressBook);  
        } 

        // Atualiza os businessDetail
        List<Database.SaveResult> resultERPInformation = Database.update(mapERPInformationUpdate.values(), false);

        // verifica os ERPInformation que não foram atualizadas para retornar erro para integração
        for (Integer i = 0; i < resultERPInformation.size(); i++) {
            if(resultERPInformation[i].isSuccess())
                setERPInformationIdUpdate.add(resultERPInformation[i].getId());
        }
        for(String addressBook : mapERPInformationUpdate.keySet()){
            ERPInformation__c objERPInformation = mapERPInformationUpdate.get(addressBook);
            if(setERPInformationIdUpdate.contains(objERPInformation.Id))
                setAddressbookUpdate.add(addressBook);
        } 

        
        

        // criação das linhas de erro e sucesso referente a atualização de addressbook
        for(AddressBook objAddressBook : lstAddressBook){
            if(setAddressbookUpdate.contains(objAddressBook.addressBook)){
                returnAddressBook.successAddressBook.add(new returnAdressBook(objAddressBook.addressBook, 'success', '200', 'Addressbook created successfuly'));
            } else{
                returnAddressBook.errorAddressBook.add(new returnAdressBook(objAddressBook.addressBook, 'error', '500', 'Error in creation addressbook'));
            }
        }

        // Criação de novos Adrresss

        for (Integer i = 0; i < resultBusinessDetail.size(); i++) {
            if(resultBusinessDetail[i].isSuccess()){
                System.debug('Successfully created ID: ' + resultBusinessDetail[i].getId());
            } else{
                System.debug('Error: could not create sobject ' + 'for array element ' + i + '.');
                System.debug('The error reported was: ' + resultBusinessDetail[i].getErrors()[0].getMessage());
            }
        }

        return returnAddressBook;
    }

    public static Account addressBookToAccount(AddressBook objAddressBook, Bussines__c objBusiness){
        Account objAccount                  = new Account();
        objAccount.Name                     = objAddressBook.name;
        objAccount.BillingCity              = objAddressBook.city;
        objAccount.CASC_Address_Customer__c = objAddressBook.addressBook;
        return objAccount;
    }

    public static BusinessDetail__c addressBookToBussinessDetail(AddressBook objAddressBook, Bussines__c objBusiness){
        BusinessDetail__c objBusinessDetail        = new BusinessDetail__c();
        objBusinessDetail.BusinessUnit__c          = objBusiness.Id;
        objBusinessDetail.Name                     = objAddressBook.name;
        objBusinessDetail.IdentificationDocument__c= objAddressBook.stateRegistration;
        objBusinessDetail.CreditLimit__c           = objAddressBook.creditLimit;
        return objBusinessDetail;
    }

    public static ERPInformation__c addressBookToErpInformation(AddressBook objAddressBook, Bussines__c objBusiness){
        ERPInformation__c objERPInformation        = new ERPInformation__c();
        objERPInformation.Business__c              = objBusiness.Id;
        objERPInformation.Name                     = objAddressBook.name + '-' + objAddressBook.addressBook;
        objERPInformation.ERPID__c                 = objAddressBook.addressBook;
        return objERPInformation;
    }
    
    
    global class AddressBook{
        public String addressBook;  
        public String name;  
        public String stateRegistration;  
        public String internalStatus;  
        public String city;  
        public Decimal creditLimit;  
        public String parentAddress;  

        public AddressBook(String addressBook, String name, String stateRegistration, String internalStatus, String city, Decimal creditLimit, String parentAddress){
            this.addressBook    = addressBook;
            this.name           = name;
            this.stateRegistration      = stateRegistration;
            this.internalStatus = internalStatus;
            this.city           = city;
            this.creditLimit    = creditLimit;
            this.parentAddress  = parentAddress;
        }
    }

    global class ReturnApi{
        public List<returnAdressBook> successAddressBook;
        public List<returnAdressBook> errorAddressBook;

        public ReturnApi(){
            this.successAddressBook = new List<returnAdressBook>();
            this.errorAddressBook   = new List<returnAdressBook>();
        }
    }

    global class returnAdressBook{
        public String addressBook;
        public String status;
        public String error;
        public String message;

        public returnAdressBook(String addressBook, String status, String error, String message){
            this.addressBook = addressBook;            
            this.status = status;
            this.error = error;
            this.message = message;
        }
    }

}
