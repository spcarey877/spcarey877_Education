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

import java.util.ArrayList;
import java.util.List;

/** Static class for running the simulation. */
class Simulator {

  /** Simulate dealing a hand from the deck and record the outcome. */
  static List<Count> simulate(Deck deck, int rounds) {
    Odds odds = new Odds();
    List<Hand> hands = new ArrayList<>();
    for (int i = 0; i < rounds; i++) {
      deck.shuffle();
      Hand deal = deck.deal();
      hands.add(deal);
      odds.dealt(deal);
      if (i % 5 == 4) {
        odds.playGame(hands);
        hands.clear();
      }
    }
    return odds.tabulateByRank();
  }
}
