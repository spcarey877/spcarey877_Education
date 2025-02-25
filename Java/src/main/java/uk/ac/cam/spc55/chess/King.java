package uk.ac.cam.spc55.chess;

import java.util.ArrayList;
import java.util.List;

public class King extends Piece {

    public static int KING_VALUE = 10000;

    public King(char name, Position piecePosition, PieceColor pieceColor, Board board) {
        super(name, piecePosition, pieceColor, board);
    }

    @Override
    public List<Position> validNextPositions() {
        List<Position> nextPositions = new ArrayList<>();

        position.getAllStraightMoves(1, board(), nextPositions);
        position.getAllDiagonalMoves(1, board(), nextPositions);

        return nextPositions;
    }

    @Override
    public char icon() {
        return pieceColor == PieceColor.BLACK ? '♚' : '♔';
    }

    @Override
    public int value() {
        return KING_VALUE;
    }

    @Override
    public char name() {
        return name;
    }
}
