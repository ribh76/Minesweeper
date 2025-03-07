import de.bezier.guido.*;
import java.util.ArrayList;

// Declare and initialize constants
private static final int NUM_ROWS = 20;
private static final int NUM_COLS = 30;
private static final int NUM_MINES = 75;

private MSButton[][] buttons; // 2D array of minesweeper buttons
private ArrayList<MSButton> mines; // ArrayList of mined buttons
private boolean gameOver = false;

void setup()
{
    size(1200, 800);
    textAlign(CENTER, CENTER);
    
    // Make the manager
    Interactive.make(this);
    
    // Initialize buttons
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    mines = new ArrayList<MSButton>();
    
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c] = new MSButton(r, c);
        }
    }
    
    setMines();
}

public void setMines()
{
    int count = 0;
    while (count < NUM_MINES) {
        int r = (int) random(NUM_ROWS);
        int c = (int) random(NUM_COLS);
        boolean alreadyAdded = false;
        for (int i = 0; i < mines.size(); i++) {
            if (mines.get(i) == buttons[r][c]) {
                alreadyAdded = true;
            }
        }
        if (!alreadyAdded) {
            mines.add(buttons[r][c]);
            count++;
        }
    }
}

public void draw()
{
    background(0);
    if (gameOver) {
        displayLosingMessage();
    } else if (isWon()) {
        displayWinningMessage();
    }
}

public boolean isWon()
{
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            boolean isMine = false;
            for (int i = 0; i < mines.size(); i++) {
                if (mines.get(i) == buttons[r][c]) {
                    isMine = true;
                }
            }
            if (!isMine && !buttons[r][c].clicked) {
                return false;
            }
        }
    }
    return true;
}

public void displayLosingMessage()
{
    fill(255, 0, 0);
    textSize(64);
    text("Game Over", width / 2, height / 2);
}

public void displayWinningMessage()
{
    fill(0, 255, 0);
    textSize(64);
    text("You Win!", width / 2, height / 2);
}

public boolean isValid(int r, int c)
{
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public int countMines(int row, int col)
{
    int numMines = 0;
    for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
            if (!(dr == 0 && dc == 0)) {
                int newRow = row + dr;
                int newCol = col + dc;
                if (isValid(newRow, newCol)) {
                    for (int i = 0; i < mines.size(); i++) {
                        if (mines.get(i) == buttons[newRow][newCol]) {
                            numMines++;
                        }
                    }
                }
            }
        }
    }
    return numMines;
}

public class MSButton
{
    private int myRow, myCol;
    private float x, y, width, height;
    private boolean clicked, flagged;
    private String myLabel;
    
    public MSButton(int row, int col)
    {
        width = 1200 / NUM_COLS;
        height = 800 / NUM_ROWS;
        myRow = row;
        myCol = col;
        x = myCol * width;
        y = myRow * height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add(this);
    }
    
    public void mousePressed()
    {
        if (gameOver) {
            return;
        }
        
        if (mouseButton == RIGHT) {
            flagged = !flagged;
        } else if (!flagged) {
            clicked = true;
            for (int i = 0; i < mines.size(); i++) {
                if (mines.get(i) == this) {
                    gameOver = true;
                    return;
                }
            }
            int mineCount = countMines(myRow, myCol);
            if (mineCount > 0) {
                setLabel(mineCount);
            } else {
                revealEmptyCells(myRow, myCol);
            }
        }
    }
    
    public void draw()
    {
        if (gameOver && isMine()) {
            fill(255, 0, 0);
        } else if (flagged) {
            fill(0, 255, 0);
        } else if (clicked) {
            fill(200);
        } else {
            fill(100);
        }
        rect(x, y, width, height);
        fill(0);
        text(myLabel, x + width / 2, y + height / 2);
    }
    
    public void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }
    
    public void setLabel(int newLabel)
    {
        myLabel = "" + newLabel;
    }
    
    public boolean isFlagged()
    {
        return flagged;
    }
    
    private boolean isMine()
    {
        for (int i = 0; i < mines.size(); i++) {
            if (mines.get(i) == this) {
                return true;
            }
        }
        return false;
    }
    
    private void revealEmptyCells(int row, int col)
    {
        for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
                if (!(dr == 0 && dc == 0)) {
                    int newRow = row + dr;
                    int newCol = col + dc;
                    if (isValid(newRow, newCol) && !buttons[newRow][newCol].clicked) {
                        buttons[newRow][newCol].clicked = true;
                        int count = countMines(newRow, newCol);
                        if (count > 0) {
                            buttons[newRow][newCol].setLabel(count);
                        } else {
                            revealEmptyCells(newRow, newCol);
                        }
                    }
                }
            }
        }
    }
}
