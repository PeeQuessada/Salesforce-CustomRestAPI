global with sharing class restAddressBookv2_cls {
    
    
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
