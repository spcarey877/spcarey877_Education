/*
 * Copyright 2020 David Berry <dgb37@cam.ac.uk>, Joe Isaacs <josi2@cam.ac.uk>, Andrew Rice <acr31@cam.ac.uk>, S.P. Carey
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

package uk.ac.cam.spc55.game_of_life;

import java.util.AbstractList;

class PackedLong extends AbstractList<Boolean> {

  private long packed;

  public PackedLong() {
    packed = 0;
  }

  public PackedLong(long base) {
    packed = base;
  }

  @Override
  public int size() {
    return 64;
  }

  @Override
  public Boolean get(int index) {
    if (index > 63) {
      return false;
    }
    return ((packed >> index) & 1) == 1;
  }


  @Override
  public Boolean set(int index, Boolean value) {
    if (index > 63) {
      return false;
    }
    if (value) {
      packed = packed | (1L << index);
    }
    else {
      packed = packed & ~(1L << index);
    }
    return true;
  }

  public long toLong() {
    return packed;
  }
}
