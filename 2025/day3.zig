const std = @import("std");
const ArrayListAligned = std.ArrayListAligned;

fn fillLines(lines: *ArrayListAligned([]const u8, null), buffer: []const u8) void {
    const BUFFER_LENGTH: usize = buffer.len;
    var index: usize = 0;

    for (0..BUFFER_LENGTH) |i| {
        if (buffer[i] == '\n') {
            lines.append(buffer[index..i]) catch unreachable;
            index = i + 1;
        }
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = std.fs.cwd().openFile("input.txt", .{}) catch unreachable;
    defer file.close();

    const file_size: u64 = file.getEndPos() catch unreachable;
    const buffer: []u8 = allocator.alloc(u8, file_size) catch unreachable;
    defer allocator.free(buffer);

    _ = file.readAll(buffer) catch unreachable;

    var lines: ArrayListAligned([]const u8, null) = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    fillLines(&lines, buffer);

    // part1
    var total: i64 = 0;

    for (0..lines.items.len) |i| {
        const bank = std.mem.trim(u8, lines.items[i], " \n");
        var bigIndex: usize = 1000;

        var bigDigit: i32 = 0;
        var prefixDigit: i32 = 0;
        var suffixDigit: i32 = 0;

        for (0..bank.len) |num| {
            const currentNum = try std.fmt.charToDigit(bank[num], 10);
            if (bigDigit < currentNum) {
                bigDigit = currentNum;
                bigIndex = num;
            }
        }

        for (0..bigIndex) |num| {
            const currentNum = try std.fmt.charToDigit(bank[num], 10);
            if (prefixDigit < currentNum) {
                prefixDigit = currentNum;
            }
        }

        for (bigIndex + 1..bank.len) |num| {
            const currentNum = try std.fmt.charToDigit(bank[num], 10);
            if (suffixDigit < currentNum) {
                suffixDigit = currentNum;
            }
        }

        var num1: i32 = -1;
        var num2: i32 = -1;

        if (prefixDigit != 0) num1 = prefixDigit * 10 + bigDigit;
        if (suffixDigit != 0) num2 = bigDigit * 10 + suffixDigit;

        total += @max(num1, num2);
    }

    std.debug.print("{d}\n\n", .{total});

    //part 2
    var total2: u64 = 0;
    var stack = std.ArrayList(u8).init(allocator);
    defer stack.deinit();

    const keepCount = 12;

    for (0..lines.items.len) |i| {
        const bank = std.mem.trim(u8, lines.items[i], " \n");
        var removalsLeft: usize = bank.len - keepCount;

        for (bank) |num| {
            while (removalsLeft > 0 and stack.items.len > 0 and stack.items[stack.items.len - 1] < num) {
                _ = stack.pop();
                removalsLeft -= 1;
            }
            try stack.append(num);
        }

        while (stack.items.len > keepCount) {
            _ = stack.pop();
        }

        const val = try std.fmt.parseInt(u64, stack.items, 10);
        total2 += val;

        stack.clearRetainingCapacity();
    }

    std.debug.print("{d}", .{total2});
}
