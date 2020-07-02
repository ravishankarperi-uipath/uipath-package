public interface SObjectIndexI {
  SObjectIndexI put(SObject newObj);
  List<SObject> getAll(Object key);
  List<SObject> getAll(SObject spec);
  List<SObject> getAll(Map<String, Object> spec);
  List<SObject> values();
  List<SObject> remove(SObject spec);
  List<SObject> remove(Map<String, Object> spec);
  Set<Object> keySet(String field);
}
