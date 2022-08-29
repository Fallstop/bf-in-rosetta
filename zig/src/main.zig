const std = @import("std");
const log = std.log;
const ArrayList = std.ArrayList;
const cwd = std.fs.cwd;
const ArrayListU8 = ArrayList(u8);

const bftoken = @import("./bftoken.zig");
const parseBf = bftoken.parse;

pub fn main() !void {
    const gpa = std.heap.GeneralPurposeAllocator(.{});
    defer gpa.deinit();

    const alloc = gpa.allocator();

    const args = std.os.argv;

    if (args.len <= 1) {
        log.err("Please provide a file to interperte", .{});
        return;
    }

    const last = args[args.len - 1];

    const file = try cwd().openFile(last, .{ .read = true });
    defer file.close();

    const source = ArrayListU8.init(alloc);
    defer source.deinit();

    parseBf(file, *source);

    log.info("{s}", .{last});
}
