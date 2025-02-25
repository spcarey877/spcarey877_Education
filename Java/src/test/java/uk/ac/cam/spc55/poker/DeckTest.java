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
import static uk.ac.cam.spc55.poker.Card.Suit.DIAMONDS;
import static uk.ac.cam.spc55.poker.Card.Suit.SPADES;
import static uk.ac.cam.spc55.poker.Card.Value.EIGHT;
import static uk.ac.cam.spc55.poker.Card.Value.FIVE;
import static uk.ac.cam.spc55.poker.Card.Value.FOUR;
import static uk.ac.cam.spc55.poker.Card.Value.JACK;
import static uk.ac.cam.spc55.poker.Card.Value.NINE;
import static uk.ac.cam.spc55.poker.Card.Value.SEVEN;
import static uk.ac.cam.spc55.poker.Card.Value.SIX;
import static uk.ac.cam.spc55.poker.Card.Value.TEN;
import static uk.ac.cam.spc55.poker.Card.Value.THREE;
import static uk.ac.cam.spc55.poker.Card.Value.TWO;

import java.util.Collections;
import java.util.List;

import org.junit.Test;
import org.junit.experimental.theories.suppliers.TestedOn;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class DeckTest {

  @Test
  public void deal_returnsCardsInOrder_beforeShuffle() {
    // ARRANGE
    Deck deck =
        Deck.create(
            Collections::shuffle,
            new Card(SPADES, TWO),
            new Card(SPADES, THREE),
            new Card(SPADES, FOUR),
            new Card(SPADES, FIVE),
            new Card(SPADES, SIX),
            new Card(SPADES, SEVEN),
            new Card(SPADES, EIGHT),
            new Card(SPADES, NINE),
            new Card(SPADES, TEN),
            new Card(SPADES, JACK));

    // ACT
    Hand first = deck.deal();
    Hand second = deck.deal();

    // ASSERT
    assertThat(first.getCards())
        .containsExactly(
            new Card(SPADES, TWO),
            new Card(SPADES, THREE),
            new Card(SPADES, FOUR),
            new Card(SPADES, FIVE),
            new Card(SPADES, SIX))
        .inOrder();
    assertThat(second.getCards())
        .containsExactly(
            new Card(SPADES, SEVEN),
            new Card(SPADES, EIGHT),
            new Card(SPADES, NINE),
            new Card(SPADES, TEN),
            new Card(SPADES, JACK))
        .inOrder();
  }

  @Test
  public void shuffle_reordersCards() {
    // ARRANGE
    Deck deck =
        Deck.create(
            Collections::reverse,
            new Card(SPADES, TWO),
            new Card(SPADES, THREE),
            new Card(SPADES, FOUR),
            new Card(SPADES, FIVE),
            new Card(SPADES, SIX));

    // ACT
    deck.shuffle();
    Hand first = deck.deal();

    // ASSERT
    assertThat(first.getCards())
        .containsExactly(
            new Card(SPADES, SIX),
            new Card(SPADES, FIVE),
            new Card(SPADES, FOUR),
            new Card(SPADES, THREE),
            new Card(SPADES, TWO));
  }

  @Test
  public void shuffle_resetsPosition() {
    // ARRANGE
    Deck deck =
        Deck.create(
            l -> {},
            new Card(SPADES, TWO),
            new Card(SPADES, THREE),
            new Card(SPADES, FOUR),
            new Card(SPADES, FIVE),
            new Card(SPADES, SIX));

    // ACT
    deck.deal();
    deck.shuffle();
    Hand first = deck.deal();

    // ASSERT
    assertThat(first.getCards())
        .containsExactly(
            new Card(SPADES, TWO),
            new Card(SPADES, THREE),
            new Card(SPADES, FOUR),
            new Card(SPADES, FIVE),
            new Card(SPADES, SIX));
  }

  @Test
  public void create_dealsFirst5Cards() {
    // ARRANGE
    Deck deck = Deck.create();

    // ACT
    List<Card> hand = deck.deal().getCards();

    // ASSERT
    assertThat(hand).containsExactly(new Card(DIAMONDS, TWO),
            new Card(DIAMONDS, THREE),
            new Card(DIAMONDS, FOUR),
            new Card(DIAMONDS, FIVE),
            new Card(DIAMONDS, SIX));
  }
}
