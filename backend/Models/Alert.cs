namespace EnergyTrack.API.Models;

public class Alert
{
    public int Id { get; set; }
    public int DeviceId { get; set; }
    public string Message { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }

    public Device Device { get; set; } = null!;
}
