const std = @import("std");
const utilits = @import("utilit.zig");
const exectuor = @import("executor.zig");
const mem = std.mem;
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();
    const repositories = env.get("US_REPOSITORIES") orelse {
        std.debug.print("错误：未设置 US_REPOSITORIES 环境变量\n", .{});
        return error.RepositoriesNotSet;
    };
    if (args.len < 2) {
        try printUsage();
        return;
    }
    try exectuor.init(allocator);
    const command = args[1];
    if (mem.eql(u8, command, "list")) {
        try listScripts(repositories);
    } else if (mem.eql(u8, command, "run")) {
        if (args.len < 3) {
            std.debug.print("错误：缺少脚本名称\n", .{});
            try printUsage();
            return;
        }
        const script_found = try getScript(allocator, repositories, args[2]);
        try exectuor.run(allocator, script_found, args[3..]);
    }
}
fn listScripts(repo: []const u8) !void {
    var dir = try std.fs.openDirAbsolute(repo, .{ .iterate = true });
    defer dir.close();
    var iterate = dir.iterate();
    while (try iterate.next()) |entry| {
        if (entry.kind == .file) {
            const ext = std.fs.path.extension(entry.name);
            if (exectuor.scriptTypes.?.get(ext) != null) {
                const script_name = entry.name[0 .. entry.name.len - ext.len];
                try utilits.println("- {s}", .{script_name});
            }
        }
    }
}
fn printUsage() !void {
    try utilits.print(
        \\Union-Script 管理器
        \\
        \\用法：
        \\  us list         - 列出所有可用脚本
        \\  us run <script> - 运行指定脚本
        \\
        \\环境变量：
        \\  US_REPOSITORIES - 指定脚本仓库路径
    , .{});
}
fn getScript(allocator: mem.Allocator, repositories: []const u8, script_name: []const u8) ![]const u8 {
    var type_iterator = exectuor.scriptTypes.?.iterator();
    while (type_iterator.next()) |entry| {
        const ext = entry.key_ptr.*;
        const full_path = try std.fmt.allocPrint(allocator, "{s}/{s}{s}", .{ repositories, script_name, ext });
        if (std.fs.accessAbsolute(full_path, .{ .mode = .read_only })) |_| {
            return full_path;
        } else |err| {
            return err;
        }
    }
    return error.ScriptNotFound;
}
