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
import static uk.ac.cam.spc55.poker.Card.Value.*;

import java.util.List;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class HandTest {

  @Test
  public void createHand_classifiesRank_withStraight() {
    // ARRANGE
    List<Card> straight =
        List.of(
            new Card(DIAMONDS, TWO),
            new Card(HEARTS, THREE),
            new Card(CLUBS, FOUR),
            new Card(SPADES, FIVE),
            new Card(SPADES, SIX));

    // ACT
    Hand hand = Hand.create(straight);

    // ASSERT
    assertThat(hand.getRank()).isEqualTo(HandRank.STRAIGHT);
  }

  @Test
  public void compareTo_returns_tiedHands() {
    // ARRANGE
    List<Card> royalFlush1 = List.of(new Card(DIAMONDS, ACE),
            new Card(DIAMONDS, KING),
            new Card(DIAMONDS, QUEEN),
            new Card(DIAMONDS, JACK),
            new Card(DIAMONDS, TEN));

    List<Card> royalFlush2 = List.of(new Card(DIAMONDS, ACE),
            new Card(DIAMONDS, KING),
            new Card(DIAMONDS, QUEEN),
            new Card(DIAMONDS, JACK),
            new Card(DIAMONDS, TEN));

    // ACT
    Hand hand1 = Hand.create(royalFlush1);
    Hand hand2 = Hand.create(royalFlush2);
    int result = hand1.compareTo(hand2);

    // ASSERT
    assertThat(result).isEqualTo(0);
  }

  @Test
  public void compareTo_greaterThan1_forSameRank() {
    // ARRANGE
    List<Card> highStraight = List.of(new Card(DIAMONDS, KING),
            new Card(CLUBS, QUEEN),
            new Card(DIAMONDS, JACK),
            new Card(CLUBS, TEN),
            new Card(DIAMONDS, NINE));

    List<Card> lowStraight = List.of(new Card(DIAMONDS, EIGHT),
            new Card(DIAMONDS, SEVEN),
            new Card(CLUBS, SIX),
            new Card(DIAMONDS, FIVE),
            new Card(CLUBS, FOUR));

    // ACT
    Hand hand1 = Hand.create(highStraight);
    Hand hand2 = Hand.create(lowStraight);
    int result = hand1.compareTo(hand2);

    // ASSERT
    assertThat(result).isGreaterThan(0);
  }

  @Test
  public void compareTo_lessThan1_forSameRank() {
    // ARRANGE
    List<Card> highStraight = List.of(new Card(DIAMONDS, KING),
            new Card(CLUBS, QUEEN),
            new Card(DIAMONDS, JACK),
            new Card(CLUBS, TEN),
            new Card(DIAMONDS, NINE));

    List<Card> lowStraight = List.of(new Card(DIAMONDS, EIGHT),
            new Card(DIAMONDS, SEVEN),
            new Card(CLUBS, SIX),
            new Card(DIAMONDS, FIVE),
            new Card(CLUBS, FOUR));

    // ACT
    Hand hand1 = Hand.create(lowStraight);
    Hand hand2 = Hand.create(highStraight);
    int result = hand1.compareTo(hand2);

    // ASSERT
    assertThat(result).isLessThan(0);
  }
}
