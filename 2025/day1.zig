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

    var dials = std.ArrayList([]const u8).init(allocator);
    defer dials.deinit();

    const LINE_COUNT: usize = lines.items.len;

    for (0..LINE_COUNT) |i| {
        dials.append(lines.items[i]) catch unreachable;
    }

    // zamn
    var count: i64 = 0;
    var dialPos: i64 = 50;
    for (dials.items) |d| {
        const str = d;
        const direction = str[0];
        const number_string = str[1..];
        const value: i64 = try std.fmt.parseInt(i64, number_string, 10);

        const step: i64 = if (direction == 'L') -1 else 1;

        for (0..@intCast(value)) |_| {
            dialPos = @mod(dialPos + step, 100);
            if (dialPos == 0) {
                count += 1;
            }
        }
    }
    std.debug.print("{d}", .{count});
}
