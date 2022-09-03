const std = @import("std");
const log = std.log;
const ArrayList = std.ArrayList;
const cwd = std.fs.cwd;
const GPA = std.heap.GeneralPurposeAllocator(.{});
const File = std.fs.File;
const expect = std.testing.expect;

const bf = @import("./bf.zig");
const tokens = bf.tokens;
const parseBf = tokens.parseBf;
const TokenList = tokens.TokenList;

const run_code = bf.runner.run_code;

pub fn main() !void {
    var gpa = GPA{};
    defer {
        const leaked = gpa.deinit();
        if (leaked) @panic("TEST FAIL"); //fail test; can't try in defer as defer is executed after we return
    }

    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len <= 1) {
        log.err("Please provide a file to interperte", .{});
        return;
    }

    const last = args[args.len - 1];

    const file = try cwd().openFile(@as([]const u8, last), File.OpenFlags{ .mode = .read_only });
    defer file.close();

    var source = TokenList.init(alloc);
    defer source.deinit();

    try parseBf(file, &source, alloc);

    try run_code(source, alloc);
}
