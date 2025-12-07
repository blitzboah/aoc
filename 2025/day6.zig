const std = @import("std");

fn fillLines(lines: *std.ArrayList([]u8), buffer: []u8) void {
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

    var lines = std.ArrayList([]u8).init(allocator);
    defer lines.deinit();

    fillLines(&lines, buffer);

    var arr = std.ArrayList(std.ArrayList([]const u8)).init(allocator);
    defer arr.deinit();

    var p1: u64 = 0;

    for (0..lines.items.len) |i| {
        const line = std.mem.trim(u8, lines.items[i], "\n");
        var it = std.mem.splitSequence(u8, line, " ");

        var inner = std.ArrayList([]const u8).init(allocator);

        while (it.next()) |token| {
            if (token.len > 0) try inner.append(token);
        }

        try arr.append(inner);
    }

    const rows = arr.items.len - 1;
    const cols = arr.items[0].items.len;

    for (0..cols) |col| {
        var result: u64 = 0;
        const op = arr.items[rows].items[col];
        var first: bool = true;

        for (0..rows) |row| {
            const num = try std.fmt.parseInt(u64, arr.items[row].items[col], 10);

            if (first) {
                result = num;
                first = false;
            } else {
                if (std.mem.eql(u8, op, "*")) result *= num;
                if (std.mem.eql(u8, op, "+")) result += num;
            }
        }

        p1 += result;
    }

    var p2: u64 = 0;
    var op: u8 = ' ';
    var st = std.ArrayList(u64).init(allocator);
    defer st.deinit();

    var prev_had_digit = false;

    for (0..lines.items[0].len) |i| {
        if (lines.items[rows][i] == '*' or lines.items[rows][i] == '+')
            op = lines.items[rows][i];

        var num: u64 = 0;
        var curr_had_digit = false;

        for (0..rows) |r| {
            const char = lines.items[r][i];

            if (char >= '0' and char <= '9') {
                curr_had_digit = true;
                num = num * 10 + @as(u64, char - '0');
            }
        }

        if (curr_had_digit) {
            try st.append(num);
        }

        if (prev_had_digit and !curr_had_digit) {
            var res: u64 = if (op == '*') 1 else 0;

            for (st.items) |v| {
                if (op == '*') res *= v else res += v;
            }

            p2 += res;
            st.clearAndFree();
        }

        prev_had_digit = curr_had_digit;
    }

    if (st.items.len > 0) {
        var res: u64 = if (op == '*') 1 else 0;

        for (st.items) |v| {
            if (op == '*') res *= v else res += v;
        }

        p2 += res;
    }

    std.debug.print("{d}\n{d}", .{ p1, p2 });
}
