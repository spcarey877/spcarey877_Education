/*
 * Copyright 2020 David Berry <dgb37@cam.ac.uk>, S.P. Carey
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

package uk.ac.cam.spc55.sorting;

import static com.google.common.truth.Truth.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class TestInsertionSorter {

  @Test
  public void insertionSorter_sortsEmptyList() {
    // ARRANGE
    Integer[] array = new Integer[] {};

    // ACT
    new InsertionSorter<Integer>().sort(array, Integer::compare);

    // ASSERT
    assertThat(array).asList().isEmpty();
  }

  @Test
  public void insertionSorter_sortsAscendingIntegers() {
    // ARRANGE
    Integer[] array = new Integer[] {4, 1, 5, 7, 1};

    // ACT
    new InsertionSorter<Integer>().sort(array, Integer::compareTo);

    // ASSERT
    assertThat(array).asList().containsExactly(1, 1, 4, 5, 7);
  }

  @Test
  public void insertionSorter_sortsStrings() {
    // ARRANGE
    String[] array = new String[] {"one", "two", "three", "four"};

    // ACT
    new InsertionSorter<String>().sort(array, String::compareTo);

    // ASSERT
    assertThat(array).asList().containsExactly("four", "one", "three", "two");
  }
}
