/**
 * Wrapper class to overcome asynchronous transaction limits (for example, from a batch Apex job), where you can add only one job to the queue with System.enqueueJob
 * We use this to have control over the flow and make sure that System.enqueueJob() is executed on our QueueableChain only once at the end of the transaction
 *
 */
public abstract class QueueableWrapper implements Queueable {
    private static Integer counter = 0;
    public String name;
    public QueueableWrapper(String name) {
        this.name = name + '.' + ++counter + System.now().format();
    }
    public abstract void work();

    public void execute(QueueableContext ctx) {
        this.work();
        if(!Test.isRunningTest()) {
            currentChain.commitQueue();
        }
    }

    public static void enqueue(QueueableWrapper queueable) {
        currentChain.add(queueable);
        if (!System.isQueueable()) {
            System.enqueueJob(queueable);
        }
    }

    private class QueueableChain implements Queueable {
        private List<QueueableWrapper> chain = new List<QueueableWrapper>();
        public void execute(QueueableContext ctx) {
            if (this.chain.isEmpty()) {
                return;
            }
            QueueableWrapper current = this.chain.remove(0);

            if (!this.chain.isEmpty()) {
                for (QueueableWrapper queueable : this.chain) {
                    enqueue(queueable);
                }
            }
            current.execute(ctx);
        }

        public void add(QueueableWrapper queueable) {

            System.debug('Chains in queue: ' + this.chain.size());
            for (QueueableWrapper queueableWrapper : chain) {
                System.debug(queueableWrapper.name);
            }
            if(this.chain.size()>10) {
                throw new QueueableChainException('Chains longer than 10 links are not supported');
            }

            if (queueable == null) {
                return;
            }
            this.chain.add(queueable);
        }

        public void commitQueue() {
                System.enqueueJob(this);

        }
    }
    private static final QueueableChain currentChain = new QueueableChain();

    public class QueueableChainException extends Exception{}
}

