const std = @import("std");
const ArrayList = std.ArrayList;
const File = std.fs.File;
const expect = std.testing.expect;

pub const BfParseError = error{ ZeroLenSource, UnknownToken };

pub const BfEnum = union(enum) {
    Add: u32,
    Minus: u32,
    Left: u32,
    Right: u32,
    Out,
    In,
    Open,
    Close,
    pub fn fromChar(char: u8) !BfEnum {
        return switch (char) {
            '+' => {
                .{ .Add = 1 };
            },
            '-' => {
                .{ .Minus = 1 };
            },
            '<' => {
                .{ .Left = 1 };
            },
            '>' => {
                .{ .Right = 1 };
            },
            '.' => {
                .{.Out};
            },
            ',' => {
                .{.In};
            },
            '[' => {
                .{.Open};
            },
            ']' => {
                .{.Close};
            },
            else => {
                BfParseError.UnknownToken;
            },
        };
    }

    pub fn is(self: *const BfEnum, other: BfEnum) bool {
        return switch (self) {
            .Add => {
                return switch (other) {
                    .Add => true,
                    else => false,
                };
            },
            .Minus => {
                return switch (other) {
                    .Minus => true,
                    else => false,
                };
            },
            .Left => {
                return switch (other) {
                    .Left => true,
                    else => false,
                };
            },
            .Right => {
                return switch (other) {
                    .Right => true,
                    else => false,
                };
            },
            .Out => {
                return switch (other) {
                    .Out => true,
                    else => false,
                };
            },
            .In => {
                return switch (other) {
                    .In => true,
                    else => false,
                };
            },
            .Open => {
                return switch (other) {
                    .Open => true,
                    else => false,
                };
            },
            .Close => {
                return switch (other) {
                    .Close => true,
                    else => false,
                };
            },
        };
    }

    pub fn inc(self: *BfEnum) void {
        switch (self) {
            .Add | .Minus | .Left | .Right => |i| i += 1,
        }
    }

    pub fn hasVal(self: *const BfEnum) bool {
        return switch (self) {
            .Add | .Minus | .Left | .Right => false,
        };
    }
};

pub fn parseFromFile(file: File, buffer: *ArrayList(BfEnum)) !void {
    const fileReader = file.reader();
    const buffReader = std.io.bufferedReader(fileReader);
    const reader = buffReader.reader();

    var char: [1]u8 = {};

    var prev: ?BfEnum = null;

    while (try reader.read(*char) != 0) {
        if (BfEnum.fromChar(char[0])) |value| {
            if (!value.hasVal()) {
                if (prev) |prevVal| {
                    try buffer.append(prevVal);
                }

                try buffer.append(value);
                prev = null;
            } else {
                if (prev) |prevVal| {
                    if (prevVal.is(value)) {
                        prevVal.inc();
                    } else {
                        try buffer.append(value);
                    }
                }

                prev = value;
            }
        }
    }

    if (prev) |prevValue| {
        try buffer.append(prevValue);
    }
}

test "testIs" {
    try expect((BfEnum{ .Add = 1 }).is(BfEnum{ .Add = 1 }));
    try expect((BfEnum{ .Minus = 1 }).is(BfEnum{ .Minus = 1 }));
    try expect((BfEnum{.Out}).is(BfEnum{.Out}));
    try expect((BfEnum{.In}).is(BfEnum{.In}));
    try expect((BfEnum{ .Left = 1 }).is(BfEnum{ .Left = 1 }));
    try expect((BfEnum{ .Right = 1 }).is(BfEnum{ .Right = 1 }));
    try expect((BfEnum{.Open}).is(BfEnum{.Open}));
    try expect((BfEnum{.Close}).is(BfEnum{.Close}));
}

// test "parseVal" {
//     try expect(BfEnum.fromChar('+') == BfEnum{ .Add = 1 });
//     try expect(BfEnum.fromChar('-') == BfEnum{ .Minus = 1 });
//     try expect(BfEnum.fromChar('.') == BfEnum{.Out});
//     try expect(BfEnum.fromChar(',') == BfEnum{.In});
//     try expect(BfEnum.fromChar('<') == BfEnum{ .Left = 1 });
//     try expect(BfEnum.fromChar('>') == BfEnum{ .Right = 1 });
//     try expect(BfEnum.fromChar('[') == BfEnum{.Open});
//     try expect(BfEnum.fromChar(']') == BfEnum{.Close});
// }
