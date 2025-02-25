package uk.ac.cam.spc55.fjava.tick2;

import uk.ac.cam.cl.fjava.messages.*;

import java.io.*;
import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Date;

@FurtherJavaPreamble(author = "Sean Carey", date = "28th October 2020", crsid = "spc55", summary = "", ticker = FurtherJavaPreamble.Ticker.D)
public class ChatClient {

    private static final SimpleDateFormat format = new SimpleDateFormat("kk:mm:ss");

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
            printMessage("Connected to " + serverName + " on port " + portNumber + ".");
            Thread inputThread = new Thread() {
                @Override
                public void run() {
                    try (DynamicObjectInputStream in = new DynamicObjectInputStream(s.getInputStream())){
                        while (true) {
                            Object m;
                            if ((m = in.readObject()) instanceof RelayMessage) {
                                printMessage((RelayMessage) m);
                            }
                            else if (m instanceof NewMessageType) {
                                NewMessageType n = (NewMessageType)m;
                                in.addClass(n.getName(), n.getClassData());
                                printMessage("New class " + n.getName() + " loaded.");
                            }
                            else if (m instanceof StatusMessage) {
                                printMessage((StatusMessage) m);
                            }
                            else {
                                Class<?> c = m.getClass();
                                StringBuilder sb = new StringBuilder();
                                sb.append(c.getSimpleName() + ": ");
                                Field[] fields = c.getDeclaredFields();
                                for (int i = 0; i < fields.length; i++) {
                                    try {
                                        Object o;
                                        fields[i].setAccessible(true);
                                        o = fields[i].get(m);
                                        sb.append(fields[i].getName() + "(" + o + ")" + (i == fields.length - 1 ? "" : ", "));
                                    } catch (IllegalAccessException ignored) {
                                        System.err.println("Shouldn't get here");
                                    }
                                }
                                printMessage(sb.toString());
                                Method[] methods = c.getMethods();
                                for (int i = 0; i < methods.length; i++) {
                                    if (methods[i].getParameterCount() == 0 && methods[i].isAnnotationPresent(Execute.class)) {
                                        try {
                                            methods[i].invoke(m);
                                        } catch (IllegalAccessException | InvocationTargetException ignored) {

                                        }
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
                                out.writeObject(new ChangeNickMessage(input.substring(6)));
                            }
                        }
                        else {
                            printMessage("Unknown command \"" + input.split("\\s+")[0].substring(1) + "\"");
                        }
                    } else {
                        out.writeObject(new ChatMessage(input));
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
