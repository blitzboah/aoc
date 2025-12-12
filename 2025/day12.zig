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

const Shape = struct {
    shape_size: u32,
};

const Present = struct {
    area: u32,
    arr: std.ArrayList(u32),
};

fn parseShape(shapes: *std.ArrayList(Shape), lines: *std.ArrayList([]u8)) !void {
    var i: usize = 0;
    while (i < lines.items.len) {
        const line = lines.items[i];

        if (line.len == 0) {
            i += 1;
            continue;
        }

        if (std.mem.indexOf(u8, line, "x")) |_| {
            return;
        }

        if (std.mem.indexOf(u8, line, ":")) |_| {
            var size: u32 = 0;

            for (0..3) |_| {
                i += 1;
                if (i >= lines.items.len) break;
                const shape_line = lines.items[i];
                for (shape_line) |ch| {
                    if (ch == '#') size += 1;
                }
            }

            try shapes.append(.{ .shape_size = size });
        }

        i += 1;
    }
}

fn parsePresent(present: *std.ArrayList(Present), lines: *std.ArrayList([]u8), allocator: std.mem.Allocator) !void {
    var splitterFound: bool = false;

    for (0..lines.items.len) |i| {
        const line = lines.items[i];

        if (line.len == 0) continue;

        if (!splitterFound) {
            if (std.mem.indexOf(u8, line, "x") != null) {
                splitterFound = true;
            } else continue;
        }

        const idx = std.mem.indexOf(u8, line, ":");
        var dim = std.mem.splitSequence(u8, line[0..idx.?], "x");
        var count = std.mem.splitSequence(u8, line[idx.? + 1 ..], " ");
        var needed = std.ArrayList(u32).init(allocator);

        var area: u32 = 1;
        while (dim.next()) |d| {
            area *= try std.fmt.parseInt(u32, d, 10);
        }

        while (count.next()) |c| {
            if (c.len > 0)
                try needed.append(try std.fmt.parseInt(u32, c, 10));
        }

        try present.append(.{
            .area = area,
            .arr = needed,
        });
    }
}

fn definitelyFits(shapes: std.ArrayList(Shape), area: u32, arr: std.ArrayList(u32)) bool {
    var totalArea: u32 = 0;

    for (arr.items, 0..) |times, i| {
        if (i >= shapes.items.len) break;
        if (times == 0) continue;

        totalArea += times * shapes.items[i].shape_size;
    }

    return totalArea <= area;
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

    var shapes = std.ArrayList(Shape).init(allocator);
    defer shapes.deinit();

    var present = std.ArrayList(Present).init(allocator);
    defer present.deinit();

    try parseShape(&shapes, &lines);
    try parsePresent(&present, &lines, allocator);

    var total: usize = 0;

    for (present.items) |p| {
        if (definitelyFits(shapes, p.area, p.arr))
            total += 1;
    }

    std.debug.print("{d}", .{total});
}
