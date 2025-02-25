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
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.function.Consumer;

/**
 * Represents a deck of cards.
 *
 * <p>Each deck contains a function for shuffling the deck - by default this actually shuffles the
 * deck but you can inject other functions for testing purposes.
 */
class Deck {

  /**
   * The shuffling function which takes a list of cards and returns void - the list is shuffled
   * in-place.
   */
  private final Consumer<List<Card>> shuffler;

  /** The cards in the deck. */
  private final List<Card> cards;

  /** How far through the deck we've got dealing out cards. */
  private int dealPosition;

  private Deck(Consumer<List<Card>> shuffler, List<Card> cards) {
    this.shuffler = shuffler;
    this.cards = cards;
    this.dealPosition = 0;
  }

  /** Creates a new deck with a standard set of cards and a normal shuffle. */
  static Deck create() {
    return create(Collections::shuffle);
  }

  /** Creates a new deck with a standard set of cards and some alternative shuffling function. */
  static Deck create(Consumer<List<Card>> shuffler) {
    List<Card> deck = new ArrayList<>();
    for (Card.Suit s : Card.Suit.values()) {
      for (Card.Value v : Card.Value.values()) {
        deck.add(new Card(s, v));
      }
    }
    return new Deck(shuffler, deck);
  }

  /** Creates a new deck with the specified shuffling function and cards. */
  static Deck create(Consumer<List<Card>> shuffler, Card... cards) {
    // wrap the cards in a linkedlist to make as much functionality available to the shuffler as
    // possible for testing (e.g. removing elements)
    return new Deck(shuffler, new LinkedList<>(Arrays.asList(cards)));
  }

  /** Shuffle the deck and reset the dealing position to start at the beginning. */
  void shuffle() {
    shuffler.accept(cards);
    dealPosition = 0;
  }

  /** Deal a hand of cards off the top and get ready to deal the next hand. */
  Hand deal() {
    Hand result = Hand.create(cards.subList(dealPosition, dealPosition + 5));
    dealPosition += 5;
    return result;
  }
}
