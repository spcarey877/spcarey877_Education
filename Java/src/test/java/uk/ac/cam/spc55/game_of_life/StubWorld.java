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

class StubWorld implements World {
  @Override
  public int width() {
    throw new UnsupportedOperationException("World.width() should not be called");
  }

  @Override
  public int height() {
    throw new UnsupportedOperationException("World.height() should not be called");
  }

  @Override
  public boolean cellAlive(int col, int row) {
    throw new UnsupportedOperationException("World.cellAlive(int,int) should not be called");
  }

  @Override
  public World withCellAliveness(int col, int row, boolean aliveness) {
    throw new UnsupportedOperationException(
        "World.withCellAliveness(int,int,boolean) should not be called");
  }
}
