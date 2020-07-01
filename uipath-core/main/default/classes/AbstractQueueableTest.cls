
/**
 * TODO needs more tests -  but is tricky given he limitations of async testing in Salesforce
 */
@IsTest
public with sharing class AbstractQueueableTest {


    @isTest
    public static void canRunQueueableDirectlyWithoutQueuing() {
        TestSupportObject__c testSupportObject = new TestSupportObject__c(Name = 'Queueable test');
        insert testSupportObject;

        TestQueueable first = new TestQueueable();
        first.execute(null);
        System.assertEquals('modified state',first.state);

        //Note that TestQueueable2's work will not execute despite being called in the chain - as the wrapper class calls System.enqueue if the context is not a queueable
        //and System.queue executions dont run in test contexts unless a stopTest is called


    }


    public class TestQueueable extends AbstractQueueable {

        public String state='initial state';

        public TestQueueable() {
            super('TestQueueable');
        }

        public override void work() {
            System.debug('*******Working on TestQueueable **********' + this.name);

            this.state='modified state';
            AbstractQueueable.enqueue(new TestQueueable2());
        }
    }

    public class TestQueueable2 extends AbstractQueueable implements Database.AllowsCallouts {

        public TestQueueable2() {
            super('TestQueueable2');
        }
        public override void work() {
            System.debug('*******Working on TestQueueable2 **********' + this.name);
            // Do some work
        }
    }


    public class TestQueueable3 extends AbstractQueueable implements Database.AllowsCallouts {

        TestSupportObject__c coolObject;

        public TestQueueable3(TestSupportObject__c coolObject) {
            super('TestQueueable3');
            this.coolObject = coolObject;
        }
        public override void work() {
            System.debug('*******Working on TestQueueable3 **********' + this.name);
            // Do some more work
        }
    }


}