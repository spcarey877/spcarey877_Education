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
import static uk.ac.cam.spc55.game_of_life.WorldStringUtils.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class TinyWorldTest {

  @Test
  public void width_returns8() {
    // ARRANGE
    TinyWorld tinyWorld = new TinyWorld();

    // ACT
    int width = tinyWorld.width();

    // ASSERT
    assertThat(width).isEqualTo(8);
  }

  @Test
  public void cellAlive_returnsFalse_whenOutOfRange() {
    // ARRANGE
    TinyWorld tinyWorld = new TinyWorld();

    // ACT
    boolean cellAlive = tinyWorld.cellAlive(-1, 0);

    // ASSERT
    assertThat(cellAlive).isFalse();
  }

  @Test
  public void withCellAliveness_doesNotChangeOriginal() {
    // ARRANGE
    TinyWorld tinyWorld = new TinyWorld();

    // ACT
    tinyWorld.withCellAliveness(0, 0, true);

    // ASSERT
    assertThat(worldToString(tinyWorld))
        .isEqualTo(
            lines(
                "________",
                "________",
                "________",
                "________",
                "________",
                "________",
                "________",
                "________"));
  }

  @Test
  public void withCellAliveness_producesCorrectResult() {
    // ARRANGE
    TinyWorld tinyWorld = new TinyWorld();

    // ACT
    World newWorld = tinyWorld.withCellAliveness(0,0, true);
    newWorld = newWorld.withCellAliveness(1,1,true);

    // ASSERT
    assertThat(worldToString(newWorld)).isEqualTo(lines("#_______",
            "_#______",
            "________",
            "________",
            "________",
            "________",
            "________",
            "________"));
  }

  @Test
  public void nextGeneration_producesCorrectResult() {
    // ARRANGE
    World tinyWorld = WorldStringUtils.stringToWorld(new TinyWorld(), "##______",
            "#_______",
            "________",
            "________",
            "________",
            "________",
            "________",
            "________");


    // ACT
    World newWorld = tinyWorld.nextGeneration();

    // ASSERT
    assertThat(worldToString(newWorld)).isEqualTo(lines("##______",
            "##______",
            "________",
            "________",
            "________",
            "________",
            "________",
            "________"));
  }
}
