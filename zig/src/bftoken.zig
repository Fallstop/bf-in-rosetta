const std = @import("std");
const ArrayList = std.ArrayList;
const bufferedReader = std.io.bufferedReader;
const File = std.fs.File;

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
};

pub fn parseBf(file: File, buffer: *TokenList) !void {
    var fileReader = file.reader();
    var buffReader = bufferedReader(fileReader);
    var reader = buffReader.reader();

    var char: [1]u8 = undefined;

    var prev: ?BfToken = null;

    while (try reader.read(&char) != 0) {
        if (BfToken.fromChar(char)) |read| {
            if (prev) |*prevToken| {
                if (@as(BfTokenTag, prevToken.*) == @as(BfTokenTag, read)) {
                    prevToken.inc();
                } else {
                    try buffer.append(prevToken.*);
                    if (read.hasVal())
                        prev = read;
                }
            } else if (read.hasVal()) {
                prev = read;
            } else {
                prev = null;
            }
        }
    }

    if (prev) |prevToken| {
        try buffer.append(prevToken);
    }
}

test "parse file" {
    var alloc = std.testing.allocator_instance;

    const tempFile = try std.fs.cwd().createFile("test.bf", .{ .mode = .read_write });
    tempFile.writeAll("+++--[><<>]");

    var buffer = TokenList.init(alloc);
    defer buffer.deinit();

    parseBf(tempFile, &buffer);

    std.log.info("{any}", .{buffer});
}
