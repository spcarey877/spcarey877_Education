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

import java.util.Arrays;

public class Main {

  public static void main(String[] args) {
    Integer[] ints = new Integer[] {4, 5, 2, 1, 5, 8, 8, 2};
    new MergeSorter<Integer>().sort(ints, Integer::compare);
    System.out.println(Arrays.toString(ints));

    String[] strings =
        new String[] {"apples", "Pears", "Oranges", "Bananas", "Grapes", "Raspberries"};
    new InsertionSorter<String>().sort(strings, String::compareTo);
    System.out.println(Arrays.toString(strings));

    new QuickSorter<String>().sort(strings, String::compareToIgnoreCase);
    System.out.println(Arrays.toString(strings));

    Double[] doubles = new Double[] {5.0, -10.2, 6.6666, 7.1, 7.11};
    new BubbleSorter<Double>().sort(doubles, Double::compareTo);
    System.out.println(Arrays.toString(doubles));
  }
}
