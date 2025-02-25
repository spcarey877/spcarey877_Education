/*
 * Copyright 2020 David Berry <dgb37@cam.ac.uk>, Joe Isaacs <josi2@cam.ac.uk>, Andrew Rice <acr31@cam.ac.uk>, S.P. Carey
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

package uk.ac.cam.spc55.game_of_life;

import static com.google.common.truth.Truth.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class PackedLongTest {
  @Test
  public void set_onlyChangesAffectedPosition() {
    // ARRANGE
    PackedLong initial = new PackedLong(0xF00000000000000FL);

    // ACT
    initial.set(4, true);
    long updated = initial.toLong();

    // ASSERT
    assertThat(updated).isEqualTo(0xF00000000000001FL);
  }

  @Test
  public void clear_onlyChangesAffectedPosition() {
    // ARRANGE
    PackedLong initial = new PackedLong(0xF00000000000001FL);

    // ACT
    initial.set(4, false);
    long updated = initial.toLong();

    // ASSERT
    assertThat(updated).isEqualTo(0xF00000000000000FL);
  }

  @Test
  public void set_setsHighestBit_atPosition63() {
    // ARRANGE
    PackedLong initial = new PackedLong(0x0000000000000000L);

    // ACT
    initial.set(63, true);
    long updated = initial.toLong();

    // ASSERT
    assertThat(updated).isEqualTo(0x8000000000000000L);
  }

  @Test
  public void get_getsHighestBit_whenPosition63IsSet() {
    // ARRANGE
    PackedLong initial = new PackedLong(0x8000000000000000L);

    // ACT
    boolean value = initial.get(63);

    // ASSERT
    assertThat(value).isTrue();
  }

  @Test
  public void get_getsHighestBit_whenPosition63IsClear() {
    // ARRANGE
    PackedLong initial = new PackedLong(0x7000000000000000L);

    // ACT
    boolean value = initial.get(63);

    // ASSERT
    assertThat(value).isFalse();
  }

  @Test
  public void constructor_defaultis0() {
    // ARRANGE
    PackedLong initial = new PackedLong();

    // ACT
    long value = initial.toLong();

    // ASSERT
    assertThat(value).isEqualTo(0x0000000000000000L);
  }

  @Test
  public void size_is64() {
    // ARRANGE
    PackedLong initial = new PackedLong();

    // ACT
    int size = initial.size();

    // ASSERT
    assertThat(size).isEqualTo(64);
  }

  @Test
  public void set_falseifoutofrange64() {
    // ARRANGE
    PackedLong initial = new PackedLong();

    // ACT
    boolean set = initial.set(64, true);

    // ASSERT
    assertThat(set).isFalse();
  }

  @Test
  public void get_falseifoutofrange64() {
    // ARRANGE
    PackedLong initial = new PackedLong(0xFFFFFFFFFFFFFFFFL);

    // ACT
    boolean set = initial.get(64);

    // ASSERT
    assertThat(set).isFalse();
  }
}
