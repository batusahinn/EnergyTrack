using EnergyTrack.API.Models;
using EnergyTrack.API.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EnergyTrack.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class DevicesController : ControllerBase
{
    private readonly IDeviceRepository _repository;

    public DevicesController(IDeviceRepository repository)
    {
        _repository = repository;
    }

    /// <summary>Returns all registered devices.</summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
        => Ok(await _repository.GetAllAsync());

    /// <summary>Returns a device by ID.</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var device = await _repository.GetByIdAsync(id);
        return device is null ? NotFound() : Ok(device);
    }

    /// <summary>Creates a new device.</summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DeviceRequest request)
    {
        var device = new Device
        {
            Name     = request.Name,
            Location = request.Location,
            Type     = request.Type
        };
        var created = await _repository.CreateAsync(device);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    /// <summary>Updates an existing device.</summary>
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DeviceRequest request)
    {
        var device = new Device
        {
            Id       = id,
            Name     = request.Name,
            Location = request.Location,
            Type     = request.Type
        };
        var updated = await _repository.UpdateAsync(device);
        return updated is null ? NotFound() : Ok(updated);
    }

    /// <summary>Deletes a device and all its associated readings and alerts.</summary>
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
        => await _repository.DeleteAsync(id) ? NoContent() : NotFound();
}

public record DeviceRequest(string Name, string Location, string Type);
