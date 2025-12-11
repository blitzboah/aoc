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

const MemoKey = struct {
    node: []const u8,
    has_dac: bool,
    has_fft: bool,
};

const MemoValue = struct {
    key: MemoKey,
    value: usize,
};

fn findExit(map: *std.StringHashMap([]const u8), allocator: std.mem.Allocator) !usize {
    var total: usize = 0;

    var pq = std.ArrayList([]const u8).init(allocator);
    const val = map.getEntry("you");

    var it = std.mem.splitSequence(u8, val.?.value_ptr.*, " ");
    while (it.next()) |v| {
        try pq.append(v);
    }

    while (pq.items.len > 0) {
        const k = pq.orderedRemove(0);
        const key = map.getEntry(k);

        var itr = std.mem.splitSequence(u8, key.?.value_ptr.*, " ");
        while (itr.next()) |v| {
            if (std.mem.eql(u8, v, "out")) {
                total += 1;
                continue;
            }
            try pq.append(v);
        }
    }

    return total;
}

fn backTrack(
    map: *std.StringHashMap([]const u8),
    key: []const u8,
    visited: *std.StringHashMap(bool),
    has_dac: bool,
    has_fft: bool,
    memo: *std.ArrayList(MemoValue),
    allocator: std.mem.Allocator,
) !usize {
    if (std.mem.eql(u8, key, "out")) {
        if (has_dac and has_fft) {
            return 1;
        } else {
            return 0;
        }
    }

    if (visited.contains(key)) {
        return 0;
    }

    for (memo.items) |m| {
        if (std.mem.eql(u8, m.key.node, key) and
            m.key.has_dac == has_dac and
            m.key.has_fft == has_fft)
        {
            return m.value;
        }
    }

    try visited.put(key, true);
    defer _ = visited.remove(key);

    const entry = map.getEntry(key);
    if (entry == null) {
        return 0;
    }

    var it = std.mem.splitSequence(u8, entry.?.value_ptr.*, " ");
    var total: usize = 0;

    while (it.next()) |v| {
        const new_dac = has_dac or std.mem.eql(u8, v, "dac");
        const new_fft = has_fft or std.mem.eql(u8, v, "fft");

        total += try backTrack(map, v, visited, new_dac, new_fft, memo, allocator);
    }

    try memo.append(MemoValue{
        .key = MemoKey{
            .node = key,
            .has_dac = has_dac,
            .has_fft = has_fft,
        },
        .value = total,
    });

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

    var map = std.StringHashMap([]const u8).init(allocator);
    defer map.deinit();

    for (lines.items) |line| {
        var it = std.mem.splitSequence(u8, line, ": ");
        if (it.next()) |key| {
            if (it.next()) |val| {
                try map.put(key, val);
            }
        }
    }
    var p1: usize = 0;
    var p2: usize = 0;

    p1 += try findExit(&map, allocator);

    var visited = std.StringHashMap(bool).init(allocator);
    defer visited.deinit();

    var memo = std.ArrayList(MemoValue).init(allocator);
    defer memo.deinit();

    const entry = map.getEntry("svr");
    var it = std.mem.splitSequence(u8, entry.?.value_ptr.*, " ");
    while (it.next()) |key| {
        p2 += try backTrack(&map, key, &visited, false, false, &memo, allocator);
    }

    std.debug.print("{d}\n{d}", .{ p1, p2 });
}
