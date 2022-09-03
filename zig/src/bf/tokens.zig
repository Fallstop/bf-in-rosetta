const std = @import("std");
const ArrayList = std.ArrayList;
const bufferedReader = std.io.bufferedReader;
const File = std.fs.File;
const expect = std.testing.expect;

pub const TokenList = ArrayList(BfToken);
pub const BfTokenTag = enum { add, sub, lft, rgh, opn, cls, in, out };

pub const BfToken = union(BfTokenTag) {
    add: u32,
    sub: u32,
    lft: u32,
    rgh: u32,
    opn,
    cls,
    in,
    out,

    pub fn fromChar(char: [1]u8) ?BfToken {
        switch (char[0]) {
            '+' => {
                return .{ .add = 1 };
            },
            '-' => {
                return .{ .sub = 1 };
            },
            '<' => {
                return .{ .lft = 1 };
            },
            '>' => {
                return .{ .rgh = 1 };
            },
            '.' => {
                return BfToken.out;
            },
            ',' => {
                return BfToken.in;
            },
            '[' => {
                return BfToken.opn;
            },
            ']' => {
                return BfToken.cls;
            },
            else => {
                return null;
            },
        }
    }

    pub fn inc(self: *BfToken) void {
        switch (self.*) {
            .add, .sub, .lft, .rgh => |*value| {
                value.* += 1;
            },
            else => {},
        }
    }

    pub fn hasVal(self: *const BfToken) bool {
        switch (self.*) {
            .add, .sub, .lft, .rgh => {
                return true;
            },
            else => return false,
        }
    }

    pub fn eql(self: *const BfToken, other: BfToken) bool {
        if (@as(BfTokenTag, self.*) == @as(BfTokenTag, other)) {
            if (self.hasVal()) {
                switch (self.*) {
                    .add, .sub, .lft, .rgh => |selfVal| {
                        switch (other) {
                            .add, .sub, .lft, .rgh => |otherVal| {
                                return selfVal == otherVal;
                            },
                            else => {
                                unreachable;
                            },
                        }
                    },
                    else => {
                        unreachable;
                    },
                }
            } else {
                return true;
            }
        } else {
            return false;
        }
    }
};

pub fn parseBf(file: File, buffer: *TokenList, allocator: std.mem.Allocator) !void {
    const meta = try file.metadata();
    const size = meta.size();
    var reader = file.reader();
    var prev: ?BfToken = null;

    const fileBuffer = try reader.readAllAlloc(allocator, size);
    defer allocator.destroy(fileBuffer.ptr);

    std.log.info("{s}", .{fileBuffer});

    for (fileBuffer) |char| {
        if (BfToken.fromChar([1]u8{char})) |read| {
            if (prev) |*prevToken| {
                if (@as(BfTokenTag, prevToken.*) == @as(BfTokenTag, read)) {
                    prevToken.inc();
                } else {
                    try buffer.append(prevToken.*);
                    // std.log.debug("Adding token {any}", .{prevToken.*});
                    if (read.hasVal()) {
                        prev = read;
                    } else {
                        try buffer.append(read);
                        // std.log.debug("Adding token {any}", .{read});

                        prev = null;
                    }
                }
            } else if (read.hasVal()) {
                prev = read;
            } else {
                prev = null;
                try buffer.append(read);
                // std.log.debug("Adding token {any}", .{read});
            }
        }
    }

    if (prev) |prevToken| {
        try buffer.append(prevToken);
        // std.log.debug("Adding token {any}", .{prevToken});
    }
}
