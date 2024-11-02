const std = @import("std");
const FileOpenError = error{
    OutOfMemory,
};
fn readBatteryFile(path: []const u8) !u32 {
    const BUF_SIZE = 32;

    const file = std.fs.openFileAbsolute(path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("{s} not found!\n", .{path});
            return err;
        },
        else => {
            std.debug.print("{s} error openning file\n", .{path});
            return err;
        },
    };

    var buffer: [BUF_SIZE]u8 = undefined;
    const b_read = try file.readAll(&buffer);
    if (b_read > BUF_SIZE) {
        std.debug.print("File too large\n", .{});
        return FileOpenError.OutOfMemory;
    }
    return try std.fmt.parseInt(u32, buffer[0 .. b_read - 1], 10);
}

fn isCharging(path: []const u8) !bool {
    const BUF_SIZE = 32;

    const file = std.fs.openFileAbsolute(path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("{s} not found!\n", .{path});
            return err;
        },
        else => {
            std.debug.print("{s} error openning file\n", .{path});
            return err;
        },
    };
    var buffer: [BUF_SIZE]u8 = undefined;
    const b_read = try file.readAll(&buffer);
    if (b_read > BUF_SIZE) {
        std.debug.print("File too large\n", .{});
        return FileOpenError.OutOfMemory;
    }

    return std.mem.eql(u8, buffer[0 .. b_read - 1], "Charging");
}

fn checkPercentage() !void {
    //TODO: Add limit as argument, add BATT name as argument
    while (true) {
        const full = try readBatteryFile("/sys/class/power_supply/BATT/charge_full");
        const current = try readBatteryFile("/sys/class/power_supply/BATT/charge_now");
        const percentage: u32 = current * 100 / full;
        var output_buf: [8]u8 = undefined;
        if (!try isCharging("/sys/class/power_supply/BATT/status")) {
            if (percentage < 12) {
                const output = try std.fmt.bufPrint(&output_buf, "{d:2}%", .{percentage});
                var cmd = std.process.Child.init(&[_][]const u8{ "notify-send", "Low Battery", output, "-t", "55000", "-u", "critical" }, std.heap.page_allocator);
                try cmd.spawn();
                _ = try cmd.wait();
            }
        }
        std.time.sleep(60 * 1e9);
    }
}

pub fn main() !void {
    const thread = try std.Thread.spawn(.{}, checkPercentage, .{});
    std.Thread.join(thread);
}
