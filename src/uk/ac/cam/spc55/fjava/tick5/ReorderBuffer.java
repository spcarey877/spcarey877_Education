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

package uk.ac.cam.spc55.fjava.tick5;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import uk.ac.cam.cl.fjava.messages.Message;

public class ReorderBuffer {

  private final List<Message> buffer;
  private final VectorClock lastDisplayed;

  public void addMessage(Message m) {
    if (lastDisplayed.happenedBeforeOrEqual(m.getVectorClock())) {
      buffer.add(m);
    }
  }

  public ReorderBuffer(Map<String, Integer> initialMsg) {
    lastDisplayed = new VectorClock(initialMsg);
    buffer = new ArrayList<>();
  }

  public Collection<Message> pop() {
    Collection<Message> eligible = new ArrayList<>();
    Message next;
    do {
      next = null;
      for (Message m : buffer) {
        if (lastDisplayed.happenedImmediatelyBefore(m.getVectorClock())) {
          next = m;
          break;
        }
      }
      if (next != null) {
        buffer.remove(next);
        eligible.add(next);
        lastDisplayed.updateClock(next.getVectorClock());
      }
    } while (next != null);
    return eligible;
  }
}
