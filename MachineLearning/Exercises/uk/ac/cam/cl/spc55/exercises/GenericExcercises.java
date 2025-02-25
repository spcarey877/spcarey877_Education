package uk.ac.cam.cl.spc55.exercises;

import uk.ac.cam.cl.mlrd.exercises.markov_models.HMMDataStore;
import uk.ac.cam.cl.mlrd.exercises.markov_models.HiddenMarkovModel;

import java.util.*;

public class GenericExcercises<T extends Enum<T>, U extends Enum<U>> {

    private final Class<T> enumClassT;
    private final Class<U> enumClassU;

    public GenericExcercises(Class<T> enumClassT, Class<U> enumClassU) {
        this.enumClassT = enumClassT;
        this.enumClassU = enumClassU;
    }


    public HiddenMarkovModel<T, U> estimateHMMFromDataStores(List<HMMDataStore<T, U>> dataStores) {
        Map<U, Map<U, Double>> transitionMatrix = new HashMap<>();
        Map<U, Map<T, Double>> emissionMatrix = new HashMap<>();

        for (U u1 : enumClassU.getEnumConstants()) {
            Map<U, Double> typeInner = new HashMap<>();
            Map<T, Double> rollInner = new HashMap<>();

            for (U u2 : enumClassU.getEnumConstants()) {
                typeInner.put(u2, 0.0);
            }
            transitionMatrix.put(u1, typeInner);

            for (T t : enumClassT.getEnumConstants()) {
                rollInner.put(t, 0.0);
            }
            emissionMatrix.put(u1, rollInner);
        }

        for (HMMDataStore<T, U> data : dataStores) {
            List<U> hiddenSequence = data.hiddenSequence;
            List<T> observedSequence = data.observedSequence;

            for (int i = 0; i < hiddenSequence.size() - 1; i++) {
                U type = hiddenSequence.get(i), nextType = hiddenSequence.get(i + 1);
                T roll = observedSequence.get(i);

                transitionMatrix.get(type).put(nextType, transitionMatrix.get(type).get(nextType) + 1);
                emissionMatrix.get(type).put(roll, emissionMatrix.get(type).get(roll) + 1);
            }

            //add final emission, which isn't included in loop
            T roll = observedSequence.get(observedSequence.size() - 1);
            U type = hiddenSequence.get(hiddenSequence.size() - 1);
            emissionMatrix.get(type).put(roll, emissionMatrix.get(type).get(roll) + 1);
        }

        transitionMatrix.replaceAll((U, UDoubleMap) -> {
            final double total = UDoubleMap.values().stream().mapToDouble(d -> d).sum();
            if (total > 0) {
                UDoubleMap.replaceAll((U1, aDouble) -> aDouble / total);
            }
            return UDoubleMap;
        });

        emissionMatrix.replaceAll(((U, TDoubleMap) -> {
            final double total = TDoubleMap.values().stream().mapToDouble(d -> d).sum();
            if (total > 0) {
                TDoubleMap.replaceAll(((T, aDouble) -> aDouble / total));
            }
            return TDoubleMap;
        }));

        return new HiddenMarkovModel<T, U>(transitionMatrix, emissionMatrix);
    }

    public List<U> viterbi(HiddenMarkovModel<T, U> model, List<T> observedSeuquence) {
        List<Map<U, Double>> sigmas = new ArrayList<>();
        List<Map<U, U>> psis = new ArrayList<>();

        Map<U, Map<U, Double>> transitionProbs = model.getTransitionMatrix();
        Map<U, Map<T, Double>> emissionProbs = model.getEmissionMatrix();

        Map<U, Double> initSigma = new HashMap<>();
        Map<U, U> initPsi = new HashMap<>();

        double initMax = Math.log(0);
        U initArgmax = null;
        for (U current : enumClassU.getEnumConstants()) {
            double val = Math.log(emissionProbs.get(current).get(observedSeuquence.get(0)));
            if (val >= initMax) {
                initArgmax = current;
                initMax = val;
            }
            initSigma.put(current, val);
        }
        initPsi.put(initArgmax, null);

        sigmas.add(initSigma);
        psis.add(initPsi);

        for (int i = 1; i < observedSeuquence.size(); i++) {
            Map<U, Double> sigma = new HashMap<>();
            Map<U, U> psi = new HashMap<>();

            for (U current : enumClassU.getEnumConstants()) {
                Map<T, Double> emissions = emissionProbs.get(current);
                double max = Math.log(0);
                U argmax = null;

                for (U prev : enumClassU.getEnumConstants()) {
                    double val = sigmas.get(i - 1).get(prev) + Math.log(transitionProbs.get(prev).get(current)) + Math.log(emissions.get(observedSeuquence.get(i)));
                    if (val >= max) {
                        argmax = prev;
                        max = val;
                    }
                }
                sigma.put(current, max);
                psi.put(current, argmax);
            }

            sigmas.add(sigma);
            psis.add(psi);
        }

        List<U> predicted = new ArrayList<>();

        U current = null;
        double max = Math.log(0);
        final Map<U, Double> finalMap = sigmas.get(sigmas.size() - 1);

        for (U argmax : finalMap.keySet()) {
            if (finalMap.get(argmax) > max) {
                current = argmax;
                predicted.add(current);
                break;
            }
        }

        for (int i = psis.size() - 1; i > 0; i--) {
            current = psis.get(i).get(current);
            predicted.add(current);
        }

        Collections.reverse(predicted);

        return predicted;
    }

    public double precision(Map<List<U>, List<U>> true2predicted, U interest) {
        double precision = 0;
        double count = 0;


        for (List<U> trueHidden : true2predicted.keySet()) {
            List<U> predictedHidden = true2predicted.get(trueHidden);
            for (int i = 0; i < trueHidden.size(); i++) {
                if (predictedHidden.get(i).equals(interest)) {
                    count++;
                    if (trueHidden.get(i).equals(interest)) {
                        precision++;
                    }
                }
            }
        }

        precision /= count;

        return precision;
    }

    public double recall(Map<List<U>, List<U>> true2predicted, U interest) {
        double recall = 0;
        double total = 0;

        for (List<U> trueHidden : true2predicted.keySet()) {
            List<U> predictedHidden = true2predicted.get(trueHidden);

            for (int i = 0; i < trueHidden.size(); i++) {
                if (trueHidden.get(i).equals(interest)) {
                    total++;
                    if (predictedHidden.get(i).equals(interest)) {
                        recall++;
                    }
                }
            }
        }

        recall = recall / total;

        return recall;
    }

    public double fOneMeasure(Map<List<U>, List<U>> true2predicted, U interest) {
        double precision = precision(true2predicted, interest), recall = recall(true2predicted, interest);

        return 2 * precision * recall / (precision + recall);
    }

    public Map<List<U>, List<U>> predictAll(HiddenMarkovModel<T, U> model, List<HMMDataStore<T, U>> dataStores) {
        Map<List<U>, List<U>> predictions = new HashMap<>();

        for (HMMDataStore<T, U> dataStore : dataStores) {
            predictions.put(dataStore.hiddenSequence, viterbi(model, dataStore.observedSequence));
        }

        return predictions;
    }
}
