const std = @import("std");

const tokens = @import("./tokens.zig");
const BfToken = tokens.BfToken;
const TokenList = tokens.TokenList;

pub fn run_code(source: TokenList, allocator: std.mem.Allocator) !void {
    var mem = [_]u8{0} ** 30_000;
    var mem_ptr = &mem[0];
    const mem_end = @ptrToInt(&mem[29_999]);
    const mem_start = @ptrToInt(mem_ptr);

    var jump_stack = std.ArrayList(usize).init(allocator);
    defer jump_stack.deinit();

    var cp = @ptrToInt(&source.items[0]);
    const end = @ptrToInt(&source.items[source.items.len - 1]);

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    while (cp < end) {
        std.log.info("{any}", .{tokenAt(cp)});
        switch (tokenAt(cp)) {
            .add => |count| {
                const vals = @ptrCast(*[4]u8, &count).*;
                std.log.debug("{d} + {d} ({d})", .{ mem_ptr.*, count, vals });
                for (vals) |val| {
                    mem_ptr.* +%= val;
                }
            },
            .sub => |count| {
                const vals = @ptrCast(*[4]u8, &count).*;
                std.log.debug("{d} - {d} ({d})", .{ mem_ptr.*, count, vals });
                for (vals) |val| {
                    mem_ptr.* -%= val;
                }
            },
            .lft => |count| {
                mem_ptr = @intToPtr(*u8, @ptrToInt(mem_ptr) - @sizeOf(u8) * count);
                if (@ptrToInt(mem_ptr) < mem_start) {
                    mem_ptr = @intToPtr(*u8, mem_end);
                }

                std.log.debug("{d}", .{@ptrToInt(mem_ptr) - mem_start});
            },
            .rgh => |count| {
                mem_ptr = @intToPtr(*u8, @ptrToInt(mem_ptr) + @sizeOf(u8) * count);
                if (@ptrToInt(mem_ptr) > mem_end) {
                    mem_ptr = @intToPtr(*u8, mem_start);
                }

                std.log.debug("{d}", .{@ptrToInt(mem_ptr) - mem_start});
            },
            .in => {
                var buf: [10]u8 = undefined;

                try stdout.print("\n> ", .{});

                if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
                    mem_ptr.* = std.fmt.parseInt(u8, user_input, 10) catch |ex| blk: {
                        std.log.err("Countn't cast int: {any}", .{ex});
                        break :blk 0;
                    };
                    std.log.info("{d}", .{mem_ptr.*});
                } else {
                    mem_ptr.* = @as(u8, 0);
                }
            },
            .out => {
                try stdout.print("# {d}\n", .{mem_ptr.*});
            },
            .cls => {
                cp = jump_stack.pop();
                continue;
            },
            .opn => {
                std.log.debug("{d}", .{mem_ptr.*});
                std.log.debug("{d}", .{(cp - @ptrToInt(&source.items[0])) / @sizeOf(BfToken)});

                if (mem_ptr.* == 0) {
                    var count = @as(u32, 1);

                    while (count > 0) {
                        cp += @sizeOf(BfToken);
                        std.log.debug("{d} {any} {d}", .{ count, tokenAt(cp), count });
                        switch (tokenAt(cp)) {
                            .opn => {
                                count += 1;
                            },
                            .cls => {
                                count -= 1;
                            },
                            else => {},
                        }
                    }
                } else {
                    try jump_stack.append(cp);
                }

                std.log.debug("{d}", .{(cp - @ptrToInt(&source.items[0])) / @sizeOf(BfToken)});
            },
        }
        cp += @sizeOf(BfToken);
    }
}

fn tokenAt(addr: usize) BfToken {
    return @intToPtr(*BfToken, addr).*;
}
