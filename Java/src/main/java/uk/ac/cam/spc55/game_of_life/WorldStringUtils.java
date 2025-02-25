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

class WorldStringUtils {

  static String worldToString(World world) {
    StringBuilder b = new StringBuilder();
    for (int row = 0; row < world.height(); row++) {
      for (int col = 0; col < world.width(); col++) {
        b.append(world.cellAlive(col, row) ? "#" : "_");
      }
      b.append("\n");
    }
    return b.toString();
  }

  static World stringToWorld(World initial, String... lines) {
    World world = initial;
    for (int row = 0; row < lines.length; row++) {
      for (int col = 0; col < lines[row].length(); col++) {
        world = world.withCellAliveness(col, row, lines[row].charAt(col) != '_');
      }
    }
    return world;
  }

  static String lines(String... lines) {
    return String.join("\n", lines) + "\n";
  }

  // No instances
  private WorldStringUtils() {}
}
