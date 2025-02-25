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

package uk.ac.cam.spc55.fjava.tick2;

import java.io.*;
import java.net.MalformedURLException;
import java.net.Socket;
import java.net.URL;
import java.net.URLConnection;

class TestMessageReadWrite {

  static boolean writeMessage(String message, String filename) {
    TestMessage m = new TestMessage();
    m.setMessage(message);

    try {
      ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(filename));
      out.writeObject(m);
      out.close();
    } catch (IOException e) {
      return false;
    }

    return true;
  }

  static String readMessage(String location) {
    if (location.startsWith("http://") || location.startsWith("https://")) {
      try (ObjectInputStream in = new ObjectInputStream(new URL(location).openStream())) {
        TestMessage m = (TestMessage) in.readObject();
        return m.getMessage();
      } catch (IOException | ClassNotFoundException e) {
        return null;
      }
    }
    else {
      try (ObjectInputStream in = new ObjectInputStream(new FileInputStream(location))) {
        TestMessage m = (TestMessage)in.readObject();
        return m.getMessage();
      } catch (IOException | ClassNotFoundException e) {
        return null;
      }
    }
  }

  public static void main(String args[]) {
    String s = readMessage("https://www.cl.cam.ac.uk/teaching/current/FJava/testmessage/spc55.jobj");
    System.out.println(s);
    System.out.println(writeMessage(s, "Message.jobj"));
    String s2 = readMessage("Message.jobj");
    System.out.println(s2);
  }
}
