/*
 * Copyright 2020 Andrew Rice <acr31@cam.ac.uk>, Alastair Beresford <arb33@cam.ac.uk>, S.P. Carey
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

package uk.ac.cam.spc55.fjava.tick3;

import java.util.Arrays;
import java.util.Random;

public class BankSimulator {

  private class BankAccount {

    private int balance;
    private int acc;

    BankAccount(int accountNumber, int deposit) {
      balance = deposit;
      acc = accountNumber;
    }

    public int getAccountNumber() {
      return acc;
    }

    public void transferTo(BankAccount b, int amount) {
      if (getAccountNumber() > b.getAccountNumber()) {
        synchronized (this) {
          synchronized (b) {
            balance -= amount;
            b.balance += amount;
          }
        }
      }
      else {
        synchronized (b) {
          synchronized (this) {
            balance -= amount;
            b.balance += amount;
          }
        }
      }
    }
  }

  private static Random r = new Random();

  private class RoboTeller extends Thread {
    public void run() {
      // Robots work from 9am until 5pm; one customer per second
      for (int i = 9 * 60 * 60; i < 17 * 60 * 60; i++) {
        int a = r.nextInt(account.length);
        int b = r.nextInt(account.length);
        account[a].transferTo(account[b], r.nextInt(100));
      }
    }
  }

  private int capital;
  private BankAccount[] account;
  private RoboTeller[] teller;

  public BankSimulator(int capital, int accounts, int tellers) {
    this.capital = capital;
    this.account = new BankAccount[accounts];
    this.teller = new RoboTeller[tellers];
    for (int i = 0; i < account.length; i++) {
      account[i] = new BankAccount(i, capital / account.length);
    }
  }

  public int getCapital() {
    return capital;
  }

  public void runDay() {
    for (int i = 0; i < teller.length; i++) {
      teller[i] = new RoboTeller();
    }

    for (int i = 0; i < teller.length; i++) {
      teller[i].start();
    }

    int done = 0;
    while (done < teller.length) {
      try {
        teller[done].join();
        done++;
      } catch (InterruptedException e) {
        // IGNORED exception
      }
    }

    capital = Arrays.stream(account).mapToInt(a -> a.balance).sum();
  }

  public static void main(String[] args) {
    BankSimulator javaBank = new BankSimulator(10000, 10, 100);
    javaBank.runDay();
    System.out.printf("Capital at close: %d pounds%n", javaBank.getCapital());
  }
}
