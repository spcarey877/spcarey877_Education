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

public class QuickSorter<T> implements Sorter<T> {
  @Override
  public void sort(T[] array, Comparator<T> comparator) {
    // TODO: implement in-place quick sort without using temporary arrays
    quicksort(array, 0, array.length - 1, comparator);
  }

  private void quicksort(T[] array, int low, int high, Comparator<T> comparator) {
    if (low < high) {
      int p = partition(array, low, high, comparator);
      quicksort(array, low, p-1, comparator);
      quicksort(array, p+1, high, comparator);
    }
  }

  private int partition(T[] array, int low, int high, Comparator<T> comparator) {
    T pivot = array[high];
    int p = low;

    for (int i = low; i < high; i++) {
      if (comparator.compare(pivot, array[i]) > 0) {
        T temp = array[p];
        array[p] = array[i];
        array[i] = temp;
        p++;
      }
    }

    return p;
  }
}
