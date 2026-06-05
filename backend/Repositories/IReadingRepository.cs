using EnergyTrack.API.Models;

namespace EnergyTrack.API.Repositories;

public interface IReadingRepository
{
    /// <summary>Returns all readings.</summary>
    Task<IEnumerable<Reading>> GetAllAsync();

    /// <summary>Returns all readings for a specific device.</summary>
    Task<IEnumerable<Reading>> GetByDeviceIdAsync(int deviceId);

    /// <summary>Returns a reading by ID, or null if not found.</summary>
    Task<Reading?> GetByIdAsync(int id);

    /// <summary>Persists a new reading and returns it with the generated ID.</summary>
    Task<Reading> CreateAsync(Reading reading);

    /// <summary>Deletes a reading by ID. Returns false if the reading does not exist.</summary>
    Task<bool> DeleteAsync(int id);
}
