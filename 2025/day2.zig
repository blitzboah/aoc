const std = @import("std");
const ArrayListAligned = std.ArrayListAligned;

fn fillLines(lines: *ArrayListAligned([]const u8, null), buffer: []const u8) void {
    const BUFFER_LENGTH: usize = buffer.len;
    var index: usize = 0;

    for (0..BUFFER_LENGTH) |i| {
        if (buffer[i] == ',') {
            lines.append(buffer[index..i]) catch unreachable;
            index = i + 1;
        }
    }

    if (index < BUFFER_LENGTH) {
        lines.append(buffer[index..BUFFER_LENGTH]) catch unreachable;
    }
}

fn isInvalidID(str: []const u8) bool {
    const len = str.len;

    for (1..len / 2 + 1) |pattern_len| {
        if (len % pattern_len != 0) continue;

        const pattern = str[0..pattern_len];
        const repetitions = len / pattern_len;

        var valid = true;
        var pos: usize = 0;
        for (0..repetitions) |_| {
            if (!std.mem.eql(u8, str[pos .. pos + pattern_len], pattern)) {
                valid = false;
                break;
            }
            pos += pattern_len;
        }

        if (valid and repetitions >= 2) {
            return true;
        }
    }

    return false;
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

    var ids = std.ArrayList([]const u8).init(allocator);
    defer ids.deinit();

    var total: u64 = 0;

    for (0..lines.items.len) |i| {
        var num1: u64 = 0;
        var num2: u64 = 0;

        const line = std.mem.trim(u8, lines.items[i], " \t\n\r");
        var range = std.mem.splitSequence(u8, line, "-");

        if (range.next()) |n1| {
            num1 = try std.fmt.parseInt(u64, n1, 10);
        }

        if (range.next()) |n2| {
            num2 = try std.fmt.parseInt(u64, n2, 10);
        }

        for (num1..num2 + 1) |num| {
            var buff: [20]u8 = undefined;
            const str = try std.fmt.bufPrint(&buff, "{}", .{num});

            if (isInvalidID(str)) {
                total += num;
            }
        }
    }

    std.debug.print("total = {d}", .{total});
}
