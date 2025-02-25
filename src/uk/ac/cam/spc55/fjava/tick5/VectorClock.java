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

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class VectorClock {

  private final Map<String, Integer> vectorClock;

  public VectorClock() {
    vectorClock = new HashMap<>();
  }

  public VectorClock(Map<String, Integer> existingClock) {
    vectorClock = new HashMap<>(existingClock);
  }

  public synchronized void updateClock(Map<String, Integer> msgClock) {
    for (String uid : msgClock.keySet()) {
      vectorClock.put(uid, Integer.max(msgClock.get(uid), vectorClock.getOrDefault(uid, 0)));
    }
  }

  public synchronized Map<String, Integer> incrementClock(String uid) {
    vectorClock.put(uid, vectorClock.getOrDefault(uid, 0) + 1);
    return Map.copyOf(vectorClock);
    // TODO: why is this required for thread safety
    // So that a message doesn't change the contents of the vector clock
  }

  public synchronized int getClock(String uid) {
    return vectorClock.getOrDefault(uid, 0);
  }

  public synchronized boolean happenedBefore(Map<String, Integer> other) {
    boolean happenedBefore = false;
    Set<String> uids = new HashSet<>();
    uids.addAll(vectorClock.keySet());
    uids.addAll(other.keySet());
    for (String uid : uids) {
      if (vectorClock.getOrDefault(uid, 0) < other.getOrDefault(uid, 0)) {
        happenedBefore = true;
      }
      else if (vectorClock.getOrDefault(uid, 0) > other.getOrDefault(uid, 0)) {
        return false;
      }
    }
    return happenedBefore;
  }

  public synchronized boolean happenedImmediatelyBefore(Map<String, Integer> other) {
    boolean happenedBefore = false;
    Set<String> uids = new HashSet<>();
    uids.addAll(vectorClock.keySet());
    uids.addAll(other.keySet());
    for (String uid : uids) {
      int vec = vectorClock.getOrDefault(uid, 0);
      int oth = other.getOrDefault(uid, 0);
      if (happenedBefore) {
        if (vec < oth) {
          return false;
        }
      }
      else {
        if (vec < oth) {
          if (vec != oth - 1) {
            return false;
          }
          happenedBefore = true;
        }
      }
    }
    return happenedBefore;
  }

  public synchronized boolean happenedBeforeOrEqual(Map<String, Integer> other) {
    Set<String> uids = new HashSet<>();
    uids.addAll(vectorClock.keySet());
    uids.addAll(other.keySet());
    for (String uid : uids) {
      int vec = vectorClock.getOrDefault(uid, 0);
      int oth = other.getOrDefault(uid, 0);
      if (oth > vec) {
        return true;
      }
    }
    return false;
  }
}
