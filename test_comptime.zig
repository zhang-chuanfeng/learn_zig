const std = @import("std");
const expect = std.testing.expect;

fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

fn gimmeTheBiggerFloat(a: f32, b: f32) f32 {
    return max(f32, a, b);
}

fn gimmeTheBigerInterger(a: u64, b: u64) u64 {
    return max(u64, a, b);
}

// Compile-Time Variables
const CmdFn = struct {
    name: []const u8,
    func: fn (i32) i32,
};

const cmd_fns = [_]CmdFn{
    CmdFn{ .name = "one", .func = one },
    CmdFn{ .name = "two", .func = two },
    CmdFn{ .name = "three", .func = three },
};

fn one(value: i32) i32 {
    return value + 1;
}
fn two(value: i32) i32 {
    return value + 2;
}
fn three(value: i32) i32 {
    return value + 3;
}

fn performFn(comptime prefix_char: u8, start_value: i32) i32 {
    var result: i32 = start_value;
    comptime var i = 0;
    inline while (i < cmd_fns.len) : (i += 1) {
        if (cmd_fns[i].name[0] == prefix_char) {
            result = cmd_fns[i].func(result);
        }
    }
    return result;
}
// performFn is generated three different times
test "perform fn" {
    try expect(performFn('t', 1) == 6);
    try expect(performFn('o', 0) == 1);
    try expect(performFn('w', 99) == 99);
}

// Compile-Time Expressions

// it doesn't make sense that a progran could call eixt()
// (or any other external function) at compile-time, so this is a
// compile error.
// all variables are comptime variables.
// all if, while, for, and switch expressions are evaluated at
// compile-time, or emit a compile error if this is not possible.
// All return and try expressions are invalid

fn fibonacci(index: u32) u32 {
    if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

test "fibonacci" {
    // test fibonacci at run-time
    try expect(fibonacci(7) == 13);

    // test fibonacci at compile-time
    try expect(fibonacci(7) == 13);
}

const first_25_primes = firstNPrimes(25);
const sum_of_first_primes = sum(&first_25_primes);

fn firstNPrimes(comptime n: usize) [n]i32 {
    var prime_list: [n]i32 = undefined;
    var next_index: usize = 0;
    var tes_number: i32 = 2;
    while (next_index < prime_list.len) : (tes_number += 1) {
        var tes_prime_index: usize = 0;
        var is_prime = true;
        while (tes_prime_index < next_index) : (tes_prime_index += 1) {
            if (tes_number % prime_list[tes_prime_index] == 0) {
                is_prime = false;
                break;
            }
        }
        if (is_prime) {
            prime_list[next_index] = tes_number;
            next_index += 1;
        }
    }
    return prime_list;
}

fn sum(numbers: []const i32) i32 {
    var result: i32 = 0;
    for (numbers) |x| {
        result += x;
    }
    return result;
}

test "variable values" {
    try expect(sum_of_first_primes == 1060);
}

// generic data structure
fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
    };
}

// The generic List data structure can be instantiated by
// a type
var buffer: [10]i32 = undefined;
var list = List(i32){ .items = &buffer, .len = 0 };

// anonymous struct name
const Node = struct {
    next: ?*Node,
    name: []const u8,
};

var node_a = Node{
    .next = null,
    .name = &"Node A",
};

var node_b = Node{
    .next = &node_a,
    .name = &"Node B",
};
