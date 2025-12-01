package aoc.day3;


import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class day3 {
    public static void main(String[] args) {
        int total = 0;
        String filePath = "aoc/day3/input.txt";
        StringBuilder content = new StringBuilder();

        try(BufferedReader br = new BufferedReader(new FileReader(filePath))){
            String line;
            while ((line = br.readLine()) != null){
                content.append(line).append("\n");
            }
        }catch (IOException e){
            e.getMessage();
        }

        String regex = "mul\\((\\d+),(\\d+)\\)";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(content.toString());

        while (matcher.find()){
            total += Integer.parseInt(matcher.group(1)) * Integer.parseInt(matcher.group(2));
        }

        System.out.println(total);
    }
}
