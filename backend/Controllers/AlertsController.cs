using EnergyTrack.API.Models;
using EnergyTrack.API.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EnergyTrack.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class AlertsController : ControllerBase
{
    private readonly IAlertRepository _repository;

    public AlertsController(IAlertRepository repository)
    {
        _repository = repository;
    }

    /// <summary>Returns all alerts ordered by most recent first.</summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
        => Ok(await _repository.GetAllAsync());

    /// <summary>Returns an alert by ID.</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var alert = await _repository.GetByIdAsync(id);
        return alert is null ? NotFound() : Ok(alert);
    }

    /// <summary>Returns all alerts for a specific device, ordered by most recent first.</summary>
    [HttpGet("device/{deviceId:int}")]
    public async Task<IActionResult> GetByDeviceId(int deviceId)
        => Ok(await _repository.GetByDeviceIdAsync(deviceId));

    /// <summary>Creates a new alert. Timestamp defaults to UTC now if omitted.</summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AlertRequest request)
    {
        var alert = new Alert
        {
            DeviceId  = request.DeviceId,
            Message   = request.Message,
            Timestamp = request.Timestamp ?? DateTime.UtcNow
        };
        var created = await _repository.CreateAsync(alert);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    /// <summary>Deletes an alert by ID.</summary>
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
        => await _repository.DeleteAsync(id) ? NoContent() : NotFound();
}

public record AlertRequest(int DeviceId, string Message, DateTime? Timestamp);
