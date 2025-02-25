/*
 * Copyright 2020 Andrew Rice <acr31@cam.ac.uk>, Alastair Beresford <arb33@cam.ac.uk>, S.P. Carey
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package uk.ac.cam.spc55.fjava.tick3;

public class QueueTest {

  private class Producer extends Thread {
    private int sent = 0;

    public void run() {
      for (int i = 0; i < 50000; ++i) {
        q.put("" + i);
        sent++;
      }
    }

    public int numberProduced() {
      return sent;
    }
  }

  private class Consumer extends Thread {
    private int recv = 0;

    public void run() {
      while (!q.take().equals("EOF")) {
        recv++;
      }
      q.put("EOF");
    }

    public int numberConsumed() {
      return recv;
    }
  }

  private MessageQueue<String> q;
  private Consumer[] consumers;
  private Producer[] producers;

  QueueTest(MessageQueue<String> q, int c, int p) {
    this.q = q;
    consumers = new Consumer[c];
    for (int i = 0; i < c; ++i) {
      consumers[i] = new Consumer();
    }
    producers = new Producer[p];
    for (int i = 0; i < p; ++i) {
      producers[i] = new Producer();
    }
  }

  public void run() {

    for (Consumer c : consumers) {
      c.start();
    }

    for (Producer p : producers) {
      p.start();
    }

    for (Producer p : producers) {
      try {
        p.join();
      } catch (InterruptedException e) {
        // IGNORE exception
      }
    }
    q.put("EOF");
    // terminate join at 10 secs since EOF marker may get lost
    for (Consumer c : consumers) {
      try {
        c.join(10000);
      } catch (InterruptedException e) {
        // IGNORE exception
      }
    }

    int recv = 0;
    for (Consumer consumer : consumers) {
      recv += consumer.numberConsumed();
    }
    int sent = 0;
    for (Producer p : producers) {
      sent += p.numberProduced();
    }
    System.out.println(recv + " / " + sent);
  }

  public static void main(String[] args) {
     System.out.println("** UNSAFE ** ");
     new QueueTest(new UnsafeMessageQueue<String>(), 1, 1).run();
     new QueueTest(new UnsafeMessageQueue<String>(), 3, 1).run();
     new QueueTest(new UnsafeMessageQueue<String>(), 1, 3).run();
     new QueueTest(new UnsafeMessageQueue<String>(), 3, 3).run();

     System.out.println("** SAFE ** ");
     new QueueTest(new SafeMessageQueue<String>(), 1, 1).run();
     new QueueTest(new SafeMessageQueue<String>(), 3, 1).run();
     new QueueTest(new SafeMessageQueue<String>(), 1, 3).run();
     new QueueTest(new SafeMessageQueue<String>(), 3, 3).run();
  }
}
