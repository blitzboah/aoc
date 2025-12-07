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

fn backTrack(
    memo: *std.AutoHashMap(u64, u64),
    lines: *std.ArrayList([]u8),
    i: usize,
    j: isize,
) u64 {
    if (i == lines.items.len) return 1;
    if (j < 0 or j >= lines.items[i].len) return 0;

    const key = (@as(u64, i) << 32) | @as(u64, @intCast(j));
    if (memo.get(key)) |result| {
        return result;
    }

    const col = @as(usize, @intCast(j));
    var total: u64 = 0;

    if (lines.items[i][col] == '^') {
        total += backTrack(memo, lines, i + 1, j - 1);
        total += backTrack(memo, lines, i + 1, j + 1);
    } else {
        total += backTrack(memo, lines, i + 1, j);
    }

    memo.put(key, total) catch unreachable;
    return total;
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

    var buf = std.ArrayList(u8).init(allocator);
    var buff = std.ArrayList(u8).init(allocator);

    defer buf.deinit();
    defer buff.deinit();

    for (0..lines.items[0].len) |_| {
        try buf.append(0);
        try buff.append(0);
    }

    var p1: u64 = 0;
    var p2: u64 = 0;

    var foundS: bool = false;

    for (0..lines.items.len) |i| {
        const line = lines.items[i];
        for (0..line.len) |j| {
            if (!foundS and lines.items[i][j] == 'S') {
                buf.items[j] = 1;
                buff.items[j] = 1;
                foundS = true;

                var memo = std.AutoHashMap(u64, u64).init(allocator);
                defer memo.deinit();
                p2 += backTrack(&memo, &lines, 1, @as(i32, @intCast(j)));

                continue;
            }

            if (lines.items[i][j] == '^' and buf.items[j] == 1) {
                buf.items[j] = 0;
                if (j - 1 >= 0) buf.items[j - 1] = 1;
                if (j + 1 < lines.items[i].len) buf.items[j + 1] = 1;
                p1 += 1;
            }
        }
    }

    std.debug.print("{d}\n", .{p1});
    std.debug.print("{d}\n", .{p2});
}
