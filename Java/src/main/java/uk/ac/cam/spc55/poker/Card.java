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

import java.util.Objects;

/** Represents a playing card. */
class Card {
  enum Suit {
    DIAMONDS,
    CLUBS,
    HEARTS,
    SPADES
  }

  enum Value {
    TWO,
    THREE,
    FOUR,
    FIVE,
    SIX,
    SEVEN,
    EIGHT,
    NINE,
    TEN,
    JACK,
    QUEEN,
    KING,
    ACE
  }

  private final Suit suit;
  private final Value value;

  Card(Suit suit, Value value) {
    this.suit = suit;
    this.value = value;
  }

  Suit getSuit() {
    return suit;
  }

  Value getValue() {
    return value;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    Card card = (Card) o;
    return suit == card.suit && value == card.value;
  }

  @Override
  public int hashCode() {
    return Objects.hash(suit, value);
  }
}
