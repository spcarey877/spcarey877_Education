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

package uk.ac.cam.spc55.palindromepairs;

import java.util.ArrayList;
import java.util.List;

public class Main {

  public static void main(String[] args) {
    System.out.println(findIndices(List.of("ab", "ba", "race", "car", "arac", "abba", "yuyu", "uyuy", "ainr", "brnia")));
  }

  private static List<IndexPair> findIndices(List<String> strings) {
    List<IndexPair> pairs = new ArrayList<>();

    for (int i = 0; i < strings.size(); i++) {
      for (int j = 0; j < strings.size(); j++) {
        if (i != j) {
          StringBuilder sb = new StringBuilder(strings.get(i) + strings.get(j));
          if (sb.toString().equals(sb.reverse().toString())) {
            pairs.add(new IndexPair(i, j));
          }
        }
      }
    }

    return pairs;
  }
}
