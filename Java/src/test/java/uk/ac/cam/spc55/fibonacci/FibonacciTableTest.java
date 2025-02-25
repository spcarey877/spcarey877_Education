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

import static com.google.common.truth.Truth.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class FibonacciTableTest {

  @Test
  public void fib_makesUseOfCache() {
    // Hint: use CountingMap!
    // ARRANGE
    CountingMap countingMap = new CountingMap();
    FibonacciTable fibonacciTable = new FibonacciTable(countingMap);

    // ACT
    fibonacciTable.fib(5);
    int result = countingMap.getCounter();

    // ASSERT
    assertThat(result).isAtLeast(1);
  }

  @Test
  public void fib_returns1_for1() {
    // ARRANGE
    FibonacciTable fibonacciTable = new FibonacciTable();

    // ACT
    int result = fibonacciTable.fib(1);

    // ASSERT
    assertThat(result).isEqualTo(1);
  }

  @Test
  public void fib_returns8_for6() {
    // ARRANGE
    FibonacciTable fibonacciTable = new FibonacciTable();

    // ACT
    int result = fibonacciTable.fib(6);

    // ASSERT
    assertThat(result).isEqualTo(8);
  }

  @Test
  public void fib_returns1_fornegative() {
    // ARRANGE
    FibonacciTable fibonacciTable = new FibonacciTable();

    // ACT
    int result = fibonacciTable.fib(-1);

    // ASSERT
    assertThat(result).isEqualTo(1);
  }
}
