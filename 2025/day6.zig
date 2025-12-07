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

    var total: i64 = 0;

    var c: usize = cols;
    while (c > 0) : (c -= 1) {
        const col = c - 1;

        const op = arr.items[rows].items[col];
        const isMul = std.mem.eql(u8, op, "*");

        var result: i64 = if (isMul) 1 else 0;

        for (0..rows) |r| {
            const val = try std.fmt.parseInt(i64, arr.items[r].items[col], 10);

            if (isMul)
                result *= val
            else
                result += val;
        }

        total += result;
    }

    std.debug.print("{d}\n{d}", .{ p1, total });
}
