namespace EnergyTrack.API.Models;

public class Device
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;

    public ICollection<Reading> Readings { get; set; } = new List<Reading>();
    public ICollection<Alert> Alerts { get; set; } = new List<Alert>();
}
