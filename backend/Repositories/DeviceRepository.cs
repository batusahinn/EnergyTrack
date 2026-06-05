using EnergyTrack.API.Data;
using EnergyTrack.API.Models;
using Microsoft.EntityFrameworkCore;

namespace EnergyTrack.API.Repositories;

public class DeviceRepository : IDeviceRepository
{
    private readonly AppDbContext _context;

    public DeviceRepository(AppDbContext context)
    {
        _context = context;
    }

    /// <inheritdoc/>
    public async Task<IEnumerable<Device>> GetAllAsync()
        => await _context.Devices.ToListAsync();

    /// <inheritdoc/>
    public async Task<Device?> GetByIdAsync(int id)
        => await _context.Devices.FindAsync(id);

    /// <inheritdoc/>
    public async Task<Device> CreateAsync(Device device)
    {
        _context.Devices.Add(device);
        await _context.SaveChangesAsync();
        return device;
    }

    /// <inheritdoc/>
    public async Task<Device?> UpdateAsync(Device device)
    {
        var existing = await _context.Devices.FindAsync(device.Id);
        if (existing is null) return null;

        existing.Name = device.Name;
        existing.Location = device.Location;
        existing.Type = device.Type;
        await _context.SaveChangesAsync();
        return existing;
    }

    /// <inheritdoc/>
    public async Task<bool> DeleteAsync(int id)
    {
        var device = await _context.Devices.FindAsync(id);
        if (device is null) return false;

        _context.Devices.Remove(device);
        await _context.SaveChangesAsync();
        return true;
    }
}
