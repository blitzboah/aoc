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

const Coord = struct { x: i64, y: i64, z: i64 };
const Edge = struct {
    dist: f64,
    u: usize,
    v: usize,

    fn lessThan(context: void, a: Edge, b: Edge) bool {
        _ = context;
        return a.dist < b.dist;
    }
};
const Union = struct {
    parent: std.ArrayList(usize),
    size: std.ArrayList(usize),

    fn init(allocator: std.mem.Allocator, n: usize) Union {
        var parent = std.ArrayList(usize).initCapacity(allocator, n) catch unreachable;
        var size = std.ArrayList(usize).initCapacity(allocator, n) catch unreachable;

        for (0..n) |i| {
            parent.appendAssumeCapacity(i);
            size.appendAssumeCapacity(1);
        }

        return Union{
            .parent = parent,
            .size = size,
        };
    }

    fn deinit(this: *Union) void {
        this.parent.deinit();
        this.size.deinit();
    }

    fn findParent(this: *Union, x: usize) usize {
        if (this.parent.items[x] != x) {
            this.parent.items[x] = this.findParent(this.parent.items[x]);
        }

        return this.parent.items[x];
    }

    fn isUnion(this: *Union, x: usize, y: usize) bool {
        var px = this.findParent(x);
        var py = this.findParent(y);

        if (px == py) return false;

        if (this.size.items[px] < this.size.items[py]) {
            const temp = px;
            px = py;
            py = temp;
        }

        this.parent.items[py] = px;
        this.size.items[px] += this.size.items[py];

        return true;
    }
};

fn distance(c1: Coord, c2: Coord) f64 {
    const dx = @as(f64, @floatFromInt(c1.x - c2.x));
    const dy = @as(f64, @floatFromInt(c1.y - c2.y));
    const dz = @as(f64, @floatFromInt(c1.z - c2.z));

    return @sqrt(dx * dx + dy * dy + dz * dz);
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

    var arr = std.ArrayList(Coord).init(allocator);
    defer arr.deinit();

    for (0..lines.items.len) |i| {
        var line = std.mem.splitSequence(u8, lines.items[i], ",");

        try arr.append(.{
            .x = try std.fmt.parseInt(i64, line.next().?, 10),
            .y = try std.fmt.parseInt(i64, line.next().?, 10),
            .z = try std.fmt.parseInt(i64, line.next().?, 10),
        });
    }

    var edges = std.ArrayList(Edge).init(allocator);
    defer edges.deinit();

    for (0..arr.items.len) |i| {
        for (i + 1..arr.items.len) |j| {
            const dist = distance(arr.items[i], arr.items[j]);
            try edges.append(.{
                .dist = dist,
                .u = i,
                .v = j,
            });
        }
    }

    std.mem.sort(Edge, edges.items, {}, Edge.lessThan);

    var uf = Union.init(allocator, arr.items.len);
    defer uf.deinit();

    var connections: usize = 0;
    var lastU: usize = 0;
    var lastV: usize = 0;

    for (edges.items) |edge| {
        if (uf.isUnion(edge.u, edge.v)) {
            connections += 1;
            lastU = edge.u;
            lastV = edge.v;
            if (connections == arr.items.len - 1) break; // for part 1 count each connections until 1000 doenst matter if union is true or not
        }
    }

    std.debug.print("part 2 = {d} \n", .{arr.items[lastU].x * arr.items[lastV].x});

    var map = std.AutoHashMap(usize, usize).init(allocator);
    defer map.deinit();

    for (0..arr.items.len) |i| {
        const root = uf.findParent(i);
        const entry = try map.getOrPut(root);
        if (!entry.found_existing) {
            entry.value_ptr.* = 0;
        }
        entry.value_ptr.* += 1;
    }

    var sizes = std.ArrayList(usize).init(allocator);
    defer sizes.deinit();

    var it = map.valueIterator();
    while (it.next()) |size| {
        try sizes.append(size.*);
    }

    std.mem.sort(usize, sizes.items, {}, std.sort.desc(usize));

    var product: usize = 1;

    for (0..@min(3, sizes.items.len)) |i| {
        product *= sizes.items[i];
    }

    std.debug.print("part 1 = {d}\n", .{product});
}
