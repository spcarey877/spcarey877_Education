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

public class CompositeWorld implements World {

  private final TinyWorld[][] worlds;

  private final int width;
  private final int height;

  /**
   * Creates a new instance of the world.
   *
   * <p>Note that the width and height parameters here correspond to the number of TinyWorld objects
   * to use rather than the number of cells.
   *
   * @param width the number of columns of TinyWorld objects to use
   * @param height the number of rows of TinyWorld objects to use
   */
  CompositeWorld(int width, int height) {
    this.height = height;
    this.width = width;
    worlds = new TinyWorld[height][width];

    for (int col = 0; col < width; col++) {
      for (int row = 0; row < height; row++) {
        worlds[row][col] = new TinyWorld();
      }
    }
  }

  CompositeWorld(CompositeWorld initial) {
    this.width = initial.width;
    this.height = initial.height;
    worlds = new TinyWorld[initial.height][initial.width];

    System.out.println(width());
    System.out.println(height());

    for (int row = 0; row < initial.height; row++) {
      for (int col = 0; col < initial.width; col++) {
        worlds[row][col] = new TinyWorld(initial.worlds[row][col]);
      }
    }
  }

  @Override
  public int width() {
    return width * 8;
  }

  @Override
  public int height() {
    return height * 8;
  }

  @Override
  public boolean cellAlive(int col, int row) {
    if (col < 0 || row < 0 || col > width() || row > height()) {
      return false;
    }
    return worlds[row / 8][col / 8].cellAlive(col % 8, row % 8);
  }

  @Override
  public CompositeWorld withCellAliveness(int col, int row, boolean b) {
    CompositeWorld newWorld = new CompositeWorld(this);
    if (col < 0 || row < 0 || col > width() || row > height()) {
      return newWorld;
    }
    newWorld.worlds[row / 8][col / 8] = newWorld.worlds[row / 8][col / 8].withCellAliveness(col % 8, row % 8, b);
    return newWorld;
  }
}
