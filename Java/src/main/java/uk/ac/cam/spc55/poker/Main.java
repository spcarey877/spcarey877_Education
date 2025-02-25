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

package uk.ac.cam.spc55.poker;

import java.util.List;

public class Main {

  public static void main(String[] args) {
    Deck deck = Deck.create();
    List<Count> counts = Simulator.simulate(deck, 100000);
    for (Count c : counts) {
      System.out.printf("%20s %2.2e %2.2e %n", c.getHandRank(), c.getDealProbability().doubleValue(), c.getWinProbability().doubleValue());
    }
  }
}
