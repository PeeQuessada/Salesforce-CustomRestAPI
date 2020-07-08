global without sharing class restAPIAddressBook_cls {
    
    public static ReturnApi upsertAddressBook(List<restAPIAddressBook_cls.AddressBook> listAddressBook){
        // List<AddressBook> listAddressBook = (List<AddressBook>) JSON.deserialize(jsonAddressBooks, List<AddressBook>.class); 

        List<Account> lstAccount = new List<Account>();
        Map<String, BusinessDetail__c> mapBusinessDetail = new Map<String, BusinessDetail__c>();
        Map<String, ERPInformation__c> mapERPInformation = new Map<String, ERPInformation__c>();

        // Distribui os campos de Addressbook em 3 objetos (Account, BusinessDetail, ERPInformation)
        Bussines__c objBussiness = [SELECT Id, Name FROM Bussines__c LIMIT 1];
        Set<String> setAddressBook = new Set<String>();
        for(AddressBook objAddressBook : listAddressBook){
            setAddressBook.add(objAddressBook.addressBook);
            String strExternalIdbyBusiness = objAddressBook.addressBook + '-' + objBussiness.Name;
            lstAccount.add(addressBookToAccount(objAddressBook, objBussiness, strExternalIdbyBusiness));
            mapBusinessDetail.put(objAddressBook.addressBook, addressBookToBussinessDetail(objAddressBook, objBussiness, strExternalIdbyBusiness));
            mapERPInformation.put(objAddressBook.addressBook, addressBookToErpInformation(objAddressBook, objBussiness, strExternalIdbyBusiness));
        }

        // instance wrapper return api 
        returnApi returnAddressBook = new returnApi();
        
        // Cria as contas
        Database.upsert(lstAccount, Account.Fields.ExternalIdByBussiness__c, false);

        // Busca as contas criadas e se não a conta nao foi criada (nao tiver id), remove os registros de BussinessDetail e ERP das listas para nao serem criados tambem
        for(Account objAccount : lstAccount){
            if(objAccount.Id == null){
                mapBusinessDetail.remove(objAccount.ExternalIdByBussiness__c);
                mapBusinessDetail.remove(objAccount.ExternalIdByBussiness__c);
            }
        }

        // Cria os BusinessDetail
        Database.upsert(mapBusinessDetail.values(), BusinessDetail__c.Fields.ExternalIdByBussiness__c, false);

        // Busca os BusinessDetail criados e se não o BusinessDetail nao foi criado (nao tiver id), remove os registros de ERP da lista para nao serem criados tambem
        for(BusinessDetail__c objBusinessDetail : mapBusinessDetail.values()){
            if(objBusinessDetail.Id == null){
                mapERPInformation.remove(objBusinessDetail.ExternalIdByBussiness__c);
            }
        }

        // Cria os ERP
        Database.upsert(mapERPInformation.values(), ERPInformation__c.Fields.ExternalIdByBussiness__c, false);

        // Adiciona os AddressBook criados em uma lista e os não criado em outra para retornar para o sistema
        for(ERPInformation__c objERPInformation : mapERPInformation.values()){
            if(objERPInformation.Id == null){
                returnAddressBook.errorAddressBook.add(new returnAdressBook(objERPInformation.ERPID__C, 'error', '500', 'Error in creation addressbook'));
            } else {
                returnAddressBook.successAddressBook.add(new returnAdressBook(objERPInformation.ERPID__C, 'success', '200', 'Addressbook created successfuly'));
            }
        }        

        return returnAddressBook;
    }

    public static Account addressBookToAccount(AddressBook objAddressBook, Bussines__c objBusiness, String strExternalIdbyBusiness){
        Account objAccount                  = new Account();
        objAccount.Name                     = objAddressBook.name;
        objAccount.BillingCity              = objAddressBook.city;
        objAccount.CASC_Address_Customer__c = objAddressBook.addressBook;
        objAccount.ExternalIdByBussiness__c = strExternalIdbyBusiness;

        if(objAddressBook.parentAddress != '' && objAddressBook.parentAddress != null)
            objAccount.Parent = new Account(ExternalIdByBussiness__c = objAddressBook.parentAddress);

        return objAccount;
    }

    public static BusinessDetail__c addressBookToBussinessDetail(AddressBook objAddressBook, Bussines__c objBusiness, String strExternalIdbyBusiness){
        Account objAccount =  new Account(ExternalIdByBussiness__c = strExternalIdbyBusiness);
        BusinessDetail__c objBusinessDetail        = new BusinessDetail__c();
        objBusinessDetail.BusinessUnit__c          = objBusiness.Id;
        objBusinessDetail.Name                     = objAddressBook.name;
        objBusinessDetail.IdentificationDocument__c= objAddressBook.stateRegistration;
        objBusinessDetail.CreditLimit__c           = objAddressBook.creditLimit;
        objBusinessDetail.ExternalIdByBussiness__c = strExternalIdbyBusiness;
        objBusinessDetail.Account__r               =  new Account(ExternalIdByBussiness__c = strExternalIdbyBusiness);
        return objBusinessDetail;
    }

    public static ERPInformation__c addressBookToErpInformation(AddressBook objAddressBook,Bussines__c objBusiness, String strExternalIdbyBusiness){
        ERPInformation__c objERPInformation        = new ERPInformation__c();
        objERPInformation.Business__c              = objBusiness.Id;
        objERPInformation.Name                     = objAddressBook.name + '-' + objAddressBook.addressBook;
        objERPInformation.ERPID__c                 = objAddressBook.addressBook;
        objERPInformation.ExternalIdByBussiness__c = strExternalIdbyBusiness;
        objERPInformation.Account__r               = new Account(ExternalIdByBussiness__c = strExternalIdbyBusiness);
        objERPInformation.BusinessDetail__r        = new BusinessDetail__c(ExternalIdByBussiness__c = strExternalIdbyBusiness);
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
        public String statusCode;
        public String message;

        public returnAdressBook(String addressBook, String status, String statusCode, String message){
            this.addressBook = addressBook;            
            this.status = status;
            this.statusCode = statusCode;
            this.message = message;
        }
    }
    
}