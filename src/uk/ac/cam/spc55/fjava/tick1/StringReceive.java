package uk.ac.cam.spc55.fjava.tick1;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;
import java.net.UnknownHostException;

public class StringReceive {

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

        BufferedReader r = null;
        try {
            r = new BufferedReader(new InputStreamReader(s.getInputStream()));
        } catch (IOException e) {
            return;
        }

        while (true) {
            try {
                System.out.println(r.readLine());
            } catch (IOException e) {
                return;
            }
        }
    }

}
