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

package uk.ac.cam.spc55.fjava.tick4;

import uk.ac.cam.cl.fjava.messages.Message;

import java.io.IOException;
import java.net.ServerSocket;

public class ChatServer {
  public static void main(String args[]) {
    if (args.length < 1) {
      System.out.println("Usage: java ChatServer <port>");
      return;
    }

    final int port;
    try {
      port = Integer.parseInt(args[0]);
    } catch (NumberFormatException e) {
      System.out.println("Usage: java ChatServer <port>");
      return;
    }

    if (port < 0 || port > 65535) {
      System.out.println("Usage: java ChatServer <port>");
      return;
    }

    MultiQueue<Message> messages = new MultiQueue<>();

    try (ServerSocket s = new ServerSocket(port)) {
      while (true) {
        try {
          new ClientHandler(s.accept(), messages);
        } catch (IOException e) {
          // Client ignored
        }
      }
    } catch (IOException e) {
      // Server closed
      e.printStackTrace();
    }

  }
}
