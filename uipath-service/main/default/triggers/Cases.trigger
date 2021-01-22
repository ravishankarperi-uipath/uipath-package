trigger Cases on Case(before insert, before update, after insert, after update) {
  // Creates Domain class instance and calls appropriate overridable methods according to Trigger state
  fflib_SObjectDomain.triggerHandler(Cases.class);
}
