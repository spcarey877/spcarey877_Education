/*
 * Copyright 2020 Andrew Rice <acr31@cam.ac.uk>, S.P. Carey
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

package uk.ac.cam.spc55.fibonacci;

import java.util.HashMap;

/** A map that also counts the number of times that someone successfully looks up a value. */
class CountingMap extends HashMap<Integer, Integer> {
  private int counter = 0;

  @Override
  public Integer get(Object key) {
    Integer result = super.get(key);
    if (result != null) {
      counter++;
    }
    return result;
  }

  int getCounter() {
    return counter;
  }
}
