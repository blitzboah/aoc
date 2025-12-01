package day5;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

public class day5 {
    public static void main(String[] args) {
        String inputFile = "day5/input.txt";
        String orderFile = "day5/order.txt";

        HashMap<Integer, ArrayList<Integer>> map = new HashMap<>();

        try(BufferedReader br = new BufferedReader(new FileReader(orderFile))){
            int[][] arr = fileToArray(inputFile);
            String line;
            while ((line = br.readLine()) != null){
                String[] parts = line.split("\\|", 2);
                if (parts.length >= 2){
                    int key = Integer.parseInt(parts[0]);
                    int val = Integer.parseInt(parts[1]);
                    map.computeIfAbsent(key, k -> new ArrayList<>()).add(val); // woah TIL
                }
                else
                    System.out.println("ligma");

            }
            System.out.println(totalMiddle(arr, map));
        } catch (IOException e) {
            e.getMessage();
        }
    }

    public static int totalMiddle(int[][] arr, HashMap<Integer, ArrayList<Integer>> map){
        int total = 0;

        for(int[] arri : arr){
            if(inOrder(arri, map)){
                int mid = arri[arri.length/2];
                total += mid;
            }
        }

        return total;
    }

    public static Boolean inOrder(int[] arr, HashMap<Integer, ArrayList<Integer>> map){
        for (int i = 0; i < arr.length; i++) {
            for (int j = i+1; j < arr.length; j++) {
                int curr = arr[i];
                int next = arr[j];

                if(map.containsKey(curr) && map.get(curr).contains(next))
                    continue;

                if(map.containsKey(next) && map.get(next).contains(curr))
                    return false;
            }
        }
        return true;
    }

    public static int[][] fileToArray(String fileName) throws IOException {
        List<int[]> rows = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(fileName))){
            String line;
            while ((line = br.readLine()) != null){
                String[] stringNums = line.trim().split(",");
                int[] intNums = Arrays.stream(stringNums)
                        .mapToInt(Integer::parseInt)
                        .toArray();
                rows.add(intNums);
            }
        }
        return rows.toArray(new int[0][]);
    }

}
