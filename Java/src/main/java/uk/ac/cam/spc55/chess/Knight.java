package uk.ac.cam.spc55.chess;

import java.util.ArrayList;
import java.util.List;

public class Knight extends Piece {

    public Knight(char name, Position piecePosition, PieceColor pieceColor, Board board) {
        super(name, piecePosition, pieceColor, board);
    }

    @Override
    public List<Position> validNextPositions() {
        List<Position> nextPositions = new ArrayList<>();

        computeKnightNextPositions(nextPositions);

        return nextPositions;
    }

    @Override
    public char icon() {
        return pieceColor == PieceColor.BLACK ? '♞' : '♘';
    }

    @Override
    public int value() {
        return 3;
    }

    private void computeKnightNextPositions(List<Position> nextPositions) {
        // directions a knight can travel in.
        final int[][] nextPosDeltas =
                new int[][] {
                        {1, 2}, {1, -2}, {-1, 2}, {-1, -2},
                        {2, 1}, {-2, 1}, {2, -1}, {-2, -1}
                };

        // iterate through all possible positions, getting any valid next positions
        for (int[] posDeltaPair : nextPosDeltas) {
            position.addPosAtDelta(posDeltaPair[0], posDeltaPair[1], board(), nextPositions);
        }
    }

    @Override
    public char name() {
        return name;
    }
}
