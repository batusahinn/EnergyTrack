using EnergyTrack.API.Data;
using EnergyTrack.API.Models;
using Microsoft.EntityFrameworkCore;

namespace EnergyTrack.API.Services;

public class AnomalyService
{
    private readonly AppDbContext _context;

    public AnomalyService(AppDbContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Checks whether the reading is anomalous relative to the device's recent history.
    /// If the value exceeds 2× the average of the last 10 prior readings, an Alert is created.
    /// Requires at least 3 prior readings to establish a baseline; silently skips otherwise.
    /// </summary>
    public async Task CheckAndAlertAsync(Reading reading)
    {
        var baseline = await _context.Readings
            .Where(r => r.DeviceId == reading.DeviceId && r.Id != reading.Id)
            .OrderByDescending(r => r.Timestamp)
            .Take(10)
            .ToListAsync();

        if (baseline.Count < 3)
            return;

        var average = baseline.Average(r => r.Value);

        if (average <= 0 || reading.Value <= 2 * average)
            return;

        var alert = new Alert
        {
            DeviceId  = reading.DeviceId,
            Message   = $"Anomaly detected: {reading.Value:F2} {reading.Unit} is " +
                        $"{reading.Value / average:F1}x the {baseline.Count}-reading average " +
                        $"of {average:F2} {reading.Unit}.",
            Timestamp = DateTime.UtcNow
        };

        _context.Alerts.Add(alert);
        await _context.SaveChangesAsync();
    }
}
