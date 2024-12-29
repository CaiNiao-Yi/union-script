const std = @import("std");
const utilit = @import("utilit.zig");
const mem = std.mem;
const fs = std.fs;
const Child = std.process.Child;
const ScriptExecutor = struct {
    name: []const u8,
    extension: []const u8,
    executable: []const u8,
    execute: *const fn (allocator: mem.Allocator, full_path: []const u8, args: []const []const u8) anyerror!void,
};
pub const ScriptType = enum {
    Python,
    Bash,
    Fish,
    Unknown,
};
pub const executorsDefinitions = [_]ScriptExecutor{
    .{ .name = "Python", .extension = ".py", .executable = "python", .execute = pythonScriptExecuter },
    .{ .name = "Bash", .extension = ".sh", .executable = "bash", .execute = shellScriptExecuter },
    .{ .name = "Fish", .extension = ".fish", .executable = "fish", .execute = fishShellScriptExectuer },
};
pub var executors: []ScriptExecutor = undefined;
pub fn initExecutors(alloc: mem.Allocator) !void {
    var executlorsList = std.ArrayList(ScriptExecutor).init(alloc);
    defer {
        if (executlorsList.capacity != 0) {
            executlorsList.deinit();
        }
    }
    for (executorsDefinitions) |exec| {
        if (try isExecutableAvailable(exec.executable, alloc)) {
            try executlorsList.append(exec);
        }
    }
    if (executlorsList.items.len > 0) {
        executors = try alloc.alloc(ScriptExecutor, executlorsList.items.len);
        std.mem.copyBackwards(ScriptExecutor, executors, executlorsList.items);
        executlorsList.capacity = 0;
    } else {
        executors = &[_]ScriptExecutor{};
    }
}
fn isExecutableAvailable(executable: []const u8, alloc: mem.Allocator) !bool {
    var child = Child.init(&[_][]const u8{ executable, "--version" }, alloc);
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    _ = child.spawnAndWait() catch |err| {
        switch (err) {
            error.InvalidExe => return false,
            else => return true,
        }
    };
    return true;
}
const ExtensionMapping = struct {
    extension: []const u8,
    scriptType: ScriptType,
};
const extensionMap = [_]ExtensionMapping{ .{ .extension = ".py", .scriptType = ScriptType.Python }, .{ .extension = ".sh", .scriptType = ScriptType.Bash }, .{ .extension = ".fish", .scriptType = ScriptType.Fish } };
pub fn getScriptType(extension: []const u8) ScriptType {
    for (extensionMap) |e| {
        if (std.mem.eql(u8, e.extension, extension)) {
            return e.scriptType;
        }
    }
    return ScriptType.Unknown;
}
pub fn run(allocator: mem.Allocator, full_path: []const u8, args: []const []const u8) !void {
    const ext = std.fs.path.extension(full_path);
    const scriptType = getScriptType(ext);
    switch (scriptType) {
        .Python => try executors[@intFromEnum(ScriptType.Python)].execute(allocator, full_path, args),
        .Bash => try executors[@intFromEnum(ScriptType.Bash)].execute(allocator, full_path, args),
        .Fish => try executors[@intFromEnum(ScriptType.Fish)].execute(allocator, full_path, args),
        .Unknown => std.debug.print("Unsupported script type: {s}\n", .{ext}),
    }
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
fn fishShellScriptExectuer(allocator: mem.Allocator, full_path: []const u8, args: []const []const u8) !void {
    var full_args = std.ArrayList([]const u8).init(allocator);
    defer full_args.deinit();

    try full_args.append("fish");
    try full_args.append(full_path);
    for (args) |arg| {
        try full_args.append(arg);
    }
    var child = Child.init(full_args.items, allocator);
    child.stderr_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    _ = try child.spawnAndWait();
}
