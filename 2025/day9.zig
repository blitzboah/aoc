const std = @import("std");

const Edge = struct {
    x1: i64,
    y1: i64,
    x2: i64,
    y2: i64,
};

fn sort(a: i64, b: i64) struct { i64, i64 } {
    if (a < b) {
        return .{ a, b };
    } else {
        return .{ b, a };
    }
}

fn abs64(x: i64) i64 {
    if (x < 0) return -x;
    return x;
}

fn rectangleArea(x1: i64, y1: i64, x2: i64, y2: i64) u64 {
    return (@abs(x2 - x1) + 1) * (@abs(y2 - y1) + 1);
}

fn manhattanDistance(a: [2]i64, b: [2]i64) i64 {
    return abs64(a[0] - b[0]) + abs64(a[1] - b[1]);
}

fn intersections(minX: i64, minY: i64, maxX: i64, maxY: i64, edges: []Edge) bool {
    for (edges) |edge| {
        const sorted_x = sort(edge.x1, edge.x2);
        const sorted_y = sort(edge.y1, edge.y2);
        const iMinX = sorted_x[0];
        const iMaxX = sorted_x[1];
        const iMinY = sorted_y[0];
        const iMaxY = sorted_y[1];

        if (minX < iMaxX and maxX > iMinX and minY < iMaxY and maxY > iMinY) {
            return true;
        }
    }
    return false;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);
    _ = try file.readAll(buffer);

    var lines = std.ArrayList([]u8).init(allocator);
    defer lines.deinit();

    var index: usize = 0;
    for (0..buffer.len) |i| {
        if (buffer[i] == '\n') {
            try lines.append(buffer[index..i]);
            index = i + 1;
        }
    }

    var redTiles = std.ArrayList([2]i64).init(allocator);
    defer redTiles.deinit();

    var edges = std.ArrayList(Edge).init(allocator);
    defer edges.deinit();

    var initX: i64 = 0;
    var initY: i64 = 0;
    var lastX: i64 = 0;
    var lastY: i64 = 0;

    for (0..lines.items.len) |lineIdx| {
        var it = std.mem.splitSequence(u8, lines.items[lineIdx], ",");
        const x = try std.fmt.parseInt(i64, it.next().?, 10);
        const y = try std.fmt.parseInt(i64, it.next().?, 10);

        if (lineIdx == 0) {
            initX = x;
            initY = y;
        }

        if (lineIdx > 0) {
            var prevIt = std.mem.splitSequence(u8, lines.items[lineIdx - 1], ",");
            const prevX = try std.fmt.parseInt(i64, prevIt.next().?, 10);
            const prevY = try std.fmt.parseInt(i64, prevIt.next().?, 10);

            try edges.append(.{ .x1 = prevX, .y1 = prevY, .x2 = x, .y2 = y });
            try redTiles.append(.{ prevX, prevY });
        }

        lastX = x;
        lastY = y;
    }

    try edges.append(.{ .x1 = initX, .y1 = initY, .x2 = lastX, .y2 = lastY });
    try redTiles.append(.{ lastX, lastY });

    var result: u64 = 0;

    for (0..redTiles.items.len - 1) |fTIdx| {
        for (fTIdx..redTiles.items.len) |tTIdx| {
            const fromTile = redTiles.items[fTIdx];
            const toTile = redTiles.items[tTIdx];

            const sorted_x = sort(fromTile[0], toTile[0]);
            const sorted_y = sort(fromTile[1], toTile[1]);
            const minX = sorted_x[0];
            const maxX = sorted_x[1];
            const minY = sorted_y[0];
            const maxY = sorted_y[1];

            const manhattan = manhattanDistance(fromTile, toTile);
            if (manhattan * manhattan > @as(i64, @intCast(result))) {
                if (!intersections(minX, minY, maxX, maxY, edges.items)) {
                    const area = rectangleArea(fromTile[0], fromTile[1], toTile[0], toTile[1]);
                    if (area > result) {
                        result = area;
                    }
                }
            }
        }
    }

    std.debug.print("{d}\n", .{result});
}
