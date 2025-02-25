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
public class MatrixTest {

  @Test
  public void add_producesCorrectAnswer() {
    // ARRANGE
    Matrix a =
        new Matrix(
            new double[][] {
              {1, 2, 3}, //
              {4, 5, 6}
            });
    Matrix b =
        new Matrix(
            new double[][] {
              {7, 8, 9}, //
              {10, 11, 12},
            });

    // ACT
    Matrix c = a.add(b);

    // ASSERT (tolerance for floating-point error)
    assertThat(c.get(0, 0)).isWithin(1E-7).of(8);
    assertThat(c.get(0, 1)).isWithin(1E-7).of(10);
    assertThat(c.get(0, 2)).isWithin(1E-7).of(12);
    assertThat(c.get(1, 0)).isWithin(1E-7).of(14);
    assertThat(c.get(1, 1)).isWithin(1E-7).of(16);
    assertThat(c.get(1, 2)).isWithin(1E-7).of(18);
  }

  @Test
  public void mult_producescorrectanswer() {
    // ARRANGE
    Matrix a = new Matrix(new double[][] {{1,0,1}, {0,1,0}});
    Matrix b = new Matrix(new double[][] {{1,0},{0,1},{1,0}});

    // ACT
    Matrix c = a.mult(b);

    // ASSERT
    assertThat(c.width()).isEqualTo(2);
    assertThat(c.height()).isEqualTo(2);
    assertThat(c.get(0,0)).isWithin(1E-7).of(2);
    assertThat(c.get(0,1)).isWithin(1E-7).of(0);
    assertThat(c.get(1,0)).isWithin(1E-7).of(0);
    assertThat(c.get(1,1)).isWithin(1E-7).of(1);
  }

  @Test
  public void transpose_producesCorrectAnswer() {
    // ARRANGE
    Matrix a = new Matrix(new double[][] {{1,1,1},{2,2,2}});

    // ACT
    Matrix b = a.transpose();

    // ASSERT
    assertThat(b.width()).isEqualTo(2);
    assertThat(b.height()).isEqualTo(3);
    assertThat(b.get(0,0)).isWithin(1E-7).of(1);
    assertThat(b.get(0,1)).isWithin(1E-7).of(2);
    assertThat(b.get(1,0)).isWithin(1E-7).of(1);
    assertThat(b.get(1,1)).isWithin(1E-7).of(2);
    assertThat(b.get(2,0)).isWithin(1E-7).of(1);
    assertThat(b.get(2,1)).isWithin(1E-7).of(2);
  }

  @Test
  public void is_immutable() {
    // ARRANGE
    double[][] elements = new double[][] {{1,1},{1,1}};
    Matrix a = new Matrix(elements);

    // ACT
    elements[0][0] = 2;

    // ASSERT
    assertThat(a.get(0,0)).isWithin(1E-7).of(1);
  }

  @Test
  public void mult_wrongdimensionsthrowsexception() {
    // ARRANGE
    Matrix a = new Matrix(new double[][] {{1,0,1}, {0,1,0}});
    Matrix b = new Matrix(new double[][] {{1,0,1}, {0,1,0}});

    // ACT
    boolean iae = false;
    try {
      a.mult(b);
    }
    catch (IllegalArgumentException e) {
      iae = true;
    }

    // ASSERT
    assertThat(iae).isTrue();
  }

  @Test
  public void add_wrongdimensionsthrowsexception() {
    // ARRANGE
    Matrix a = new Matrix(new double[][] {{1,0,1}, {0,1,0}});
    Matrix b = new Matrix(new double[][] {{1,0},{0,1},{1,0}});

    // ACT
    boolean iae = false;
    try {
      a.add(b);
    }
    catch (IllegalArgumentException e) {
      iae = true;
    }

    // ASSERT
    assertThat(iae).isTrue();
  }

  @Test
  public void height_producesCorrectAnswer () {
    // ARRANGE
    Matrix a = new Matrix(new double[][] {{1},{2},{3}});

    // ACT
    int result = a.height();

    // ASSERT
    assertThat(result).isEqualTo(3);
  }

  @Test
  public void width_producesCorrectAnswer () {
    // ARRANGE
    Matrix a = new Matrix(new double[][] {{1},{2},{3}});

    // ACT
    int result = a.width();

    // ASSERT
    assertThat(result).isEqualTo(1);
  }

  @Test
  public void toString_producesCorrectAnswer () {
    // ARRANGE
    Matrix a = new Matrix(new double[][] {{1},{2},{3}});

    // ACT
    String result = a.toString();

    // ASSERT
    assertThat(result).isEqualTo("[[1.0], [2.0], [3.0]]");
  }
}
