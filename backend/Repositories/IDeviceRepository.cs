using EnergyTrack.API.Models;

namespace EnergyTrack.API.Repositories;

public interface IDeviceRepository
{
    /// <summary>Returns all devices.</summary>
    Task<IEnumerable<Device>> GetAllAsync();

    /// <summary>Returns a device by ID, or null if not found.</summary>
    Task<Device?> GetByIdAsync(int id);

    /// <summary>Persists a new device and returns it with the generated ID.</summary>
    Task<Device> CreateAsync(Device device);

    /// <summary>Updates an existing device. Returns null if the device does not exist.</summary>
    Task<Device?> UpdateAsync(Device device);

    /// <summary>Deletes a device by ID. Returns false if the device does not exist.</summary>
    Task<bool> DeleteAsync(int id);
}
