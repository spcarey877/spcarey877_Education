package uk.ac.cam.spc55.fjava.tick3;

public class SafeMessageQueue<T> implements MessageQueue<T> {
    private static class Link<L> {
        L val;
        Link<L> next;

        Link(L val) {
            this.val = val;
            this.next = null;
        }
    }

    private Link<T> first = null;
    private Link<T> last = null;

    public synchronized void put(T val) {
        Link<T> newLink = new Link<>(val);
        if (first != null) {
            last.next = newLink;
        } else {
            first = newLink;
        }
        last = newLink;
        notifyAll();
    }

    public synchronized T take() {
        while (first == null) { // use a loop to block thread until data is available
            try {
                wait();
            } catch (InterruptedException ie) {
                // Ignored exception
            }
        }
        T val = first.val;
        first = first.next;
        return val;
    }
}
