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
public class FibonacciTest {

  @Test
  public void fibonacci_returns1_for1() {
    // ARRANGE
    Fibonacci fibonacci = new Fibonacci();

    // ACT
    int result = fibonacci.fib(1);

    // ASSERT
    assertThat(result).isEqualTo(1);
  }

  @Test
  public void fibonacci_returns8_for6() {
    // ARRANGE
    Fibonacci fibonacci = new Fibonacci();

    // ACT
    int result = fibonacci.fib(6);

    // ASSERT
    assertThat(result).isEqualTo(8);
  }

  @Test
  public void fibonacci_returns1_fornegative() {
    // ARRANGE
    Fibonacci fibonacci = new Fibonacci();

    // ACT
    int result = fibonacci.fib(-1);

    // ASSERT
    assertThat(result).isEqualTo(1);
  }
}
