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

import static uk.ac.cam.spc55.poker.Card.Value.ACE;

import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Captures the different ranking of hands.
 *
 * <p>Each element of this enum contains a function which can be used to determine if a hand (as a
 * list of five cards) matches this rank. The function returns a list of cards. If its empty then
 * the hand does not match this rank. If its non-empty then the hand matches and the returned cards
 * should be used to break ties between two hands of the same rank.
 *
 * <p>For example: one-pair is a hand with two cards of the same value. If you have two players with
 * a one-pair then you have to break the tie between them. In this case this is done by first
 * comparing the value of the card in the pair and then the remaining 'side' cards in order or
 * magnitude. So, 2,2,3,5,10 beats 2,2,3,4,10: both are a one-pair, their pair card (2) is the same,
 * their highest 'side' card (10) is the same but their second highest cards are different (5 vs 4).
 * In this case the matching function would return [2,10,5,3] for the hand 2,2,3,5,10 and [2,10,4,3]
 * for 2,2,3,4,10.
 */
public enum HandRank {
  // This syntax means that the ROYAL_FLUSH enum element should be constructed with the matching
  // function HandRank::royalFlush
  ROYAL_FLUSH(HandRank::royalFlush),
  STRAIGHT_FLUSH(HandRank::straightFlush),
  FOUR_OF_A_KIND(HandRank::fourOfAkind),
  FULL_HOUSE(HandRank::fullHouse),
  FLUSH(HandRank::flush),
  STRAIGHT(HandRank::straight),
  THREE_OF_A_KIND(HandRank::threeOfAKind),
  TWO_PAIR(HandRank::twoPair),
  ONE_PAIR(HandRank::onePair),
  HIGH_CARD(HandRank::highCard);

  /**
   * Matching function for this rank.
   *
   * <p>Takes a list of cards representing a hand and returns either an empty list if it doesn't
   * match or a list containing the high cards for that rank.
   */
  private final Function<List<Card>, List<Card>> matcher;

  HandRank(Function<List<Card>, List<Card>> matcher) {
    this.matcher = matcher;
  }

  List<Card> highCardsIfMatching(List<Card> hand) {
    if (hand.size() != 5) {
      return List.of();
    }
    return matcher.apply(hand);
  }

  /**
   * A hand with a single high card, ties are broken by considering the values of the remaining
   * cards.
   */
  private static List<Card> highCard(List<Card> cards) {
    return cards.stream()
        .sorted(Comparator.comparing(Card::getValue).reversed())
        .collect(Collectors.toList());
  }

  /**
   * A hand containing two cards with the same value, ties are broken by considering the value of
   * the pair card and then the values of the remaining cards.
   */
  private static List<Card> onePair(List<Card> cards) {
    Collection<List<Card>> cardsWithSameValue =
        cards.stream().collect(Collectors.groupingBy(Card::getValue)).values();
    Optional<Card> pairCard =
        cardsWithSameValue.stream()
            .filter(v -> v.size() == 2)
            .map(v -> v.get(0))
            .max(Comparator.comparing(Card::getValue));
    if (pairCard.isEmpty()) {
      return List.of();
    }
    List<Card> otherCards =
        cardsWithSameValue.stream()
            .map(v -> v.get(0))
            .filter(v -> !v.equals(pairCard.get()))
            .sorted(Comparator.comparing(Card::getValue).reversed())
            .collect(Collectors.toList());
    return Stream.concat(pairCard.stream(), otherCards.stream()).collect(Collectors.toList());
  }

  /**
   * A hand containing two pairs of two cards with the same value, ties are broken by considering
   * the highest pair card, then the next pair card, then last card by value.
   */
  private static List<Card> twoPair(List<Card> cards) {
    Collection<List<Card>> groupedByValue =
        cards.stream().collect(Collectors.groupingBy(Card::getValue)).values();
    List<Card> cardsFromPairs =
        groupedByValue.stream()
            .filter(v -> v.size() == 2)
            .map(v -> v.get(0))
            .sorted(Comparator.comparing(Card::getValue).reversed())
            .collect(Collectors.toList());
    Optional<Card> remainingCard =
        groupedByValue.stream().filter(v -> v.size() == 1).findAny().map(v -> v.get(0));
    if (cardsFromPairs.size() == 2 && remainingCard.isPresent()) {
      return List.of(cardsFromPairs.get(0), cardsFromPairs.get(1), remainingCard.get());
    }
    return List.of();
  }

  /**
   * A hand containing three cards with the same value, ties are broken by considering the value of
   * the three-card.
   */
  private static List<Card> threeOfAKind(List<Card> cards) {
    Collection<List<Card>> groupedByValue =
        cards.stream().collect(Collectors.groupingBy(Card::getValue)).values();
    return groupedByValue.stream()
        .filter(v -> v.size() == 3)
        .findAny()
        .map(v -> List.of(v.get(0)))
        .orElse(List.of());
  }

  /**
   * A hand containing 5 cards (all with any suit) in numerical order, ties are broken by
   * considering the highest card.
   */
  private static List<Card> straight(List<Card> cards) {
    List<Card> sortedByValue =
        cards.stream().sorted(Comparator.comparing(Card::getValue)).collect(Collectors.toList());
    List<Integer> values =
        sortedByValue.stream()
            .map(Card::getValue)
            .map(Card.Value::ordinal)
            .collect(Collectors.toList());
    if (!numericalOrder(values)) {
      return List.of();
    }
    return List.of(sortedByValue.get(4));
  }

  /**
   * A hand containing 5 cards in numerical order with the same suit, ties are broken by the highest
   * card.
   */
  private static List<Card> straightFlush(List<Card> cards) {
    List<Card> highCards = straight(cards);
    if (highCards.isEmpty()) {
      return List.of();
    }
    boolean suited = cards.stream().map(Card::getSuit).distinct().count() == 1;
    if (!suited) {
      return List.of();
    }
    return highCards;
  }

  /**
   * A hand containing 5 cards in numerical order in the same suit ending on ACE.
   *
   * <p>This is an unbeatable hand, if you have two royal flushes then its a tie.
   */
  private static List<Card> royalFlush(List<Card> cards) {
    List<Card> highCards = straightFlush(cards);
    return highCards.stream().filter(c -> c.getValue().equals(ACE)).collect(Collectors.toList());
  }

  /**
   * A hand containing 5 cards in the same suit with any values, ties are broken by the highest
   * card.
   */
  private static List<Card> flush(List<Card> cards) {
    Collection<List<Card>> cardsWithSameSuit =
        cards.stream().collect(Collectors.groupingBy(Card::getSuit)).values();
    return cardsWithSameSuit.stream()
        .filter(v -> v.size() == 5)
        .findAny()
        .map(v -> List.of(Collections.max(v, Comparator.comparing(Card::getValue))))
        .orElse(List.of());
  }

  /** A hand containing a three and a pair, ties are broken by the three card. */
  private static List<Card> fullHouse(List<Card> cards) {
    Collection<List<Card>> cardsWithSameValue =
        cards.stream().collect(Collectors.groupingBy(Card::getValue)).values();
    Optional<Card> highFromThree =
        cardsWithSameValue.stream().filter(v -> v.size() == 3).findAny().map(v -> v.get(0));
    if (highFromThree.isEmpty()) {
      return List.of();
    }
    boolean hasPair = cardsWithSameValue.stream().anyMatch(v -> v.size() == 2);
    if (!hasPair) {
      return List.of();
    }
    return List.of(highFromThree.get());
  }

  /**
   * A hand containing four cards of the same value, ties are broken by the value of the four-cards.
   */
  private static List<Card> fourOfAkind(List<Card> cards) {
    Collection<List<Card>> cardsWithSameValue =
        cards.stream().collect(Collectors.groupingBy(Card::getValue)).values();
    return cardsWithSameValue.stream()
        .filter(v -> v.size() == 4)
        .map(v -> List.of(v.get(0)))
        .findAny()
        .orElse(List.of());
  }

  private static boolean numericalOrder(List<Integer> values) {
    int previous = values.get(0) - 1;
    for (int v : values) {
      if (v != previous + 1) {
        return false;
      }
      previous = v;
    }
    return true;
  }
}
