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

import java.util.Objects;

class IndexPair {
  private final int left;
  private final int right;

  IndexPair(int left, int right) {
    this.left = left;
    this.right = right;
  }

  int left() {
    return left;
  }

  int right() {
    return right;
  }

  @Override
  public String toString() {
    // HINT: overriding to string can give us some nicer console output.
    // modify the code below to print out a the pair into the console.
    return "(" + left + " " + right + ")";
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    IndexPair indexPair = (IndexPair) o;
    return left == indexPair.left && right == indexPair.right;
  }

  @Override
  public int hashCode() {
    return Objects.hash(left, right);
  }
}
