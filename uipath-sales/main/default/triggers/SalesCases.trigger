trigger SalesCases on Case(before insert) {
  // Creates Domain class instance and calls appropriate overridable methods according to Trigger state
  fflib_SObjectDomain.triggerHandler(SalesCases.class);
}
