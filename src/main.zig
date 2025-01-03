const std = @import("std");
const utilits = @import("utilit.zig");
const exectuor = @import("executor.zig");
const mem = std.mem;
pub fn main() !void {
    // const allocator = std.heap.c_allocator;

    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    const repositories = env.get("US_REPOSITORIES") orelse {
        std.debug.print("Error:Enverment US_REPOSITORIES not found\n", .{});
        return error.RepositoriesNotSet;
    };
    const editor = env.get("EDITOR") orelse "nano";
    if (args.len < 2) {
        try printUsage();
        return;
    }
    const command = args[1];
    try exectuor.initExecutors(allocator);
    defer allocator.free(exectuor.executors);
    if (mem.eql(u8, command, "list")) {
        try listScripts(repositories);
    } else if (mem.eql(u8, command, "ls-exe")) {
        try listExecutor();
    } else if (mem.eql(u8, command, "edit")) {
        if (args.len < 3) {
            std.debug.print("Error:Script name not found\n", .{});
            try printUsage();
            return;
        }
        const script_found = try getScript(allocator, repositories, args[2]);
        try editScript(allocator, script_found, editor);
        allocator.free(script_found);
    } else if (mem.eql(u8, command, "run")) {
        if (args.len < 3) {
            std.debug.print("Error:Script name not found\n", .{});
            try printUsage();
            return;
        }
        const script_found = try getScript(allocator, repositories, args[2]);
        try exectuor.run(allocator, script_found, args[3..]);
        allocator.free(script_found);
    }
}
fn editScript(allocator: mem.Allocator, full_path: []const u8, editor: []const u8) !void {
    var full_args = std.ArrayList([]const u8).init(allocator);
    defer full_args.deinit();

    try full_args.append(editor);
    try full_args.append(full_path);
    var child = std.process.Child.init(full_args.items, allocator);
    child.stderr_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    _ = try child.spawnAndWait();
}
fn listScripts(repo: []const u8) !void {
    var dir = try std.fs.openDirAbsolute(repo, .{ .iterate = true });
    defer dir.close();
    var iterate = dir.iterate();
    while (try iterate.next()) |entry| {
        if (entry.kind == .file) {
            const ext = std.fs.path.extension(entry.name);
            if (exectuor.getScriptType(ext) != exectuor.ScriptType.Unknown) {
                const script_name = entry.name[0 .. entry.name.len - ext.len];
                try utilits.println("{s}", .{script_name});
            }
        }
    }
}
fn listExecutor() !void {
    const exectuors = exectuor.executors;
    try utilits.println("NAME\tEXTENSION", .{});
    for (exectuors) |entry| {
        try utilits.println("{s}\t{s}", .{ entry.name, entry.extension });
    }
}
fn printUsage() !void {
    try utilits.print(
        \\Union-Script
        \\
        \\Usage：
        \\  us list           - list all script
        \\  us ls-exe         - list all executor
        \\  us edit <script>  - edit script
        \\  us run <script>   - run script
        \\
        \\env：
        \\  US_REPOSITORIES - script repositories
    , .{});
}
fn getScript(allocator: mem.Allocator, repositories: []const u8, script_name: []const u8) ![]const u8 {
    const executors = exectuor.executors;
    for (executors) |entry| {
        const ext = entry.extension;
        const full_path = try std.fmt.allocPrint(allocator, "{s}/{s}{s}", .{ repositories, script_name, ext });
        if (std.fs.accessAbsolute(full_path, .{ .mode = .read_only })) |_| {
            return full_path;
        } else |_| {
            continue;
        }
    }
    return error.ScriptNotFound;
}
