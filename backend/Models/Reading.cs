namespace EnergyTrack.API.Models;

public class Reading
{
    public int Id { get; set; }
    public int DeviceId { get; set; }
    public double Value { get; set; }
    public string Unit { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }

    public Device Device { get; set; } = null!;
}
