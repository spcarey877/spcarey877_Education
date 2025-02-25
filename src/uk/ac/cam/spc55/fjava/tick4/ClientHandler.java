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

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.util.Random;

import uk.ac.cam.cl.fjava.messages.*;

public class ClientHandler {
  private Socket socket;
  private MultiQueue<Message> multiQueue;
  private String nickname;
  private MessageQueue<Message> clientMessages;
  private Boolean run;

  public ClientHandler(Socket s, MultiQueue<Message> q) throws IOException {
    socket = s;
    multiQueue = q;
    clientMessages = new SafeMessageQueue<>();
    nickname = "Anonymous" + (new Random().nextInt(89999) + 10000);
    run = true;

    Thread readThread = new ReadThread();
    Thread writeThread = new WriteThread();

    readThread.start();
    writeThread.start();

    multiQueue.register(clientMessages);
    multiQueue.put(new StatusMessage(nickname + " connected from " + socket.getInetAddress().getHostName() + "."));

  }


  private class ReadThread extends Thread {

    final ObjectInputStream readStream;

    ReadThread() throws IOException {
      readStream = new ObjectInputStream(socket.getInputStream());
    }

    @Override
    public void run() {
      try {
        while (run) {
          try {
            Object o = readStream.readObject();
            if (o instanceof ChangeNickMessage) {
              multiQueue.put(new StatusMessage(nickname + "is now known as " + (nickname = ((ChangeNickMessage) o).name) + "."));
            } else if (o instanceof ChatMessage) {
              multiQueue.put(new RelayMessage(nickname, (ChatMessage) o));
            }
          } catch (ClassNotFoundException e) {
            // ignore object
          }
        }
      } catch (IOException e) {
        synchronized (run) {
          if (run) {
            run = false;
            multiQueue.put(new StatusMessage(nickname + " has disconnected."));
            multiQueue.deregister(clientMessages);
          }
        }
      }
    }
  }

  private class WriteThread extends Thread {

    final ObjectOutputStream writeStream;

    WriteThread() throws IOException {
      writeStream = new ObjectOutputStream(socket.getOutputStream());
    }

    @Override
    public void run() {
      try {
        while (run) {
          Message m = clientMessages.take();
          writeStream.writeObject(m);
        }
      } catch(IOException e){
        synchronized (run) {
          if (run) {
            run = false;
            multiQueue.deregister(clientMessages);
            multiQueue.put(new StatusMessage(nickname + " has disconnected."));
          }
        }
      }
    }
  }
}
