package day1;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;

public class day1 {
    public static void main(String[] args) {

        String filePath = "./input.txt";

        List<Integer> col1 = new ArrayList<>();
        List<Integer> col2 = new ArrayList<>();

        try(BufferedReader br = new BufferedReader(new FileReader(filePath))){
            String line;
            while ((line = br.readLine()) != null){
                String[] parts = line.split("\\s+");
                if(parts.length >= 2){
                    col1.add(Integer.parseInt(parts[0]));
                    col2.add(Integer.parseInt(parts[1]));
                }
            }
        }
        catch (Exception e){
            System.out.println(e.getMessage());
        }

        int[] arr1 = col1.stream().mapToInt(i -> i).toArray();
        int[] arr2 = col2.stream().mapToInt(i -> i).toArray();

        System.out.println(totalDistance(arr1, arr2));
    }

    public static int totalDistance(int[] arr1, int[] arr2){
        int total = 0;

        for (int i = 0; i < arr1.length; i++)
            total += Math.abs(smallestNum(arr1) - smallestNum(arr2));

        return total;
    }

    public static int smallestNum(int[] arr){
        int min = Integer.MAX_VALUE;
        int index = -1;
        for(int i=0; i<arr.length; i++){
            if(arr[i] < min){
                min = arr[i];
                index = i;
            }
        }

        arr[index] = Integer.MAX_VALUE;
        return min;
    }
}
