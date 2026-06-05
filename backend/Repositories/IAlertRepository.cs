using EnergyTrack.API.Models;

namespace EnergyTrack.API.Repositories;

public interface IAlertRepository
{
    /// <summary>Returns all alerts ordered by most recent first.</summary>
    Task<IEnumerable<Alert>> GetAllAsync();

    /// <summary>Returns all alerts for a specific device.</summary>
    Task<IEnumerable<Alert>> GetByDeviceIdAsync(int deviceId);

    /// <summary>Returns an alert by ID, or null if not found.</summary>
    Task<Alert?> GetByIdAsync(int id);

    /// <summary>Persists a new alert and returns it with the generated ID.</summary>
    Task<Alert> CreateAsync(Alert alert);

    /// <summary>Deletes an alert by ID. Returns false if the alert does not exist.</summary>
    Task<bool> DeleteAsync(int id);
}
