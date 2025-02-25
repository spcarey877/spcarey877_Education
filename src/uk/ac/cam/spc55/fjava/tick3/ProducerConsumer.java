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

class ProducerConsumer {
  private MessageQueue<Character> m = new UnsafeMessageQueue<Character>();

  private class Producer implements Runnable {
    char[] cl = "Department of Computer Science and Technology".toCharArray();

    public void run() {
      for (char c : cl) {
        m.put(c);
        try {
          Thread.sleep(500);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }
    }
  }

  private class Consumer implements Runnable {
    public void run() {
      while (true) {
        System.out.print(m.take());
        System.out.flush();
      }
    }
  }

  void execute() {
    new Thread(new Producer()).start();
    new Thread(new Consumer()).start();
  }

  public static void main(String[] args) {
    new ProducerConsumer().execute();
  }
}
