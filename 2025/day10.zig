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

const State = struct {
    lights: std.ArrayList(u1),
    presses: u32,
};

fn parseMachine(allocator: std.mem.Allocator, line: []u8) !u32 {
    var buttons = std.ArrayList(std.ArrayList(usize)).init(allocator);
    defer {
        for (buttons.items) |btn| {
            btn.deinit();
        }
        buttons.deinit();
    }

    var target = std.ArrayList(u1).init(allocator);
    defer target.deinit();

    var parts = std.mem.splitSequence(u8, line, "[");
    _ = parts.next();
    const after_bracket = parts.next().?;
    var diagram_parts = std.mem.splitSequence(u8, after_bracket, "]");
    const diagram = diagram_parts.next().?;

    for (diagram) |c| {
        try target.append(if (c == '#') 1 else 0);
    }

    var button_parts = std.mem.splitSequence(u8, line, "(");
    _ = button_parts.next();

    while (button_parts.next()) |button_str| {
        var button = std.ArrayList(usize).init(allocator);
        var close_paren = std.mem.splitSequence(u8, button_str, ")");
        const content = close_paren.next().?;

        var nums = std.mem.splitSequence(u8, content, ",");
        while (nums.next()) |num_str| {
            const trimmed = std.mem.trim(u8, num_str, " ");
            try button.append(try std.fmt.parseInt(usize, trimmed, 10));
        }
        try buttons.append(button);
    }

    var start = std.ArrayList(u1).init(allocator);
    for (0..target.items.len) |_| {
        try start.append(0);
    }

    var queue = std.ArrayList(State).init(allocator);
    defer {
        for (queue.items) |state| {
            state.lights.deinit();
        }
        queue.deinit();
    }

    var visited = std.ArrayList(std.ArrayList(u1)).init(allocator);
    defer visited.deinit();

    try queue.append(.{
        .lights = start,
        .presses = 0,
    });
    try visited.append(start);

    if (std.mem.eql(u1, start.items, target.items)) return 0;

    while (queue.items.len > 0) {
        const cur = queue.orderedRemove(0);

        for (buttons.items) |button| {
            var new_lights = std.ArrayList(u1).init(allocator);
            for (cur.lights.items) |light| {
                try new_lights.append(light);
            }

            for (button.items) |light_idx| {
                new_lights.items[light_idx] ^= 1;
            }

            if (std.mem.eql(u1, new_lights.items, target.items)) {
                new_lights.deinit();
                return cur.presses + 1;
            }

            var already_visited = false;
            for (visited.items) |v| {
                if (std.mem.eql(u1, v.items, new_lights.items)) {
                    already_visited = true;
                    break;
                }
            }

            if (!already_visited) {
                try visited.append(new_lights);
                try queue.append(.{
                    .lights = new_lights,
                    .presses = cur.presses + 1,
                });
            } else {
                new_lights.deinit();
            }
        }
    }

    return 0;
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

    var total: u32 = 0;

    for (lines.items) |line| {
        total += parseMachine(allocator, line) catch continue;
    }

    std.debug.print("{d}\n", .{total});
}
