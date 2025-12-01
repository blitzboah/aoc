package day1;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;

public class day1part2 {
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

        System.out.println(similarityScore(arr1, arr2));
    }

    public static int similarityScore(int[] arr1, int[] arr2){
        int total = 0;

        for (int i = 0; i < arr1.length; i++) {
            total += arr1[i] * getFrequency(arr2, arr1[i]);
        }

        return total;
    }

    public static int getFrequency(int[] arr2, int num){
        int totalFreq = 0;
        for (int i = 0; i < arr2.length; i++) {
            if(arr2[i] == num){
                totalFreq++;
            }
        }
        return totalFreq;
    }
}
