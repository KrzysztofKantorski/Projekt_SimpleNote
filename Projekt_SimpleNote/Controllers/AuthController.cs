using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Dto.Auth;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        //Validators
        private readonly IValidator<RegisterDto> _registerValidator;
        private readonly IValidator<LoginDto> _loginValidator;

        public AuthController(IAuthService authService, IValidator<RegisterDto> registerValidator, IValidator<LoginDto> loginValidator)
        {
            _authService = authService;
            _registerValidator = registerValidator;
            _loginValidator = loginValidator;
        }


        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto) {

            var validationResult = await _registerValidator.ValidateAsync(dto);

            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }


            var result = await _authService.RegisterAsync(dto);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }
            return Created("", new { message = result.Message });
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {


            var validationResult = await _loginValidator.ValidateAsync(dto);

            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }

            var result = await _authService.LoginAsync(dto);

            if (!result.Success)
            {
                return Unauthorized(new { message = result.Message });
            }

            //For admin panel
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true, 
                Expires = DateTime.UtcNow.AddDays(7), 
                SameSite = SameSiteMode.Lax,
            };

            Response.Cookies.Append("refreshToken", result.Tokens!.RefreshToken, cookieOptions);

            return Ok(new
            {
                message = result.Message,
                tokens = result.Tokens
            });

        }

        [Authorize]
        [HttpPost("logout")]
        public async Task <IActionResult> Logout([FromBody] RefreshTokenRequestDto? dto)
        {
            string? refreshToken = Request.Cookies["refreshToken"] ?? dto?.RefreshToken;

            if (!string.IsNullOrWhiteSpace(refreshToken))
            {
                var result = await _authService.LogoutAsync(refreshToken);

                if (!result.Success) 
                { 
                    return Unauthorized(result.Message);
                }


                Response.Cookies.Delete("refreshToken", new CookieOptions
                {
                    HttpOnly = true,
                    SameSite = SameSiteMode.Lax,
                });

                return Ok(new { message = "Logout successfull" });
            }

            return BadRequest("Incorrect token");
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequestDto? dto) {

            //Check admin panel scenario
            string? refreshToken = Request.Cookies["refreshToken"];

            //Check app scenario
            if (string.IsNullOrEmpty(refreshToken))
            {
                refreshToken = dto?.RefreshToken;
            }

            
            if (string.IsNullOrEmpty(refreshToken))
            {
                return BadRequest(new { message = "Your token expired." });
            }


            var result = await _authService.RefreshTokenAsync(refreshToken);

            if (!result.Success)
            {
                return Unauthorized(new { message = result.Message });
            }

            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Expires = DateTime.UtcNow.AddDays(7),
                SameSite = SameSiteMode.Lax,
            };


            Response.Cookies.Append("refreshToken", result.Tokens!.RefreshToken, cookieOptions);

            return Ok(new
            {
                message = result.Message,
                tokens = result.Tokens
            });
        }

    }
}
