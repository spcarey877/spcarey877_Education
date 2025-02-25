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

import static com.google.common.truth.Truth.assertThat;
import static uk.ac.cam.spc55.poker.Card.Suit.CLUBS;
import static uk.ac.cam.spc55.poker.Card.Suit.DIAMONDS;
import static uk.ac.cam.spc55.poker.Card.Suit.HEARTS;
import static uk.ac.cam.spc55.poker.Card.Suit.SPADES;
import static uk.ac.cam.spc55.poker.Card.Value.ACE;
import static uk.ac.cam.spc55.poker.Card.Value.EIGHT;
import static uk.ac.cam.spc55.poker.Card.Value.FIVE;
import static uk.ac.cam.spc55.poker.Card.Value.FOUR;
import static uk.ac.cam.spc55.poker.Card.Value.JACK;
import static uk.ac.cam.spc55.poker.Card.Value.KING;
import static uk.ac.cam.spc55.poker.Card.Value.QUEEN;
import static uk.ac.cam.spc55.poker.Card.Value.SIX;
import static uk.ac.cam.spc55.poker.Card.Value.TEN;
import static uk.ac.cam.spc55.poker.Card.Value.THREE;
import static uk.ac.cam.spc55.poker.Card.Value.TWO;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;
import org.junit.Test;

public class SimulatorTest {

  @Test
  public void simulate_shufflesEveryRound() {
    // ARRANGE
    AtomicInteger counter = new AtomicInteger(0);
    Consumer<List<Card>> countingShuffler =
        l -> {
          counter.incrementAndGet();
        };

    // ACT
    Simulator.simulate(Deck.create(countingShuffler), 104);

    // ASSERT
    assertThat(counter.get()).isEqualTo(104);
  }

  @Test
  public void simulate_countsDealtHands_inFiveRounds() {
    // ARRANGE
    Deck deck =
        Deck.create(
            l -> {
              // A 'shuffle' which rotates the deck by one hand - each time we shuffle we take five
              // cards off the top and put them on the back.
              for (int i = 0; i < 5; i++) {
                Card c = l.remove(0);
                l.add(c);
              }
            },
            // ROYAL_FLUSH
            new Card(HEARTS, TEN),
            new Card(HEARTS, JACK),
            new Card(HEARTS, QUEEN),
            new Card(HEARTS, KING),
            new Card(HEARTS, ACE),
            // STRAIGHT_FLUSH
            new Card(SPADES, TWO),
            new Card(SPADES, THREE),
            new Card(SPADES, FOUR),
            new Card(SPADES, FIVE),
            new Card(SPADES, SIX),
            // FOUR_OF_A_KIND
            new Card(DIAMONDS, FIVE),
            new Card(HEARTS, FIVE),
            new Card(CLUBS, FIVE),
            new Card(SPADES, FIVE),
            new Card(SPADES, ACE),
            // FULL_HOUSE
            new Card(DIAMONDS, EIGHT),
            new Card(HEARTS, EIGHT),
            new Card(CLUBS, EIGHT),
            new Card(DIAMONDS, ACE),
            new Card(SPADES, ACE),
            // STRAIGHT
            new Card(DIAMONDS, TWO),
            new Card(HEARTS, THREE),
            new Card(CLUBS, FOUR),
            new Card(SPADES, FIVE),
            new Card(SPADES, SIX));

    // ACT
    List<Count> tabulated = Simulator.simulate(deck, 5);

    // ASSERT
    assertThat(tabulated)
        .containsAtLeast(
            new Count(HandRank.ROYAL_FLUSH, 0.2, 1.0),
            new Count(HandRank.STRAIGHT_FLUSH, 0.2, 0.0),
            new Count(HandRank.FOUR_OF_A_KIND, 0.2, 0.0),
            new Count(HandRank.FULL_HOUSE, 0.2, 0.0),
            new Count(HandRank.STRAIGHT, 0.2, 0.0));
  }
}
