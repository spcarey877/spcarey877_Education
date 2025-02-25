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

public class ShapesTest {

  @Test
  public void identity_isCorrectSize() {
    // ARRANGE

    // ACT
    Matrix m = Shapes.identity(10);

    // ASSERT
    assertThat(m.height()).isEqualTo(10);
    assertThat(m.width()).isEqualTo(10);
  }

  @Test
  public void identity_isCorrect_for2x2() {
    // ARRANGE

    // ACT
    Matrix m = Shapes.identity(2);

    // ASSERT
    assertThat(m.get(0, 0)).isWithin(1e-7).of(1);
    assertThat(m.get(0, 1)).isWithin(1e-7).of(0);
    assertThat(m.get(1, 0)).isWithin(1e-7).of(0);
    assertThat(m.get(1, 1)).isWithin(1e-7).of(1);
  }

  @Test
  public void square_isCorrectSize() {
    // ARRANGE

    // ACT
    Matrix m = Shapes.square(10);

    // ASSERT
    assertThat(m.height()).isEqualTo(2);
    assertThat(m.width()).isEqualTo(4);
  }

  @Test
  public void square_isCorrect_forsize10() {
    // ARRANGE

    // ACT
    Matrix m = Shapes.square(10);

    // ASSERT
    assertThat(m.get(0, 0)).isWithin(1e-7).of(10);
    assertThat(m.get(0, 1)).isWithin(1e-7).of(-10);
    assertThat(m.get(0, 2)).isWithin(1e-7).of(-10);
    assertThat(m.get(0, 3)).isWithin(1e-7).of(10);
    assertThat(m.get(1, 0)).isWithin(1e-7).of(10);
    assertThat(m.get(1, 1)).isWithin(1e-7).of(10);
    assertThat(m.get(1, 2)).isWithin(1e-7).of(-10);
    assertThat(m.get(1, 3)).isWithin(1e-7).of(-10);
  }

  @Test
  public void rotation2d_isCorrectSize() {
    // ARRANGE

    // ACT
    Matrix m = Shapes.rotation2d(10);

    // ASSERT
    assertThat(m.height()).isEqualTo(2);
    assertThat(m.width()).isEqualTo(2);
  }

  @Test
  public void rotation2d_isCorrect_for10degrees() {
    // ARRANGE

    // ACT
    Matrix m = Shapes.rotation2d(10);

    // ASSERT
    assertThat(m.get(0, 0)).isWithin(1e-7).of(Math.cos(Math.toRadians(10)));
    assertThat(m.get(0, 1)).isWithin(1e-7).of(-Math.sin(Math.toRadians(10)));
    assertThat(m.get(1, 0)).isWithin(1e-7).of(Math.sin(Math.toRadians(10)));
    assertThat(m.get(1, 1)).isWithin(1e-7).of(Math.cos(Math.toRadians(10)));
  }
}
