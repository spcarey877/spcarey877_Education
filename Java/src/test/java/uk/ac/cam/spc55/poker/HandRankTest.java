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
import static uk.ac.cam.spc55.poker.Card.Value;
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
import java.util.stream.Collectors;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class HandRankTest {

  private final List<Card> ROYAL_FLUSH =
      List.of(
          new Card(HEARTS, TEN),
          new Card(HEARTS, JACK),
          new Card(HEARTS, QUEEN),
          new Card(HEARTS, KING),
          new Card(HEARTS, ACE));
  private final List<Card> STRAIGHT_FLUSH =
      List.of(
          new Card(SPADES, TWO),
          new Card(SPADES, THREE),
          new Card(SPADES, FOUR),
          new Card(SPADES, FIVE),
          new Card(SPADES, SIX));
  private final List<Card> FOUR_OF_A_KIND =
      List.of(
          new Card(DIAMONDS, FIVE),
          new Card(HEARTS, FIVE),
          new Card(CLUBS, FIVE),
          new Card(SPADES, FIVE),
          new Card(SPADES, ACE));
  private final List<Card> FULL_HOUSE =
      List.of(
          new Card(DIAMONDS, EIGHT),
          new Card(HEARTS, EIGHT),
          new Card(CLUBS, EIGHT),
          new Card(DIAMONDS, ACE),
          new Card(SPADES, ACE));
  private final List<Card> STRAIGHT =
      List.of(
          new Card(DIAMONDS, TWO),
          new Card(HEARTS, THREE),
          new Card(CLUBS, FOUR),
          new Card(SPADES, FIVE),
          new Card(SPADES, SIX));
  private final List<Card> THREE_OF_A_KIND =
      List.of(
          new Card(DIAMONDS, FIVE),
          new Card(HEARTS, FIVE),
          new Card(CLUBS, FIVE),
          new Card(DIAMONDS, TWO),
          new Card(SPADES, ACE));
  private final List<Card> TWO_PAIR =
      List.of(
          new Card(DIAMONDS, FIVE),
          new Card(HEARTS, FIVE),
          new Card(HEARTS, TWO),
          new Card(DIAMONDS, TWO),
          new Card(SPADES, ACE));
  private final List<Card> ONE_PAIR =
      List.of(
          new Card(DIAMONDS, KING),
          new Card(HEARTS, FIVE),
          new Card(HEARTS, TWO),
          new Card(DIAMONDS, TWO),
          new Card(SPADES, ACE));
  private final List<Card> HIGH_CARD =
      List.of(
          new Card(DIAMONDS, KING),
          new Card(HEARTS, FIVE),
          new Card(HEARTS, TWO),
          new Card(DIAMONDS, TEN),
          new Card(SPADES, ACE));

  @Test
  public void royalFlush_matches_royalFlush() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.ROYAL_FLUSH.highCardsIfMatching(ROYAL_FLUSH);

    // ASSERT
    assertThat(highCards).containsExactly(new Card(HEARTS, ACE));
  }

  @Test
  public void straightFlush_matches_straightFlush() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.STRAIGHT_FLUSH.highCardsIfMatching(STRAIGHT_FLUSH);

    // ASSERT
    assertThat(highCards).containsExactly(new Card(SPADES, SIX));
  }

  @Test
  public void fourOfAKind_matches_fourOfAKind() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.FOUR_OF_A_KIND.highCardsIfMatching(FOUR_OF_A_KIND);

    // ASSERT
    List<Value> values = highCards.stream().map(Card::getValue).collect(Collectors.toList());
    assertThat(values).containsExactly(FIVE);
  }

  @Test
  public void fullHouse_matches_fullHouse() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.FULL_HOUSE.highCardsIfMatching(FULL_HOUSE);

    // ASSERT
    List<Value> values = highCards.stream().map(Card::getValue).collect(Collectors.toList());
    assertThat(values).containsExactly(EIGHT);
  }

  @Test
  public void straight_matches_straight() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.STRAIGHT.highCardsIfMatching(STRAIGHT);

    // ASSERT
    assertThat(highCards).containsExactly(new Card(SPADES, SIX));
  }

  @Test
  public void threeOfAKind_matches_threeOfAKind() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.THREE_OF_A_KIND.highCardsIfMatching(THREE_OF_A_KIND);

    // ASSERT
    List<Value> values = highCards.stream().map(Card::getValue).collect(Collectors.toList());
    assertThat(values).containsExactly(FIVE);
  }

  @Test
  public void twoPair_matches_twoPair() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.TWO_PAIR.highCardsIfMatching(TWO_PAIR);

    // ASSERT
    List<Value> values = highCards.stream().map(Card::getValue).collect(Collectors.toList());
    assertThat(values).containsExactly(FIVE, TWO, ACE);
  }

  @Test
  public void onePair_matches_onePair() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.ONE_PAIR.highCardsIfMatching(ONE_PAIR);

    // ASSERT
    List<Value> values = highCards.stream().map(Card::getValue).collect(Collectors.toList());
    assertThat(values).containsExactly(TWO, ACE, KING, FIVE);
  }

  @Test
  public void highCard_matches_highCard() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.HIGH_CARD.highCardsIfMatching(HIGH_CARD);

    // ASSERT
    List<Value> values = highCards.stream().map(Card::getValue).collect(Collectors.toList());
    assertThat(values).containsExactly(ACE, KING, TEN, FIVE, TWO);
  }

  @Test
  public void royalFlush_doesNotMatch_lowerHands() {
    // ARRANGE
    List<List<Card>> lowerHands =
        List.of(
            STRAIGHT_FLUSH,
            FOUR_OF_A_KIND,
            FULL_HOUSE,
            STRAIGHT,
            THREE_OF_A_KIND,
            TWO_PAIR,
            ONE_PAIR,
            HIGH_CARD);

    // ACT
    List<List<Card>> highCards =
        lowerHands.stream()
            .map(HandRank.ROYAL_FLUSH::highCardsIfMatching)
            .collect(Collectors.toList());

    // ASSERT
    assertThat(highCards).containsAnyIn(List.of(List.of()));
  }

  @Test
  public void straightFlush_doesNotMatch_lowerHands() {
    // ARRANGE
    List<List<Card>> lowerHands =
        List.of(
            FOUR_OF_A_KIND, FULL_HOUSE, STRAIGHT, THREE_OF_A_KIND, TWO_PAIR, ONE_PAIR, HIGH_CARD);

    // ACT
    List<List<Card>> highCards =
        lowerHands.stream()
            .map(HandRank.STRAIGHT_FLUSH::highCardsIfMatching)
            .collect(Collectors.toList());

    // ASSERT
    assertThat(highCards).containsAnyIn(List.of(List.of()));
  }

  @Test
  public void fourOfAKind_doesNotMatch_lowerHands() {
    // ARRANGE
    List<List<Card>> lowerHands =
        List.of(FULL_HOUSE, STRAIGHT, THREE_OF_A_KIND, TWO_PAIR, ONE_PAIR, HIGH_CARD);

    // ACT
    List<List<Card>> highCards =
        lowerHands.stream()
            .map(HandRank.FOUR_OF_A_KIND::highCardsIfMatching)
            .collect(Collectors.toList());

    // ASSERT
    assertThat(highCards).containsAnyIn(List.of(List.of()));
  }

  @Test
  public void fullHouse_doesNotMatch_lowerHands() {
    // ARRANGE
    List<List<Card>> lowerHands = List.of(STRAIGHT, THREE_OF_A_KIND, TWO_PAIR, ONE_PAIR, HIGH_CARD);

    // ACT
    List<List<Card>> highCards =
        lowerHands.stream()
            .map(HandRank.FULL_HOUSE::highCardsIfMatching)
            .collect(Collectors.toList());

    // ASSERT
    assertThat(highCards).containsAnyIn(List.of(List.of()));
  }

  @Test
  public void straight_doesNotMatch_lowerHands() {
    // ARRANGE
    List<List<Card>> lowerHands = List.of(THREE_OF_A_KIND, TWO_PAIR, ONE_PAIR, HIGH_CARD);

    // ACT
    List<List<Card>> highCards =
        lowerHands.stream()
            .map(HandRank.STRAIGHT::highCardsIfMatching)
            .collect(Collectors.toList());

    // ASSERT
    assertThat(highCards).containsAnyIn(List.of(List.of()));
  }

  @Test
  public void threeOfAKind_doesNotMatch_lowerHands() {
    // ARRANGE
    List<List<Card>> lowerHands = List.of(TWO_PAIR, ONE_PAIR, HIGH_CARD);

    // ACT
    List<List<Card>> highCards =
        lowerHands.stream()
            .map(HandRank.THREE_OF_A_KIND::highCardsIfMatching)
            .collect(Collectors.toList());

    // ASSERT
    assertThat(highCards).containsAnyIn(List.of(List.of()));
  }

  @Test
  public void twoPair_doesNotMatch_lowerHands() {
    // ARRANGE
    List<List<Card>> lowerHands = List.of(ONE_PAIR, HIGH_CARD);

    // ACT
    List<List<Card>> highCards =
        lowerHands.stream()
            .map(HandRank.TWO_PAIR::highCardsIfMatching)
            .collect(Collectors.toList());

    // ASSERT
    assertThat(highCards).containsAnyIn(List.of(List.of()));
  }

  @Test
  public void onePair_doesNotMatch_lowerHands() {
    // ARRANGE

    // ACT
    List<Card> highCards = HandRank.ONE_PAIR.highCardsIfMatching(HIGH_CARD);

    // ASSERT
    assertThat(highCards).isEmpty();
  }

  @Test
  public void highCardsIfMatching_returnsEmptyList_withPartialHand() {
    // ARRANGE
    List<Card> cards = List.of(new Card(DIAMONDS, FOUR));

    // ACT
    List<Card> results = HandRank.FOUR_OF_A_KIND.highCardsIfMatching(cards);

    // ASSERT
    assertThat(results).isEmpty();
  }
}
