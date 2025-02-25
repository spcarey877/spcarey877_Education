package uk.ac.cam.spc55.Algorithms.Tick3;

import uk.ac.cam.cl.tester.Algorithms.LabelledGraph;
import uk.ac.cam.cl.tester.Algorithms.MaxFlow;

import java.io.IOException;
import java.util.*;
import java.util.List;

import uk.ac.cam.cl.tester.Algorithms.LabelledGraph.Edge;

public class MaxFlowFinder implements MaxFlow {

    private int[][] flow = null;
    private int s = 0, t = 0;
    private LabelledGraph g = null;
    private Boolean[] cut = null;

    @Override
    public void maximize(LabelledGraph g, int s, int t) {
        flow = new int[g.numVertices()][g.numVertices()];
        this.s = s;
        this.t = t;
        this.g = g;
        cut = new Boolean[g.numVertices()];

        Collection<Edge> augPath;

        while (true) {
            try {
                augPath = findAugmentingPath();
                int increase = Integer.MAX_VALUE;
                for (Edge e : augPath) {
                    increase = Math.min(increase, Math.abs(e.label));
                }

                for (Edge e : augPath) {
                    if (e.label >= 0) {
                        flow[e.from][e.to] += increase;
                    }
                    else {
                        flow[e.to][e.from] -= increase;
                    }
                }
            }
            catch (NoAugmentingPathException e) {
                break;
            }
        }

        for (int[] flow : flow) {
            System.out.println(Arrays.toString(flow));
        }
    }

    @Override
    public int value() {
        int v = 0;
        for (int j=0; j<g.numVertices(); j++) v += flow[s][j];
        for (int i=0; i<g.numVertices(); i++) v -= flow[i][s];
        return v;
    }

    @Override
    public Iterable<LabelledGraph.Edge> flows() {
        List<LabelledGraph.Edge> res = new ArrayList<LabelledGraph.Edge>();
        for (int i=0; i<g.numVertices(); i++) for (int j=0; j<g.numVertices(); j++) if (flow[i][j]>0)
            res.add(new LabelledGraph.Edge(i, j, flow[i][j]));
        return res;
    }

    @Override
    public Set<Integer> cut() {
        Set<Integer> res = new HashSet<Integer>();
        for (int i=0; i<cut.length; i++) if (cut[i]) res.add(i);
        return res;
    }

    private Collection<Edge> findAugmentingPath() throws NoAugmentingPathException {
        Stack<Edge> augmentingPath = new Stack<>();

        ArrayList<Edge> helperGraph = new ArrayList<>();

        for (int i = 0; i < g.numVertices(); i++) {
            for (int j = 0; j < g.numVertices(); j++) {
                int maxIncreaseFlow = g.capacity(i, j) - flow[i][j];
                if (maxIncreaseFlow > 0) {
                    helperGraph.add(new Edge(i, j, maxIncreaseFlow));
                }
                if (flow[j][i] > 0) {
                    helperGraph.add(new Edge(i, j, -flow[j][i]));
                }
            }
        }

        Map<Integer, Edge> comeFrom = new HashMap<>();
        Queue<Integer> toExplore = new LinkedList<>();
        toExplore.add(s);
        comeFrom.put(s, null);
        cut[s] = true;

        while (toExplore.size() != 0) {
            int v = toExplore.poll();
            for (Edge e : helperGraph) {
                if (e.from == v && !comeFrom.containsKey(e.to)) {
                    toExplore.offer(e.to);
                    comeFrom.put(e.to, e);
                }
            }
        }

        if (!comeFrom.containsKey(t)) {
            for (int i = 0; i < cut.length; i++) {
                cut[i] = comeFrom.containsKey(i);
            }
            throw new NoAugmentingPathException();
        } else {
            augmentingPath.push(comeFrom.get(t));
            while (augmentingPath.peek().from != s) {
                augmentingPath.push(comeFrom.get(augmentingPath.peek().from));
            }
        }

        return augmentingPath;
    }

    private static class NoAugmentingPathException extends Exception {
    }


    public static void main(String[] args) throws IOException {
        LabelledGraph g = new LabelledGraph("flownetwork_02.csv");
        MaxFlowFinder m = new MaxFlowFinder();
        m.maximize(g, 0, 5);
    }

}
