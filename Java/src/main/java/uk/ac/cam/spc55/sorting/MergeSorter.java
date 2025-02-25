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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

public class MergeSorter<T> implements Sorter<T> {
  @Override
  public void sort(T[] array, Comparator<T> comparator) {
    // TODO: implement merge sort
    splitMerge(Arrays.asList(array), comparator).toArray(array);
  }

  private List<T> splitMerge(List<T> array, Comparator<T> comparator) {
    int size = array.size();

    if (size <= 1) {
      return array;
    }

    return merge(splitMerge(array.subList(0, size / 2), comparator), splitMerge(array.subList(size / 2, size), comparator), comparator);
  }

  private List<T> merge(List<T> a1, List<T> a2, Comparator<T> comparator) {
    List<T> newlist = new ArrayList<>();
    int i = 0, j = 0;
    while(i < a1.size() && j < a2.size()) {
      if (comparator.compare(a1.get(i), a2.get(j)) < 0) {
        newlist.add(a1.get(i++));
      }
      else {
        newlist.add(a2.get(j++));
      }
    }

    if (i == a1.size()) {
      newlist.addAll(a2.subList(j, a2.size()));
    }
    else {
      newlist.addAll(a1.subList(i, a1.size()));
    }

    return newlist;
  }
}
