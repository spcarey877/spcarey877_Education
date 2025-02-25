package uk.ac.cam.cl.spc55.exercises;

import uk.ac.cam.cl.mlrd.exercises.social_networks.IExercise12;

import java.util.*;

public class Exercise12 implements IExercise12 {
    @Override
    public List<Set<Integer>> GirvanNewman(Map<Integer, Set<Integer>> graph, int minimumComponents) {
        List<Set<Integer>> clusters;

        clusters = getComponents(graph);

        double max;
        ArrayList<Integer> edges;

        while (clusters.size() < minimumComponents && getNumberOfEdges(graph) > 0) {
            max = 0;
            edges = new ArrayList<>();
            Map<Integer, Map<Integer, Double>> edgeBetweenness = getEdgeBetweenness(graph);

            for (int i : edgeBetweenness.keySet()) {
                for (int j : edgeBetweenness.get(i).keySet()) {
                    double val = edgeBetweenness.get(i).get(j);
                    if (val > max) {
                        edges.clear();
                        edges.add(i);
                        edges.add(j);
                        max = edgeBetweenness.get(i).get(j);
                    } else if (val == max) {
                        edges.add(i);
                        edges.add(j);
                    }
                }
            }

            for (int i = 0; i < edges.size(); i+=2) {
                graph.get(edges.get(i++)).remove(edges.get(i));
                graph.get(edges.get(i--)).remove(edges.get(i));
            }

            clusters = getComponents(graph);
        }

        return clusters;
    }

    @Override
    public int getNumberOfEdges(Map<Integer, Set<Integer>> graph) {
        return graph.values().stream().mapToInt(Set::size).sum() / 2;
    }

    @Override
    public List<Set<Integer>> getComponents(Map<Integer, Set<Integer>> graph) {
        List<Set<Integer>> components = new ArrayList<>();

        for (int i : graph.keySet()) {
            boolean found = false;
            for (Set<Integer> component : components) {
                if (component.contains(i)) {
                    found = true;
                }
            }

            if (!found) {
                Set<Integer> inner = new HashSet<>();
                Stack<Integer> toExplore = new Stack<>();
                inner.add(i);
                toExplore.push(i);

                while (!toExplore.isEmpty()) {
                    int v = toExplore.pop();
                    for (int w : graph.get(v)) {
                        if (inner.add(w)) {
                            toExplore.push(w);
                        }
                    }
                }

                components.add(inner);
            }
        }

        return components;
    }

    @Override
    public Map<Integer, Map<Integer, Double>> getEdgeBetweenness(Map<Integer, Set<Integer>> graph) {
        final Map<Integer, Map<Integer, Double>> betweenness = new HashMap<>();
        final Set<Integer> nodes = graph.keySet();

        for (int i : nodes) {
            Map<Integer, Double> inner = new HashMap<>();
            for (int j : graph.get(i)) {
                inner.put(j, 0.0);
            }
            betweenness.put(i, inner);
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
                    double c = (1 + delta.get(w)) * sigma.get(v) / (double)sigma.get(w);
                    betweenness.get(v).put(w, betweenness.get(v).get(w) + c);
                    delta.put(v, delta.get(v) + c);
                }
            }
        }

        return betweenness;
    }
}
