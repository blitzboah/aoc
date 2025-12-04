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

fn checkAdjacent(lines: *std.ArrayList([]u8), i: usize, j: usize) bool {
    var count: u8 = 0;

    const row = lines.items.len;
    const col = lines.items[0].len;

    const dirs: [8][2]isize = .{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, 1 }, .{ 0, -1 }, .{ 1, 1 }, .{ 1, 0 }, .{ 1, -1 } };

    for (dirs) |dir| {
        const newRow: isize = @as(isize, @intCast(i)) + dir[0];
        const newCol: isize = @as(isize, @intCast(j)) + dir[1];

        if (newRow < 0 or newRow >= row or newCol < 0 or newCol >= col) continue;

        if (lines.items[@intCast(newRow)][@intCast(newCol)] == '@') count += 1;
    }

    return count < 4;
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

    var count: u32 = 0;
    var removedAny: bool = true;
    while (removedAny) {
        removedAny = false;
        for (0..lines.items.len) |i| {
            for (0..lines.items[i].len) |j| {
                if (lines.items[i][j] != '@') continue;

                if (checkAdjacent(&lines, i, j)) {
                    count += 1;
                    lines.items[i][j] = '.';
                    removedAny = true;
                }
            }
        }
    }

    std.debug.print("{d}", .{count});
}
