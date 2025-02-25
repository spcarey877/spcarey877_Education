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

package uk.ac.cam.spc55.fjava.tick1;


import java.io.*;
import java.net.Socket;
import java.net.UnknownHostException;

public class StringChat {
    public static void main(String[] args) {

        String server = null;
        int port = 0;

        if (args.length < 2) {
            System.err.println("This application requires two arguments: <machine> <port>");
            return;
        }

        server = args[0];

        try {
            port = Integer.parseInt(args[1]);
            if (port < 0 || port > 65535) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            System.err.println("This application requires two arguments: <machine> <port>");
            return;
        }

        final Socket s;

        try {
            s = new Socket(server, port);
        } catch (IOException e) {
            System.err.println("Cannot connect to " + server + " on port " + port);
            return;
        }

        InputStream out;
        try {
            out = s.getInputStream();
        } catch (IOException e) {
            return;
        }

        Thread output = new Thread() {

            InputStream outThread = out;

            @Override
            public void run() {

                while (true) {
                    try {
                        byte[] buffer = new byte[1024];
                        outThread.read(buffer);
                        System.out.println(new String(buffer));
                    } catch (IOException e) {
                        return;
                    }
                }
            }
        };
        output.setDaemon(true);
        output.start();

        BufferedReader r = new BufferedReader(new InputStreamReader(System.in));
        OutputStream in;
        try {
            in = s.getOutputStream();
        } catch (IOException e) {
            return;
        }

        while (true ) {

            try {
                in.write(r.readLine().getBytes());
            } catch (IOException e) {
                return;
            }
        }
    }
}
