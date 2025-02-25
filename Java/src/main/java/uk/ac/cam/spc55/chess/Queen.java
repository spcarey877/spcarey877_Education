package uk.ac.cam.spc55.chess;

import java.util.ArrayList;
import java.util.List;

public class Queen extends Piece {

    public Queen(char name, Position piecePosition, PieceColor pieceColor, Board board) {
        super(name, piecePosition, pieceColor, board);
    }

    @Override
    public List<Position> validNextPositions() {
        List<Position> nextPositions = new ArrayList<>();

        position.getAllStraightMoves(8, board(), nextPositions);
        position.getAllDiagonalMoves(8, board(), nextPositions);

        return nextPositions;
    }

    @Override
    public char icon() {
        return pieceColor == PieceColor.BLACK ? '♛' : '♕';
    }

    @Override
    public int value() {
        return 10;
    }

    @Override
    public char name() {
        return name;
    }
}
