/*
 * Copyright 2020 David Berry <dgb37@cam.ac.uk>, Joe Isaacs <josi2@cam.ac.uk>, Andrew Rice <acr31@cam.ac.uk>, S.P. Carey
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

package uk.ac.cam.spc55.game_of_life;

import java.util.ArrayList;
import java.util.List;

public class MainPackedLong {

  public static void main(String[] args) {
    PackedLong board = new PackedLong(Long.parseLong(args[0]));
    int position = Integer.parseInt(args[1]);
    boolean value = Boolean.parseBoolean(args[2]);

    PackedLong initialValue = new PackedLong(board.toLong());
    board.set(position, value);
    PackedLong updatedValue = new PackedLong(board.toLong());

    System.out.printf("Setting position %d to %s gives %s%n", position, value, updatedValue);
    System.out.printf("Initial: %s%n", getAllPositions(initialValue));
    System.out.printf("Final:   %s%n", getAllPositions(updatedValue));
  }

  private static String getAllPositions(PackedLong packedLong) {
    List<String> all = new ArrayList<>();
    for (int i = 0; i < 64; i++) {
      all.add(String.valueOf(packedLong.get(i) ? 1 : 0));
    }
    return String.join(",", all);
  }
}
