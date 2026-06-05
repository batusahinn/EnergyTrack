using EnergyTrack.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace EnergyTrack.API.Controllers;

[ApiController]
[Route("api/v1/auth")]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    /// <summary>Registers a new user account.</summary>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] AuthRequest request)
    {
        var user = await _authService.RegisterAsync(request.Username, request.Password);
        if (user is null)
            return Conflict(new { message = "Username already exists." });

        return Ok(new { user.Id, user.Username });
    }

    /// <summary>Authenticates a user and returns a signed JWT.</summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] AuthRequest request)
    {
        var token = await _authService.LoginAsync(request.Username, request.Password);
        if (token is null)
            return Unauthorized(new { message = "Invalid username or password." });

        return Ok(new { token });
    }
}

public record AuthRequest(string Username, string Password);
