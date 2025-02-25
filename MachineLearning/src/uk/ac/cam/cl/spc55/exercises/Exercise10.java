package uk.ac.cam.cl.spc55.exercises;

import uk.ac.cam.cl.mlrd.exercises.social_networks.IExercise10;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Path;
import java.util.*;

public class Exercise10 implements IExercise10 {
    @Override
    public Map<Integer, Set<Integer>> loadGraph(Path graphFile) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(graphFile.toFile()));
        Map<Integer, Set<Integer>> graph = new HashMap<>();


        String edge;
        int[] nodes = new int[2];
        String[] sNodes;

        while ((edge = br.readLine()) != null) {
            sNodes = edge.split(" ");

            assert sNodes.length == 2 : "Edge matches to more than 2 nodes";

            for (int i = 0; i < 2; i++) {
                nodes[i] = Integer.parseInt(sNodes[i]);
            }

            if (graph.containsKey(nodes[0])) {
                graph.get(nodes[0]).add(nodes[1]);
            }
            else {
                Set<Integer> inner = new HashSet<>();
                inner.add(nodes[1]);
                graph.put(nodes[0], inner);
            }

            if (graph.containsKey(nodes[1])) {
                graph.get(nodes[1]).add(nodes[0]);
            }
            else {
                Set<Integer> inner = new HashSet<>();
                inner.add(nodes[0]);
                graph.put(nodes[1], inner);
            }
        }

        return graph;
    }

    @Override
    public Map<Integer, Integer> getConnectivities(Map<Integer, Set<Integer>> graph) {
        Map<Integer, Integer> degrees = new HashMap<>();

        graph.forEach((i, s) -> degrees.put(i, s.size()));

        return degrees;
    }

    @Override
    public int getDiameter(Map<Integer, Set<Integer>> graph) {
        int diameter = 0;

        for (int i : graph.keySet()) {
            //distance functions v.seen
            Map<Integer, Integer> distance = new HashMap<>();
            LinkedList<Integer> toExplore = new LinkedList<>();

            distance.put(i, 0);
            toExplore.offer(i);

            while (!toExplore.isEmpty()) {
                int v = toExplore.poll();
                for (int j : graph.get(v)) {
                    if (!distance.containsKey(j)) {
                        distance.put(j, distance.get(v) + 1);
                        toExplore.offer(j);
                    }
                }
            }

            diameter = Math.max(diameter, distance.values().stream().max(Integer::compareTo).get());
        }

        return diameter;
    }
}
