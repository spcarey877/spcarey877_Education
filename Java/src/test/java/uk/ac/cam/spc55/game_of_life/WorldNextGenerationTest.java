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

import static com.google.common.truth.Truth.assertThat;

import org.junit.Test;

public class WorldNextGenerationTest {

  private static class TwoElementWorld extends StubWorld {
    boolean left;
    boolean right;

    TwoElementWorld(boolean left, boolean right) {
      this.left = left;
      this.right = right;
    }

    @Override
    public int width() {
      return 2;
    }

    @Override
    public int height() {
      return 1;
    }

    @Override
    public boolean cellAlive(int col, int row) {
      return col == 0 ? left : right;
    }

    @Override
    public World withCellAliveness(int col, int row, boolean aliveness) {
      if (col == 0) {
        return new TwoElementWorld(aliveness, right);
      } else {
        return new TwoElementWorld(left, aliveness);
      }
    }

    @Override
    public boolean cellAliveNextGeneration(int col, int row) {
      return true;
    }
  }

  @Test
  public void nextGeneration_hasAllCellsLive_whenCellAliveNextGenerationAlwaysTrue() {
    // ARRANGE
    TwoElementWorld world = new TwoElementWorld(false, false);

    // ACT
    World next = world.nextGeneration();

    // ASSERT
    assertThat(next.cellAlive(0, 0)).isTrue();
    assertThat(next.cellAlive(1, 0)).isTrue();
  }
}
