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

import java.util.*;
import java.util.stream.Collectors;

/**
 * Class for counting the occurrences of a particular hand rank and tabulating their probabilities.
 */
class Odds {

  private Counter dealCount;
  private Counter winCount;
  private long totalDealt;

  Odds() {
    this.dealCount = new Counter();
    this.winCount = new Counter();
    this.totalDealt = 0;
  }

  /** Record that we have been dealt this hand. */
  void dealt(Hand hand) {
    dealCount.inc(hand);
    totalDealt++;
  }

  /** Finds and records the winning rank in the list of hands if there is one. */
  void playGame(List<Hand> hands) {
    Hand winner = hands.stream().min(Hand::compareTo).get();
    if (hands.stream().filter(h -> h.compareTo(winner) == 0).count() == 1) {
      winCount.inc(winner);
    }
  }

  /** Return a list of the probabilities for each defined hand rank. */
  List<Count> tabulateByRank() {
    return Arrays.stream(HandRank.values())
        .map(
            handRank -> {
              double count = dealCount.getOrDefault(handRank, 0L);
              double dealProbabilty = totalDealt == 0 ? 0 : count / totalDealt;
              double wins = winCount.getOrDefault(handRank, 0L);
              double winProbability = count == 0 ? 0 : wins / count;
              return new Count(handRank, dealProbabilty, winProbability);
            })
        .collect(Collectors.toList());
  }

  private static class Counter extends HashMap<HandRank, Long> {
    void inc(Hand hand) {
      compute(hand.getRank(), (k, v) -> v == null ? 1 : v + 1);
    }
  }
}
