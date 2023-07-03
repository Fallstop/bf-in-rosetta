const bf = @import("./bf.zig");
const clap = @import("clap");
const std = @import("std");

const debug = std.debug;
const io = std.io;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // First we specify what parameters our program can take.
    // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`
    const params = comptime clap.parseParamsComptime(
        \\-h,   --help                 Display this help and exit.
        \\-m,   --mode <MODE>          Weather to use ASCII mode or int mode
        \\<FILE>                       The BrainFuck source code to be interperated 
        \\
    );

    // Declare our own parsers which are used to map the argument strings to other
    // types.
    const Mode = enum { ascii, int };
    const parsers = comptime .{
        .FILE = clap.parsers.string,
        .MODE = clap.parsers.enumeration(Mode),
    };

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0 or res.positionals.len != 1) {
        _ = try std.io.getStdErr().writer().write("Useage: bf ");
        try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
        _ = try std.io.getStdErr().writer().write("\n");
        try clap.help(std.io.getStdErr().writer(), clap.Help, &params, clap.HelpOptions{});
    }

    const file = try std.fs.cwd().openFile(res.positionals[0], std.fs.File.OpenFlags{ .mode = .read_only });
    defer file.close();

    // If you program is more then 30_000 charcters long, tf you doing?
    const code = try file.reader().readAllAlloc(allocator, 30_000);
    defer allocator.free(code);

    switch (res.args.mode orelse .ascii) {
        .ascii => try bf.run(allocator, u8, 0, .{ .in = in_u8, .out = out_u8, .inc = inc_u8, .dec = dec_u8 }, code),
        .int => try bf.run(allocator, i64, 0, .{ .in = in_int, .out = out_int, .inc = inc_int, .dec = dec_int }, code),
    }
}

fn in_u8() u8 {
    _ = std.io.getStdOut().writer().print("?", .{}) catch void;
    return std.io.getStdIn().reader().readByte() catch 0;
}

fn out_u8(value: u8) void {
    _ = std.io.getStdOut().writer().writeByte(value) catch void;
}

fn inc_u8(value: *u8) void {
    value.* = value.* +% 1;
}

fn dec_u8(value: *u8) void {
    value.* = value.* -% 1;
}

fn in_int() i64 {
    _ = std.io.getStdOut().writer().print("?", .{}) catch void;
    var buffer = [_]u8{undefined} ** 20;
    _ = std.io.getStdIn().reader().readUntilDelimiter(&buffer, 10) catch return 0;
    var trimmed = std.mem.trimRight(u8, &buffer, &[_]u8{ ' ', '\n', 0, undefined });
    const val = std.fmt.parseInt(i64, trimmed, 10) catch blk: {
        std.debug.print("Invaild input \"{s}\" assuming 0", .{trimmed});
        break :blk 0;
    };
    return val;
}

fn out_int(value: i64) void {
    _ = std.io.getStdOut().writer().print("{d}\n", .{value}) catch void;
}

fn inc_int(value: *i64) void {
    value.* = value.* +% 1;
}

fn dec_int(value: *i64) void {
    value.* = value.* -% 1;
}
