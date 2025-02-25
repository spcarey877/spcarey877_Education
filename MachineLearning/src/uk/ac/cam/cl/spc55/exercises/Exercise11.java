package uk.ac.cam.cl.spc55.exercises;

import uk.ac.cam.cl.mlrd.exercises.social_networks.IExercise11;

import uk.ac.cam.cl.spc55.exercises.Exercise10;

import java.io.IOException;
import java.nio.file.Path;
import java.util.*;

public class Exercise11 implements IExercise11 {

    private static final Exercise10 exercise10 = new Exercise10();

    @Override
    public Map<Integer, Double> getNodeBetweenness(Path graphFile) throws IOException {
        final Map<Integer, Set<Integer>> graph = exercise10.loadGraph(graphFile);
        final Map<Integer, Double> betweenness = new HashMap<>();
        final Set<Integer> nodes = graph.keySet();

        for (int i : nodes) {
            betweenness.put(i, 0.0);
        }

        for (int i : nodes) {
            //initialization
            Map<Integer, Integer> dist = new HashMap<>();
            Map<Integer, List<Integer>> pred = new HashMap<>();
            Map<Integer, Integer> sigma = new HashMap<>();
            Map<Integer, Double> delta = new HashMap<>();
            Queue<Integer> Q = new LinkedList<>();
            Stack<Integer> S = new Stack<>();

            nodes.forEach(n -> {dist.put(n, Integer.MAX_VALUE); pred.put(n, new ArrayList<>()); sigma.put(n, 0); delta.put(n, 0.0);});

            dist.put(i, 0);
            sigma.put(i, 1);
            Q.offer(i);

            //count of all shortest paths
            while (!Q.isEmpty()) {
                int v = Q.poll();
                S.push(v);
                for (int w : graph.get(v)) {
                    if (dist.get(w) == Integer.MAX_VALUE) {
                        dist.put(w, dist.get(v) + 1);
                        Q.offer(w);
                    }
                    if (dist.get(w) == dist.get(v) + 1) {
                        sigma.put(w, sigma.get(w) + sigma.get(v));
                        pred.get(w).add(v);
                    }
                }
            }

            //back-propagation of dependencies
            while (!S.isEmpty()) {
                int w = S.pop();
                for (int v : pred.get(w)) {
                    delta.put(v, delta.get(v) + (1 + delta.get(w)) * sigma.get(v) / (double)sigma.get(w));
                }
                if (w != i) {
                    betweenness.put(w, betweenness.get(w) + delta.get(w));
                }
            }
        }

        betweenness.replaceAll((i, d) -> d/2);

        return betweenness;
    }
}
