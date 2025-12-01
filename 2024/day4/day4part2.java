package aoc.day4;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class day4part2 {
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

        for(int i=1; i<arr.length - 1; i++){
            for (int j = 1; j < arr[i].length - 1; j++) {
                if(arr[i][j] == 'A' && checkDiagonals(arr, i, j)){
                        total++;
                }
            }
        }

        return total;
    }

    public static Boolean checkDiagonals(char[][] arr, int i, int j){
        boolean tlbr = ((arr[i-1][j-1] == 'M'
                        && arr[i+1][j+1] == 'S')
                        || (arr[i-1][j-1] == 'S'
                        && arr[i+1][j+1] == 'M'));
        boolean trbl = ((arr[i-1][j+1] == 'M'
                        && arr[i+1][j-1] == 'S')
                        || (arr[i-1][j+1] == 'S'
                        && arr[i+1][j-1] == 'M'));

        return tlbr && trbl;
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
