package uk.ac.cam.spc55.chess;

import java.util.ArrayList;
import java.util.List;

public class Bishop extends Piece {

    public Bishop(char name, Position piecePosition, PieceColor pieceColor, Board board) {
        super(name, piecePosition, pieceColor, board);
    }

    @Override
    public List<Position> validNextPositions() {
        List<Position> nextPositions = new ArrayList<>();

        position.getAllDiagonalMoves(8, board(), nextPositions);

        return nextPositions;
    }

    @Override
    public char icon() {
        return pieceColor == PieceColor.BLACK ? '♝' : '♗';
    }

    @Override
    public int value() {
        return 3;
    }

    @Override
    public char name() {
        return name;
    }
}
