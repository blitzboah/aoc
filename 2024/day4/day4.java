package aoc.day4;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class day4 {
    public static void main(String[] args){
        String filePath = "aoc/day4/input.txt";
        try {
            char[][] arr = fileToArray(filePath);
            System.out.println(totalXmas(arr));
        }
        catch (IOException e){
            e.getMessage();
        }
    }
    
    public static int totalXmas(char[][] arr){
        int total = 0;
        for (int i = 0; i < arr.length; i++) {
            for (int j = 0; j < arr[i].length; j++) {
                if(arr[i][j] == 'X'){
                    if (checkLeft(arr, i, j)) total++;
                    if (checkRight(arr, i, j)) total++;
                    if (checkUp(arr, i, j)) total++;
                    if (checkDown(arr, i, j)) total++;
                    if (checkDiagonalTopLeft(arr, i, j)) total++;
                    if (checkDiagonalTopRight(arr, i, j)) total++;
                    if (checkDiagonalBottomLeft(arr, i, j)) total++;
                    if (checkDiagonalBottomRight(arr, i, j)) total++;
                }
            }
        }
        return total;
    }

    public static Boolean checkLeft(char[][] arr, int i, int j) {
        return j - 3 >= 0 &&
                arr[i][j - 1] == 'M' &&
                arr[i][j - 2] == 'A' &&
                arr[i][j - 3] == 'S';
    }

    public static Boolean checkRight(char[][] arr, int i, int j) {
        return j + 3 < arr[i].length &&
                arr[i][j + 1] == 'M' &&
                arr[i][j + 2] == 'A' &&
                arr[i][j + 3] == 'S';
    }

    public static Boolean checkUp(char[][] arr, int i, int j) {
        return i - 3 >= 0 &&
                arr[i - 1][j] == 'M' &&
                arr[i - 2][j] == 'A' &&
                arr[i - 3][j] == 'S';
    }

    public static Boolean checkDown(char[][] arr, int i, int j) {
        return i + 3 < arr.length &&
                arr[i + 1][j] == 'M' &&
                arr[i + 2][j] == 'A' &&
                arr[i + 3][j] == 'S';
    }

    public static Boolean checkDiagonalTopLeft(char[][] arr, int i, int j) {
        return i - 3 >= 0 && j - 3 >= 0 &&
                arr[i - 1][j - 1] == 'M' &&
                arr[i - 2][j - 2] == 'A' &&
                arr[i - 3][j - 3] == 'S';
    }

    public static Boolean checkDiagonalTopRight(char[][] arr, int i, int j) {
        return i - 3 >= 0 && j + 3 < arr[i].length &&
                arr[i - 1][j + 1] == 'M' &&
                arr[i - 2][j + 2] == 'A' &&
                arr[i - 3][j + 3] == 'S';
    }

    public static Boolean checkDiagonalBottomLeft(char[][] arr, int i, int j) {
        return i + 3 < arr.length && j - 3 >= 0 &&
                arr[i + 1][j - 1] == 'M' &&
                arr[i + 2][j - 2] == 'A' &&
                arr[i + 3][j - 3] == 'S';
    }

    public static Boolean checkDiagonalBottomRight(char[][] arr, int i, int j) {
        return i + 3 < arr.length && j + 3 < arr[i].length &&
                arr[i + 1][j + 1] == 'M' &&
                arr[i + 2][j + 2] == 'A' &&
                arr[i + 3][j + 3] == 'S';
    }

    public static Boolean inBounds(char[][] arr, int col, int row){
        return row >= 0 && row < arr.length && col >= 0 && col < arr[0].length;
    }

    public static char[][] fileToArray(String filePath) throws IOException{
        List<char[]> rows = new ArrayList<>();
        try(BufferedReader br = new BufferedReader(new FileReader(filePath))){
            String line;
            while ((line = br.readLine()) != null){
                rows.add(line.toCharArray());
            }
        }
        catch (IOException e){
            e.getMessage();
        }
        return rows.toArray(new char[0][]);
    }

}
