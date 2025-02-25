package uk.ac.cam.spc55.Algorithms.Tick2;


import uk.ac.cam.cl.tester.Algorithms.LCSFinder;

import java.util.Arrays;

public class LCSBottomUp extends LCSFinder {

    public LCSBottomUp (String s1, String s2) {
        super(s1, s2);
        if (!s1.isBlank() && !s2.isBlank()) {
            mTable = new int[s1.length()][s2.length()];
        }
    }

    @Override
    public int getLCSLength() {
        if (mString1.isBlank() || mString2.isBlank()) {
            return 0;
        }

        for (int i = 0; i < mString1.length(); i++) {
            for (int j = 0; j < mString2.length(); j++) {
                if (mString1.charAt(i) == mString2.charAt(j)) {
                    mTable[i][j] = 1 + (i > 0 && j > 0 ? mTable[i-1][j-1] : 0);
                }
                else {
                    mTable[i][j] = Math.max(j > 0 ? mTable[i][j-1] : 0, i > 0 ? mTable[i-1][j] : 0);
                }
            }
        }

        return mTable[mString1.length() - 1][mString2.length() - 1];
    }

    @Override
    public String getLCSString() {
        if (mString1.isBlank() || mString2.isBlank()) {
            return "";
        }
        StringBuilder lcsString = new StringBuilder();

        int j = mString2.length()-1, i = mString1.length()-1;

        while (mTable[i][j] != 0) {
            if (i > 0 && j > 0) {
                if (mTable[i][j] > mTable[i - 1][j] && mTable[i][j] > mTable[i][j - 1]) {
                    lcsString.append(mString1.charAt(i));
                    i--;
                    j--;
                }
                else if (mTable[i-1][j] > mTable[i][j-1]) {
                    i--;
                }
                else {
                    j--;
                }
            }
            else if (i > 0) {
                if (mTable[i][0] > mTable[i-1][0]) {
                    lcsString.append(mString1.charAt(i));
                }
                i--;
            }
            else if (j > 0) {
                if (mTable[0][j] > mTable[0][j-1]) {
                    lcsString.append(mString1.charAt(0));
                }
                j--;
            }
            else {
                lcsString.append(mString1.charAt(0));
                break;
            }
        }

        return lcsString.reverse().toString();
    }

    public static void main(String[] args) {
        String s1 = "ABBA";
        String s2 = "CACA";

        LCSBottomUp lcs = new LCSBottomUp(s1, s2);
        System.out.println(lcs.getLCSLength());
        System.out.println(lcs.getLCSString());
    }
}
