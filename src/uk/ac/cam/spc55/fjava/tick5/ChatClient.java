package uk.ac.cam.spc55.fjava.tick5;

import uk.ac.cam.cl.fjava.messages.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectOutputStream;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;


public class ChatClient {

    private static final SimpleDateFormat format = new SimpleDateFormat("kk:mm:ss");

    private static String uuid;

    private static VectorClock vectorClock;
    private static ReorderBuffer reorderBuffer;

    public static void main(String[] args) {

        String serverName;
        int portNumber;

        if (args.length < 2) {
            System.err.println("This application requires two arguments: <machine> <port>");
            return;
        }

        serverName = args[0];
        try {
            portNumber = Integer.parseInt(args[1]);
            if (portNumber < 0 || portNumber > 65535) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            System.err.println("This application requires two arguments: <machine> <port>");
            return;
        }

        try (Socket s = new Socket(serverName, portNumber)) {
            uuid = java.util.UUID.randomUUID().toString();
            vectorClock = new VectorClock();
            reorderBuffer = null;
            printMessage("Connected to " + serverName + " on port " + portNumber + ".");
            Thread inputThread = new Thread() {
                @Override
                public void run() {
                    try (DynamicObjectInputStream in = new DynamicObjectInputStream(s.getInputStream())){
                        while (true) {
                            Object m;
                            if ((m = in.readObject()) instanceof Message) {
                                if (reorderBuffer != null) {
                                    reorderBuffer.addMessage((Message) m);
                                }
                                else {
                                    reorderBuffer = new ReorderBuffer(((Message) m).getVectorClock());
                                    if (m instanceof RelayMessage) {
                                        printMessage((RelayMessage)m);
                                    }
                                    else if (m instanceof StatusMessage) {
                                        printMessage((StatusMessage)m);
                                    }
                                    else {
                                        printMessage((Message)m);
                                    }
                                }
                                vectorClock.updateClock(((Message) m).getVectorClock());

                            }
                            Collection<Message> ms = reorderBuffer.pop();
                            if (!(ms.isEmpty())){
                                for (Message message : ms) {
                                    if (message instanceof RelayMessage) {
                                        printMessage((RelayMessage)message);
                                    }
                                    else if (message instanceof StatusMessage) {
                                        printMessage((StatusMessage)message);
                                    }
                                    else {
                                        printMessage(message);
                                    }
                                }
                            }
                        }
                    } catch (IOException | ClassNotFoundException e) {
                        return;
                    }
                }
            };
            inputThread.setDaemon(true);
            inputThread.start();

            BufferedReader r = new BufferedReader(new InputStreamReader(System.in));
            try (ObjectOutputStream out = new ObjectOutputStream(s.getOutputStream())) {
                String input;
                while (!(input = r.readLine()).equals("\\quit")) {
                    if (input.startsWith("\\")) {
                        if (input.substring(1).startsWith("nick")) {
                            if (input.length() < 6) {
                                printMessage("Invalid nickname");
                            } else {
                                out.writeObject(new ChangeNickMessage(input.substring(6), uuid,  vectorClock.incrementClock(uuid)));
                            }
                        }
                        else {
                            printMessage("Unknown command \"" + input.split("\\s+")[0].substring(1) + "\"");
                        }
                    } else {
                        out.writeObject(new ChatMessage(input, uuid, vectorClock.incrementClock(uuid)));
                    }
                }
            } catch (IOException ignored) {

            }
        } catch (IOException ignored) {
            System.err.println("Cannot connect to " + serverName + " on port " + portNumber);
        }
        printMessage("Connection terminated");
    }

    private static void printMessage(RelayMessage m) {
        printMessage(m.getMessage(), m.getFrom(), m.getCreationTime());
    }

    private static void printMessage(StatusMessage m) {
        printMessage(m.getMessage(), "Server", m.getCreationTime());
    }

    private static void printMessage(String message) {
        printMessage(message, "Client", new Date());
    }

    private static void printMessage(String message, String from, Date time) {
        System.out.println(format.format(time) + " [" + from + "] " + message);
    }

    private static void printMessage(Message m) {
        System.out.println(format.format(m.getCreationTime()) + " " + m.getClass().toString());
    }
}
