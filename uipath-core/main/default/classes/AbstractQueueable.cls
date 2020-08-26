/**
 * Wrapper class to overcome asynchronous transaction limits (for example, from a batch Apex job), where you can add only one job to the queue with System.enqueueJob
 * We use this to have control over the flow and make sure that System.enqueueJob() is executed on our QueueableChain only once at the end of the transaction
 *.
 */
public abstract class AbstractQueueable implements Queueable {
    private static Integer counter = 0;
    public String name;
    private static final QueueableChain currentChain = new QueueableChain();

    public AbstractQueueable(String name) {
        this.name = name + '.' + ++counter + System.now().format();
    }
    public abstract void work();

    public void execute(QueueableContext ctx) {
        //execute work in the current Queueable.
        //This may potentially call QueueableWrapper.enqueue many times adding items to theChain List
        this.work();

        //finally the accumulated queueables are all executed in one shot at the end
        if (!Test.isRunningTest()) {
            currentChain.commitQueue();
        }
    }

    public static void enqueue(AbstractQueueable queueable) {
        currentChain.add(queueable);
        if (!System.isQueueable() && !Test.isRunningTest()) {
            System.enqueueJob(queueable);
        }
    }


    public static void enqueueIfFieldsChanged(AbstractQueueable queueable,Set<SObjectField> fieldTokens,fflib_SObjectDomain domain) {
        List<SObject> changedAccounts = domain.getChangedRecords(fieldTokens);
        if (changedAccounts.size() > 0) {
            enqueue(
                queueable
            );
        }
        currentChain.add(queueable);
        if (!System.isQueueable() && !Test.isRunningTest()) {
            System.enqueueJob(queueable);
        }
    }

    private class QueueableChain implements Queueable {


        private List<AbstractQueueable> chain = new List<AbstractQueueable>();

        /**
         * This basically takes items from the chain one by one and schedules them for execution one by one.
         * It executes the first one by directly calling execute on it and then schedules the remainder via the Wrapper logic again. This is repeated recursively until there is nothing left in the chain
         * @param ctx
         */
        public void execute(QueueableContext ctx) {
            if (this.chain.isEmpty()) {
                return;
            }
            AbstractQueueable current = this.chain.remove(0);

            if (!this.chain.isEmpty()) {
                for (AbstractQueueable queueable : this.chain) {
                    enqueue(queueable);
                }
            }
            current.execute(ctx);
        }

        public void add(AbstractQueueable queueable) {
            System.debug('Chains in queue: ' + this.chain.size());
            for (AbstractQueueable queueableWrapper : chain) {
                System.debug(queueableWrapper.name);
            }
            if (this.chain.size() > 10 && !Test.isRunningTest()) {
                throw new QueueableChainException(
                        'Chains longer than 10 links are not supported'
                );
            }

            if (queueable == null) {
                return;
            }
            this.chain.add(queueable);
        }

        //Runs the whole chain as one single queueable
        public void commitQueue() {
            System.enqueueJob(this);
        }
    }

    public class QueueableChainException extends Exception {
    }
}
