using EnergyTrack.API.Models;
using EnergyTrack.API.Repositories;
using EnergyTrack.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EnergyTrack.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class ReadingsController : ControllerBase
{
    private readonly IReadingRepository _repository;
    private readonly AnomalyService _anomalyService;

    public ReadingsController(IReadingRepository repository, AnomalyService anomalyService)
    {
        _repository     = repository;
        _anomalyService = anomalyService;
    }

    /// <summary>Returns all readings ordered by most recent first.</summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
        => Ok(await _repository.GetAllAsync());

    /// <summary>Returns a reading by ID.</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var reading = await _repository.GetByIdAsync(id);
        return reading is null ? NotFound() : Ok(reading);
    }

    /// <summary>Returns all readings for a specific device, ordered by most recent first.</summary>
    [HttpGet("device/{deviceId:int}")]
    public async Task<IActionResult> GetByDeviceId(int deviceId)
        => Ok(await _repository.GetByDeviceIdAsync(deviceId));

    /// <summary>Records a new energy reading. Timestamp defaults to UTC now if omitted.</summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ReadingRequest request)
    {
        var reading = new Reading
        {
            DeviceId  = request.DeviceId,
            Value     = request.Value,
            Unit      = request.Unit,
            Timestamp = request.Timestamp ?? DateTime.UtcNow
        };
        var created = await _repository.CreateAsync(reading);
        await _anomalyService.CheckAndAlertAsync(created);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    /// <summary>Deletes a reading by ID.</summary>
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
        => await _repository.DeleteAsync(id) ? NoContent() : NotFound();
}

public record ReadingRequest(int DeviceId, double Value, string Unit, DateTime? Timestamp);
