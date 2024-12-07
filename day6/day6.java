package aoc.day6;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class day6 {
    public static void main(String[] args) {
        String filePath = "aoc/day6/input.txt";
        try {
            char[][] arr = fileToArray(filePath);
            System.out.println(totalPositions(arr));
        }
        catch (IOException e){
            e.getMessage();
        }
    }

    public static int totalPositions(char[][] arr){
        int total = 1;
        int i,j = -1;
        int flag = 0;

        int dir = 0;

        for ( i = 0; i < arr.length; i++) {
            for ( j = 0; j < arr[i].length; j++) {
                if(arr[i][j] == '^'){
                    flag = 1;
                    break;
                }
            }
            if(flag == 1) break;
        }

        arr[i][j] = '.';

        while ((i > 0 && i < arr.length) && (j > 0 && j < arr[i].length)){
            if(i == 0 || i == arr.length-1) break;
            if(j == 0 || j == arr[i].length-1) break;
            if(dir == 0){
                if(arr[i-1][j] == '#')
                    dir++;
                else if(arr[i][j] == '.'){
                    arr[i][j] = 'X';
                    i--;
                    total++;
                }
                else i--;
            }
            else if(dir == 1){
                if(arr[i][j+1] == '#')
                    dir++;
                else if(arr[i][j] == '.'){
                    arr[i][j] = 'X';
                    j++;
                    total++;
                }
                else j++;
            }
            else if(dir == 2){
                if(arr[i+1][j] == '#')
                    dir++;
                else if(arr[i][j] == '.'){
                    arr[i][j] = 'X';
                    i++;
                    total++;
                }
                else i++;
            }
            else{
                if(arr[i][j-1] == '#')
                    dir = 0;
                else if(arr[i][j] == '.'){
                    arr[i][j] = 'X';
                    j--;
                    total++;
                }
                else j--;
            }
        }

        return total;
    }

    public static char[][] fileToArray(String filePath) throws IOException {
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