/*
 * Copyright 2020 Andrew Rice <acr31@cam.ac.uk>, S.P. Carey
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

package uk.ac.cam.spc55.matrices;

/**
 * Simple object to render pixels as a String for printing to the screen.
 *
 * <p>Uses a co-ordinate system where (0,0) is in the middle of the picture
 */
class TextDrawing {

  private final int width;
  private final int height;
  private boolean[][] pixels;

  /**
   * Create a new instance.
   *
   * @param width the width of the drawing (in characters)
   * @param height the height of the drawing (in characters)
   */
  TextDrawing(int width, int height) {
    this.width = width;
    this.height = height;
    this.pixels = new boolean[this.height][this.width];
  }

  /** Reset the drawing to a blank canvas. */
  void clear() {
    pixels = new boolean[height][width];
  }

  /**
   * Plot the points specified by this matrix over the existing drawing.
   *
   * @param m a matrix with height 2. Elements in row 0 are y co-ordinates, elements in row 1 are x
   *     co-ordinates
   */
  void plot(Matrix m) {
    if (m.height() != 2) {
      throw new IllegalArgumentException(
          "Matrix height must be 2 but matrix was " + m.width() + "x" + m.height());
    }
    for (int p = 0; p < m.width(); p++) {
      int row = (int) Math.round(m.get(0, p));
      int col = (int) Math.round(m.get(1, p));
      pixels[row + height / 2][col + width / 2] = true;
    }
  }

  /** Render the current drawing to a string suitable for printing to the screen. */
  String draw() {
    StringBuilder result = new StringBuilder();
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        result.append(pixels[row][col] ? "#" : ".");
      }
      result.append(System.lineSeparator());
    }
    return result.toString();
  }
}
