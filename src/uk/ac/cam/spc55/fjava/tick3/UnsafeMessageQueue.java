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

public class UnsafeMessageQueue<T> implements MessageQueue<T> {
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

  public void put(T val) {
    Link<T> newLink = new Link<>(val);
    if (first != null) {
      last.next = newLink;
    }
    else {
      first = newLink;
    }
    last = newLink;
  }

  public T take() {
    while (first == null) { // use a loop to block thread until data is available
      try {
        Thread.sleep(100);
      } catch (InterruptedException ie) {
        // Ignored exception
      }
    }
    T val = first.val;
    first = first.next;
    return val;
  }
}
