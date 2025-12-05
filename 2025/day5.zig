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

fn checkRange(num: u64, range: *std.ArrayList([2]u64)) bool {
    for (0..range.items.len) |i| {
        if (num >= range.items[i][0] and num <= range.items[i][1]) return true;
    }
    return false;
}

fn compare(_: void, left: [2]u64, right: [2]u64) bool {
    return left[0] < right[0];
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

    var p1: u64 = 0;
    var p2: u64 = 0;
    var index: usize = undefined;

    var range = std.ArrayList([2]u64).init(allocator);
    defer range.deinit();

    for (0..lines.items.len) |i| {
        const line = lines.items[i];

        if (line.len == 0) {
            index = i;
            break;
        }

        var r = std.mem.splitSequence(u8, line, "-");

        var num1: u64 = 0;
        var num2: u64 = 0;

        if (r.next()) |n1| {
            num1 = try std.fmt.parseInt(u64, n1, 10);
        }

        if (r.next()) |n1| {
            num2 = try std.fmt.parseInt(u64, n1, 10);
        }

        try range.append([2]u64{ num1, num2 });
    }

    for (index + 1..lines.items.len) |num| {
        const n = try std.fmt.parseInt(u64, lines.items[num], 10);

        if (checkRange(n, &range)) p1 += 1;
    }

    std.mem.sort([2]u64, range.items, {}, compare);

    var overlap: [2]u64 = .{ 0, 0 };
    for (range.items) |ran| {
        if (ran[0] <= overlap[1]) {
            overlap[1] = @max(ran[1], overlap[1]);
        } else {
            p2 += (overlap[1] - overlap[0] + 1);
            overlap = ran;
        }
    }

    p2 += (overlap[1] - overlap[0] + 1);

    std.debug.print("{d}\n", .{p1});
    std.debug.print("{d}\n", .{p2 - 1});
}
