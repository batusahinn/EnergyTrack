using EnergyTrack.API.Data;
using EnergyTrack.API.Models;
using Microsoft.EntityFrameworkCore;

namespace EnergyTrack.API.Repositories;

public class AlertRepository : IAlertRepository
{
    private readonly AppDbContext _context;

    public AlertRepository(AppDbContext context)
    {
        _context = context;
    }

    /// <inheritdoc/>
    public async Task<IEnumerable<Alert>> GetAllAsync()
        => await _context.Alerts.OrderByDescending(a => a.Timestamp).ToListAsync();

    /// <inheritdoc/>
    public async Task<IEnumerable<Alert>> GetByDeviceIdAsync(int deviceId)
        => await _context.Alerts
            .Where(a => a.DeviceId == deviceId)
            .OrderByDescending(a => a.Timestamp)
            .ToListAsync();

    /// <inheritdoc/>
    public async Task<Alert?> GetByIdAsync(int id)
        => await _context.Alerts.FindAsync(id);

    /// <inheritdoc/>
    public async Task<Alert> CreateAsync(Alert alert)
    {
        _context.Alerts.Add(alert);
        await _context.SaveChangesAsync();
        return alert;
    }

    /// <inheritdoc/>
    public async Task<bool> DeleteAsync(int id)
    {
        var alert = await _context.Alerts.FindAsync(id);
        if (alert is null) return false;

        _context.Alerts.Remove(alert);
        await _context.SaveChangesAsync();
        return true;
    }
}
