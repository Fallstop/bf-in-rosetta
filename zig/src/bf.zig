const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const io = std.io;
const clap = @import("clap");

pub fn create_jump_map(allocator: Allocator, code: []u8) !std.AutoHashMap(usize, usize) {
    var jump_stack = ArrayList(usize).init(allocator);
    defer jump_stack.deinit();
    var jump_map = AutoHashMap(usize, usize).init(allocator);
    errdefer jump_map.deinit();

    var index: usize = 0;
    while (index < code.len) {
        switch (code[index]) {
            '[' => try jump_stack.append(index),
            ']' => {
                const left = jump_stack.popOrNull() orelse return error.UnmatchedCloseBrace;
                try jump_map.put(left, index);
                try jump_map.put(index, left);
            },
            else => {},
        }

        index += 1;
    }

    if (jump_stack.items.len != 0) {
        return error.UnmatchedOpenBrace;
    }

    return jump_map;
}

pub fn BfArgs(comptime T: type) type {
    return struct {
        in: *const fn () T,
        out: *const fn (value: T) void,
        inc: *const fn (value: *T) void,
        dec: *const fn (value: *T) void,
    };
}

pub fn run(allocator: Allocator, comptime T: type, init: T, args: BfArgs(T), code: []u8) !void {
    var mem = [_]T{init} ** 30_000;
    var pointer: usize = 0;
    var code_pointer: usize = 0;
    var jump_map = try create_jump_map(allocator, code);
    defer jump_map.deinit();

    while (code_pointer < code.len) {
        // std.debug.print(" Instruction: {c}, Code Pointer {d}", .{ code[code_pointer], code_pointer });
        switch (code[code_pointer]) {
            '+' => args.inc(&mem[pointer]),
            '-' => args.dec(&mem[pointer]),

            '.' => args.out(mem[pointer]),
            ',' => mem[pointer] = args.in(),

            '>' => {
                if (pointer == 29_999) {
                    pointer = 0;
                } else {
                    pointer += 1;
                }
            },
            '<' => {
                if (pointer == 0) {
                    pointer = 29_999;
                } else {
                    pointer -= 1;
                }
            },

            '[' => {
                if (mem[pointer] == 0) {
                    code_pointer = jump_map.get(code_pointer) orelse unreachable;
                }
            },
            ']' => {
                if (mem[pointer] != 0) {
                    code_pointer = jump_map.get(code_pointer) orelse unreachable;
                }
            },

            else => {},
        }
        code_pointer += 1;
    }
}
