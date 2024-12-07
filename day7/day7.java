package aoc.day7;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class day7 {

    public static void main(String[] args) {
        List<String> lines = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader("aoc/day7/input.txt"))) {
            String line;
            while ((line = br.readLine()) != null) {
                lines.add(line.trim());
            }
        } catch (IOException e) {
            e.getMessage();
        }

        long resultPart1 = 0;
        long resultPart2 = 0;

        for (String line : lines) {
            String[] parts = line.split(":");
            long desired = Long.parseLong(parts[0].trim());
            String[] operandsStr = parts[1].trim().split("\\s+");
            List<Long> operands = new ArrayList<>();
            for (String s : operandsStr) {
                operands.add(Long.parseLong(s));
            }

            long s = operands.get(0);
            if (tryRemakePart1(desired, s, operands.subList(1, operands.size()))) {
                resultPart1 += desired;
            }

            if (tryRemakePart2(desired, s, operands.subList(1, operands.size()))) {
                resultPart2 += desired;
            }
        }

        System.out.println(resultPart1);
        System.out.println(resultPart2);
    }

    public static boolean tryRemakePart1(long desired, long s, List<Long> operands) {
        if (operands.isEmpty()) {
            return desired == s;
        }
        return tryRemakePart1(desired, s * operands.get(0), operands.subList(1, operands.size())) ||
                tryRemakePart1(desired, s + operands.get(0), operands.subList(1, operands.size()));
    }

    public static boolean tryRemakePart2(long desired, long s, List<Long> operands) {
        if (operands.isEmpty()) {
            return desired == s;
        }

        boolean possibleMul = tryRemakePart2(desired, s * operands.get(0), operands.subList(1, operands.size()));

        boolean possibleAdd = tryRemakePart2(desired, s + operands.get(0), operands.subList(1, operands.size()));

        boolean possibleConcat = tryRemakePart2(desired, Long.parseLong(s + "" + operands.get(0)), operands.subList(1, operands.size()));

        return possibleMul || possibleAdd || possibleConcat;
    }
}
