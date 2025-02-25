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

import static uk.ac.cam.spc55.game_of_life.WorldStringUtils.stringToWorld;
import static uk.ac.cam.spc55.game_of_life.WorldStringUtils.worldToString;

public class MainTinyWorld {

  public static void main(String[] args) {

    World w =
        stringToWorld(
            new TinyWorld(),
            "________",
            "________",
            "____#___",
            "_____#__",
            "___###__",
            "________",
            "________",
            "________");

    for (int i = 0; i < 5; i++) {
      System.out.println(worldToString(w));
      w = w.nextGeneration();
    }
  }
}
