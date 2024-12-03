package aoc.day3;


import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class day3part2 {
    public static void main(String[] args) {
        int total = 0;
        Boolean currentState = true;
        int num1;
        int num2;
        int lastProcessedIndex = 0;
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
            String substringBeforeMatch = content.substring(lastProcessedIndex,matcher.start());
            if(substringBeforeMatch.contains("do()")){
                currentState = true;
            }
            else if(substringBeforeMatch.contains("don't()")){
                currentState = false;
            }

            if(!currentState) continue;

            num1 = Integer.parseInt(matcher.group(1));
            num2 = Integer.parseInt(matcher.group(2));
            total += num1 * num2;

            lastProcessedIndex = matcher.end();
        }

        System.out.println(total);
    }
}
