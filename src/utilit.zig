const std = @import("std");
const exectuor = @import("executor.zig");
pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);

    try bw.flush();
}
pub fn println(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);
    try stdout.print("\n", .{});

    try bw.flush();
}
pub fn getScriptList(repo: []const u8) !std.ArrayList([]const u8) {
    var list = std.ArrayList([]const u8).init(std.heap.page_allocator);
    errdefer list.deinit(); // 确保在发生错误时释放列表内存

    try getScriptListRecursive(repo, &list);

    return list;
}

fn getScriptListRecursive(repo: []const u8, list: *std.ArrayList([]const u8)) !void {
    var dir = try std.fs.openDirAbsolute(repo, .{ .iterate = true });
    defer dir.close();
    var iterate = dir.iterate();

    while (try iterate.next()) |entry| {
        if (entry.kind == .file) {
            const ext = std.fs.path.extension(entry.name);
            if (exectuor.getScriptType(ext) != exectuor.ScriptType.Unknown) {
                const abs_path = try std.fs.path.join(
                    std.heap.page_allocator,
                    &.{ repo, entry.name },
                );
                try list.append(abs_path);
            }
        } else if (entry.kind == .directory) {
            const sub_dir_path = try std.fs.path.join(
                std.heap.page_allocator,
                &.{ repo, entry.name },
            );
            defer std.heap.page_allocator.free(sub_dir_path);
            try getScriptListRecursive(sub_dir_path, list);
        }
    }
}
