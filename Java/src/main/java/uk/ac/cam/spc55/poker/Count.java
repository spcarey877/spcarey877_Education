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

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.Objects;

/** Used by the Odds object to return the probability for a particular kind of hand. */
class Count {
  private final HandRank handRank;

  private final BigDecimal dealProbability;

  private final BigDecimal winProbability;

  Count(HandRank handRank, double dealProbability, double winProbability) {
    this.handRank = handRank;
    // use a big decimal here to only store results to 4 digits of precision (among other things
    // this makes the equals method a bit less dicey)
    MathContext mathContext = new MathContext(4, RoundingMode.HALF_UP);
    this.dealProbability = new BigDecimal(dealProbability, mathContext);
    this.winProbability = new BigDecimal(winProbability, mathContext);
  }

  HandRank getHandRank() {
    return handRank;
  }

  BigDecimal getDealProbability() {
    return dealProbability;
  }

  BigDecimal getWinProbability() {
    return winProbability;
  }

  @Override
  public String toString() {
    return String.format("%s(%f, %f)", handRank, dealProbability, winProbability);
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    Count count = (Count) o;
    return handRank == count.handRank && dealProbability.equals(count.dealProbability) && winProbability.equals(count.winProbability);
  }

  @Override
  public int hashCode() {
    return Objects.hash(handRank, dealProbability, winProbability);
  }
}
