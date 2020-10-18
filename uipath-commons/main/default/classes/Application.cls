public class Application {
  // Configure and create the UnitOfWorkFactory for this Application
  public static final fflib_Application.UnitOfWorkFactory UnitOfWork = new fflib_Application.UnitOfWorkFactory(
    new List<SObjectType>{ Account.SObjectType }
  );

  // Configure and create the ServiceFactory for this Application
  public static final fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory(
    new Map<Type, Type>{}
  );

  // Configure and create the SelectorFactory for this Application
  public static final fflib_Application.SelectorFactory Selector = new fflib_Application.SelectorFactory(
    new Map<SObjectType, Type>{}
  );
  //                            Account.SObjectType => AccountSelector.class,
  //                            User.sObjectType => UsersSelector.class
  //                            Address__c.sObjectType => AddressSelector.class

  // Configure and create the DomainFactory for this Application
  public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
    Application.Selector,
    new Map<SObjectType, Type>{
      Account.SObjectType => Accounts.Constructor.class,
      Address__c.SObjectType => Addresses.Constructor.class
    }
  );
}
