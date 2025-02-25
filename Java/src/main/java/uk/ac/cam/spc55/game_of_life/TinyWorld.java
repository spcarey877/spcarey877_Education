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

public final class TinyWorld implements World {

  PackedLong packedLong;

  TinyWorld() {
    packedLong = new PackedLong();
  }

  TinyWorld(PackedLong initial) {
    packedLong = new PackedLong(initial.toLong());
  }

  TinyWorld(TinyWorld initial) {
    new TinyWorld(initial.packedLong);
  }

  @Override
  public int width() {
    return 8;
  }

  @Override
  public int height() {
    return 8;
  }

  @Override
  public boolean cellAlive(int col, int row) {
    if (col < 0 || col >= 8 || row < 0 || row >= 8) {
      return false;
    }
    return packedLong.get(row * 8 + col);
  }

  @Override
  public TinyWorld withCellAliveness(int col, int row, boolean b) {
    TinyWorld newWorld = new TinyWorld(packedLong);
    if (!(col < 0 || row < 0 || col > 7 || row > 7)) {
      newWorld.packedLong.set(row * 8 + col, b);
    }
    return newWorld;
  }
}
