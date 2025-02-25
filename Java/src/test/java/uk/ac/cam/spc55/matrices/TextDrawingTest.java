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

package uk.ac.cam.spc55.matrices;

import static com.google.common.truth.Truth.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class TextDrawingTest {

  @Test
  public void draw_createsStringOfExpectedSize() {
    // ARRANGE
    TextDrawing textDrawing = new TextDrawing(10, 5);

    // ACT
    String drawing = textDrawing.draw();

    // ASSERT
    String[] lines = drawing.split(System.lineSeparator());
    assertThat(lines.length).isEqualTo(5);
    assertThat(lines[0].length()).isEqualTo(10);
  }

  @Test
  public void draw_createsOnlyDots_forEmptyCanvas() {
    // ARRANGE
    TextDrawing textDrawing = new TextDrawing(2, 2);

    // ACT
    String drawing = textDrawing.draw();

    // ASSERT
    assertThat(drawing).isEqualTo(String.format("..%n..%n"));
  }

  @Test
  public void draw_createsOnlyHashes_forFullCanvas() {
    // ARRANGE
    TextDrawing textDrawing = new TextDrawing(2, 2);

    // ACT
    textDrawing.plot(
        new Matrix(
                new double[][] {
                  {-1, -1},
                  {-1, 0},
                  {0, 0},
                  {0, -1},
                })
            .transpose());
    String drawing = textDrawing.draw();

    // ASSERT
    assertThat(drawing).isEqualTo(String.format("##%n##%n"));
  }

  @Test
  public void clear_resetsCanvas() {
    // ARRANGE
    TextDrawing textDrawing = new TextDrawing(2, 2);

    // ACT
    textDrawing.plot(
        new Matrix(
                new double[][] {
                  {-1, -1},
                  {-1, 0},
                  {0, 0},
                  {0, -1},
                })
            .transpose());
    textDrawing.clear();
    String drawing = textDrawing.draw();

    // ASSERT
    assertThat(drawing).isEqualTo(String.format("..%n..%n"));
  }
}
