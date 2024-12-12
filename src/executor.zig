const std = @import("std");
const utilit = @import("utilit.zig");
const mem = std.mem;
const fs = std.fs;
const Child = std.process.Child;
const ScriptExecutor = struct {
    name: []const u8,
    execute: *const fn (allocator: mem.Allocator, full_path: []const u8, args: []const []const u8) anyerror!void,
};
const ScriptTypeMap = std.StringHashMap(*const ScriptExecutor);
pub var scriptTypes: ?ScriptTypeMap = null;

pub fn init(allocator: mem.Allocator) !void {
    scriptTypes = ScriptTypeMap.init(allocator);
    const python = ScriptExecutor{ .name = "python", .execute = pythonScriptExecuter };
    const bash = ScriptExecutor{ .name = "bash", .execute = shellScriptExecuter };
    try scriptTypes.?.put(".py", &python);
    try scriptTypes.?.put(".sh", &bash);
}

pub fn run(allocator: mem.Allocator, full_path: []const u8, args: []const []const u8) !void {
    const ext = std.fs.path.extension(full_path);
    const executor = scriptTypes.?.get(ext);
    try executor.?.execute(allocator, full_path, args);
}
fn pythonScriptExecuter(allocator: mem.Allocator, full_path: []const u8, args: []const []const u8) !void {
    // Build args list
    var full_args = std.ArrayList([]const u8).init(allocator);
    defer full_args.deinit();

    try full_args.append("python");
    try full_args.append(full_path);
    for (args) |arg| {
        try full_args.append(arg);
    }

    // Execute script
    var child = Child.init(full_args.items, allocator);
    child.stderr_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    _ = try child.spawnAndWait();
}
fn shellScriptExecuter(allocator: mem.Allocator, full_path: []const u8, args: []const []const u8) !void {
    // Build args list
    var full_args = std.ArrayList([]const u8).init(allocator);
    defer full_args.deinit();

    try full_args.append("bash");
    try full_args.append("-c");
    try full_args.append(full_path);
    for (args) |arg| {
        try full_args.append(arg);
    }

    // Execute script
    var child = Child.init(full_args.items, allocator);
    child.stderr_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    _ = try child.spawnAndWait();
}
