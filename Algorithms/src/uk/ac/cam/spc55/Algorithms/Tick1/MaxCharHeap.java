package uk.ac.cam.spc55.Algorithms.Tick1;

import uk.ac.cam.cl.tester.Algorithms.EmptyHeapException;
import uk.ac.cam.cl.tester.Algorithms.MaxCharHeapInterface;

public class MaxCharHeap implements MaxCharHeapInterface {

    private char[] heap;
    private int length;

    public MaxCharHeap(char[] x) {
        length = x.length;
        heap = new char[1 << (32 - Integer.numberOfLeadingZeros(x.length))];
        for (int i = 0; i < x.length; i++) {
            heap[i] = x[i];
        }
        for (int i = length / 2; i >= 0; i--) {
            heapify(heap, length, i);
        }
    }

    @Override
    public char popMax() throws EmptyHeapException {
        if (length == 0) {
            throw new EmptyHeapException();
        }

        char c = heap[0];
        heap[0] = heap[--length];

        if (heap.length / 4 == length) {
            char[] temp = new char[heap.length / 2];
            for (int i = 0; i < temp.length; i++) {
                temp[i] = heap[i];
            }
            heap = temp;
        }

        heapify(heap, length, 0);

        return c;
    }

    private static void heapify(char[] x, int end, int root) {
        if (root * 2 + 1 < end) {
            if (root * 2 + 2 < end) {
                if (x[root] < x[root * 2 + 1] || x[root] < x[root * 2 + 2]) {
                    if (x[root * 2 + 1] > x[root * 2 + 2]) {
                        swap(x, root, root = root * 2 + 1);
                        heapify(x, end, root);
                    }
                    else {
                        swap(x, root, root = root * 2 + 2);
                        heapify(x, end, root);
                    }
                }
            } else {
                if ((x[root] < x[root * 2 + 1])) {
                    swap(x, root, root = root * 2 + 1);
                    heapify(x, end, root);
                }
            }
        }
    }

    private static void swap(char[] x, int index1, int index2) {
        char temp = x[index1];
        x[index1] = x[index2];
        x[index2] = temp;
    }

    @Override
    public int getLength() {
        return length;
    }

    @Override
    public void insert(char e) {
        if (length == heap.length) {
            char[] temp = new char[length * 2];
            for (int i = 0; i < length; i++) {
                temp[i] = heap[i];
            }
            heap = temp;
        }

        heap[length] = e;

        int pointer = length++;

        while (heap[(pointer - 1) / 2] < heap[pointer]) {
            swap(heap, pointer, pointer = (pointer - 1) / 2);
        }
    }
}
