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

public class BubbleSorter<T> implements Sorter<T> {

  @Override
  public void sort(T[] list, Comparator<T> comparator) {
    for (int i = 0; i < list.length; i++) {
      for (int j = i + 1; j < list.length; j++) {
        if (comparator.compare(list[i], list[j]) > 0) {
          T temp = list[i];
          list[i] = list[j];
          list[j] = temp;
        }
      }
    }
  }
}
