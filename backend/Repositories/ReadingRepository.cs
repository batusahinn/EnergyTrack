using EnergyTrack.API.Data;
using EnergyTrack.API.Models;
using Microsoft.EntityFrameworkCore;

namespace EnergyTrack.API.Repositories;

public class ReadingRepository : IReadingRepository
{
    private readonly AppDbContext _context;

    public ReadingRepository(AppDbContext context)
    {
        _context = context;
    }

    /// <inheritdoc/>
    public async Task<IEnumerable<Reading>> GetAllAsync()
        => await _context.Readings.OrderByDescending(r => r.Timestamp).ToListAsync();

    /// <inheritdoc/>
    public async Task<IEnumerable<Reading>> GetByDeviceIdAsync(int deviceId)
        => await _context.Readings
            .Where(r => r.DeviceId == deviceId)
            .OrderByDescending(r => r.Timestamp)
            .ToListAsync();

    /// <inheritdoc/>
    public async Task<Reading?> GetByIdAsync(int id)
        => await _context.Readings.FindAsync(id);

    /// <inheritdoc/>
    public async Task<Reading> CreateAsync(Reading reading)
    {
        _context.Readings.Add(reading);
        await _context.SaveChangesAsync();
        return reading;
    }

    /// <inheritdoc/>
    public async Task<bool> DeleteAsync(int id)
    {
        var reading = await _context.Readings.FindAsync(id);
        if (reading is null) return false;

        _context.Readings.Remove(reading);
        await _context.SaveChangesAsync();
        return true;
    }
}
