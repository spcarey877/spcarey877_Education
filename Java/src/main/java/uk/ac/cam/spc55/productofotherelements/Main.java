/*
 * Copyright 2020 Ben Philps <bp413@cam.ac.uk>, Andrew Rice <acr31@cam.ac.uk>, S.P. Carey
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

package uk.ac.cam.spc55.productofotherelements;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.stream.IntStream;

public class Main {

    public static void main(String[] args) {
        int[] testArr = new int[]{1, 2, 3, 4, 5};
        int[] result = findArrayProducts(testArr);
        System.out.println(Arrays.toString(result));
    }

    static int[] findArrayProducts(int[] arr) {
        int product = 1;

        for (int i : arr) {
            product *= i;
        }

        int[] result = new int[arr.length];

        for (int i = 0; i < arr.length; i++) {
            if (arr[i] == 0) {
                result[i] = product;
            } else {
                result[i] = product / arr[i];
            }
        }

        return result;
    }

    static double[] findArrayProducts(double[] arr) {
        double product = 1;

        for (double i : arr) {
            product *= i;
        }

        double[] result = new double[arr.length];

        for (int i = 0; i < arr.length; i++) {
            if (arr[i] == 0.0) {
                result[i] = product;
            } else {
                result[i] = product / arr[i];
            }
        }

        return result;
    }
}
