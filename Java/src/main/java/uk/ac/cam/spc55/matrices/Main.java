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

public class Main {

  public static void main(String[] args) {

    Matrix points = Shapes.square(5);
    Matrix rotation = Shapes.rotation2d(10);
    TextDrawing textDrawing = new TextDrawing(60, 20);
    for (int i = 0; i < 10; i++) {
      textDrawing.clear();
      textDrawing.plot(points);
      System.out.println(textDrawing.draw());
      points = rotation.mult(points);
    }
  }
}
