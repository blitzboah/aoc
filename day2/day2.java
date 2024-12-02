package day2;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class day2 {
    public static void main(String[] args) {

        String fileName = "day2/input.txt";
        try{
            int[][] arr = fileToArray(fileName);
            System.out.println(totalSafe(arr));
        }
        catch (IOException e){
            System.out.println(e.getMessage());
        }
    }

    public static int[][] fileToArray(String fileName) throws IOException{
        List<int[]> rows = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(fileName))){
            String line;
            while ((line = br.readLine()) != null){
                String[] stringNums = line.trim().split("\\s+");
                int[] intNums = Arrays.stream(stringNums)
                        .mapToInt(Integer::parseInt)
                        .toArray();
                rows.add(intNums);
            }
        }
        return rows.toArray(new int[0][]);
    }

    public static int totalSafe(int[][] arr){
        int total = 0;
        for (int i = 0; i < arr.length; i++) {
            if(isIncreasing(arr[i]) || isDecreasing(arr[i])){
                if(diff(arr[i])) total++;
            }
        }
        return total;
    }

    public static Boolean diff(int[] arr){
        for (int j = 0; j < arr.length-1; j++) {
            if(Math.abs(arr[j] - arr[j+1]) > 3){
                return false;
            }
        }
        return true;
    }

    public static Boolean isIncreasing(int[] arr){
        boolean inc = true;
        for (int i = 0; i < arr.length-1; i++) {
            if(arr[i] >= arr[i+1]){
                inc = false;
                break;
            }
        }
        return inc;
    }

    public static Boolean isDecreasing(int[] arr){
        boolean dec = true;
        for (int i = 0; i < arr.length-1; i++) {
            if(arr[i] <= arr[i+1]){
                dec = false;
                break;
            }
        }
        return dec;
    }
}
