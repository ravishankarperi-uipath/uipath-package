public with sharing class AccountSetRegionSpecificTierFunction implements SObjectToSObjectFunction {
  /**
   * Set Region Specific Field based on Tier level
   * *ProcessBuilder clean-up: Acc Segmentation - Update Reg Specific
   */
  public SObject apply(Account acc) {
    if (
      acc.Geo__c == 'AMER' &&
      acc.Region__c != 'Canada' &&
      acc.Region__c != 'LATAM'
    ) {
      // Enterprise Tier 3 - AMER
      if (
        acc.AnnualRevenue >= 1000000000.00 &&
        ((acc.NumberOfEmployees < 1000 &&
        acc.AnnualRevenue < 6000000000.00) ||
        (acc.NumberOfEmployees >= 1000 &&
        acc.NumberOfEmployees < 3000 &&
        acc.AnnualRevenue < 4000000000.00) ||
        (acc.NumberOfEmployees >= 3000 &&
        acc.NumberOfEmployees < 5000 &&
        acc.AnnualRevenue < 2000000000.00))
      ) {
        acc.Region_Specific__c = 'Enterprise Tier 3';
      } else if (
        (acc.NumberOfEmployees < 1000 &&
        acc.AnnualRevenue >= 6000000000.00) ||
        (acc.NumberOfEmployees >= 1000 &&
        acc.NumberOfEmployees < 3000 &&
        acc.AnnualRevenue >= 4000000000.00 &&
        acc.AnnualRevenue < 10000000000.00) ||
        (acc.NumberOfEmployees >= 3000 &&
        acc.NumberOfEmployees < 5000 &&
        acc.AnnualRevenue >= 2000000000.00 &&
        acc.AnnualRevenue < 10000000000.00) ||
        (acc.NumberOfEmployees >= 5000 &&
        acc.NumberOfEmployees < 10000 &&
        acc.AnnualRevenue >= 1000000000.00 &&
        acc.AnnualRevenue < 6000000000.00) ||
        (acc.NumberOfEmployees >= 10000 &&
        acc.AnnualRevenue >= 1000000000.00 &&
        acc.AnnualRevenue < 4000000000.00)
      ) {
        // Enterprise Tier 2 - AMER
        acc.Region_Specific__c = 'Enterprise Tier 2';
      } else if (
        (acc.NumberOfEmployees >= 1000 &&
        acc.NumberOfEmployees < 5000 &&
        acc.AnnualRevenue >= 10000000000.00) ||
        (acc.NumberOfEmployees >= 5000 &&
        acc.NumberOfEmployees < 10000 &&
        acc.AnnualRevenue >= 6000000000.00) ||
        (acc.NumberOfEmployees >= 10000 &&
        acc.AnnualRevenue >= 4000000000.00)
      ) {
        // Enterprise Tier 1 - AMER
        acc.Region_Specific__c = 'Enterprise Tier 1';
      } else if (
        acc.AnnualRevenue >= 1.00 &&
        ((acc.NumberOfEmployees < 1000 &&
        acc.AnnualRevenue < 650000000.00) ||
        (acc.NumberOfEmployees >= 1000 &&
        acc.NumberOfEmployees < 2000 &&
        acc.AnnualRevenue < 500000000.00) ||
        (acc.NumberOfEmployees >= 2000 &&
        acc.NumberOfEmployees < 3500 &&
        acc.AnnualRevenue < 250000000.00))
      ) {
        // Velocity Tier 3 - AMER
        acc.Region_Specific__c = 'Velocity Tier 3';
      } else if (
        (acc.NumberOfEmployees < 1000 &&
        acc.AnnualRevenue >= 650000000.00 &&
        acc.AnnualRevenue < 1000000000.00) ||
        (acc.NumberOfEmployees >= 1000 &&
        acc.NumberOfEmployees < 2000 &&
        acc.AnnualRevenue >= 500000000.00 &&
        acc.AnnualRevenue < 750000000.00) ||
        (acc.NumberOfEmployees >= 2000 &&
        acc.NumberOfEmployees < 3500 &&
        acc.AnnualRevenue >= 250000000.00 &&
        acc.AnnualRevenue < 750000000.00) ||
        (acc.NumberOfEmployees >= 3500 &&
        acc.NumberOfEmployees < 5000 &&
        acc.AnnualRevenue >= 1.00 &&
        acc.AnnualRevenue < 650000000.00) ||
        (acc.NumberOfEmployees >= 5000 &&
        acc.AnnualRevenue >= 1.00 &&
        acc.AnnualRevenue < 500000000.00)
      ) {
        // Velocity Tier 2 - AMER
        acc.Region_Specific__c = 'Velocity Tier 2';
      } else if (
        (acc.NumberOfEmployees >= 1000 &&
        acc.NumberOfEmployees < 3500 &&
        acc.AnnualRevenue >= 750000000.00 &&
        acc.AnnualRevenue < 1000000000.00) ||
        (acc.NumberOfEmployees >= 3500 &&
        acc.NumberOfEmployees < 5000 &&
        acc.AnnualRevenue >= 650000000.00 &&
        acc.AnnualRevenue < 1000000000.00) ||
        (acc.NumberOfEmployees >= 5000 &&
        acc.AnnualRevenue >= 500000000.00 &&
        acc.AnnualRevenue < 1000000000.00)
      ) {
        // Velocity Tier 1 - AMER
        acc.Region_Specific__c = 'Velocity Tier 1';
      }
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }
}
