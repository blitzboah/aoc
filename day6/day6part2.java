// do not run this I REPEAT do not run this, this code is so ass. it will keep on running and eventually you'll stop
// but it does give right answer and quickly to smaller inputs, ggs

package aoc.day6;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class day6part2 {
    public static void main(String[] args) {
        String filePath = "aoc/day6/input.txt";
        try {
            char[][] arr = fileToArray(filePath);
            System.out.println(totalLoop(arr));
        }
        catch (IOException e){
            e.getMessage();
        }
    }

    public static int totalLoop(char[][] arr){
        int total = 0;
        int i,j = -1;
        int k,l = -1;
        int startI = -1, startJ = -1;
        int flag = 0;

        int dir = 0;

        for ( i = 0; i < arr.length; i++) {
            for ( j = 0; j < arr[i].length; j++) {
                if(arr[i][j] == '^'){
                    flag = 1;
                    startI = i;
                    startJ = j;
                    break;
                }
            }
            if(flag == 1) break;
        }


        //mark travelled area with X
        while ((i > 0 && i < arr.length) && (j > 0 && j < arr[i].length)){
            if(i == 0 || i == arr.length-1) {
                arr[i][j] = 'X';
                break;
            }
            if(j == 0 || j == arr[i].length-1){
                arr[i][j] = 'X';
                break;
            }
            if(dir == 0){
                if(arr[i-1][j] == '#')
                    dir++;
                else if(arr[i][j] == '.'){
                    arr[i][j] = 'X';
                    i--;
                }
                else i--;
            }
            else if(dir == 1){
                if(arr[i][j+1] == '#')
                    dir++;
                else if(arr[i][j] == '.'){
                    arr[i][j] = 'X';
                    j++;
                }
                else j++;
            }
            else if(dir == 2){
                if(arr[i+1][j] == '#')
                    dir++;
                else if(arr[i][j] == '.'){
                    arr[i][j] = 'X';
                    i++;
                }
                else i++;
            }
            else{
                if(arr[i][j-1] == '#')
                    dir = 0;
                else if(arr[i][j] == '.'){
                    arr[i][j] = 'X';
                    j--;
                }
                else j--;
            }
        }
        arr[startI][startJ] = '.';

        for ( k = 0; k < arr.length; k++) {
            for ( l = 0; l < arr[k].length; l++) {
                if(arr[k][l] == '.' || arr[k][l] == '#') {
                    continue;
                }
                else if(checkLoop(arr, k, l, startI, startJ)){
                    total++;
                }
            }
        }
        return total;
    }

    public static Boolean checkLoop(char[][] arr, int k, int l, int i, int j) {
        arr[k][l] = 'o';
        int dir = 0;
        int encountered = 0;

        while ((i > 0 && i < arr.length) && (j > 0 && j < arr[i].length)) {
            if (i == 0 || i == arr.length - 1) break;
            if (j == 0 || j == arr[i].length - 1) break;
            if(encountered > 1){
                arr[k][l] = '.';
                return true;
            }
            if(dir == 0){
                if(arr[i-1][j] == '#')
                    dir++;
                else if(arr[i-1][j] == 'o') {
                    dir++;
                    encountered++;
                }
                else{
                    i--;
                }
            }
            else if(dir == 1){
                if(arr[i][j+1] == '#')
                    dir++;
                else if(arr[i][j+1] == 'o') {
                    dir++;
                    encountered++;
                }
                else{
                    j++;
                }
            }
            else if(dir == 2){
                if(arr[i+1][j] == '#')
                    dir++;
                else if(arr[i+1][j] == 'o') {
                    dir++;
                    encountered++;
                }
                else{
                    i++;
                }
            }
            else{
                if(arr[i][j-1] == '#')
                    dir = 0;
                else if(arr[i][j-1] == 'o') {
                    dir = 0;
                    encountered++;
                }
                else{
                    j--;
                }
            }
        }
        arr[k][l] = '.';
        return false;
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
