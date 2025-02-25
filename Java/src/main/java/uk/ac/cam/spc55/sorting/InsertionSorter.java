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

import java.util.Comparator;

public class InsertionSorter<T> implements Sorter<T> {

  @Override
  public void sort(T[] array, Comparator<T> comparator) {
    // TODO: implement in-place insertion sort without using a temporary array

    for (int i = 1; i < array.length; i++) {
      for (int j = i; j > 0 && comparator.compare(array[j], array[j-1]) < 0; j--) {
        T temp = array[j-1];
        array[j-1] = array[j];
        array[j] = temp;
      }
    }
  }
}
