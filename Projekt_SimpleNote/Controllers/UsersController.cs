using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/users")]
    [ApiController]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }
        
        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            var currentUserId = HttpContext.GetCurrentUserId();
           

            var userProfile = await _userService.GetUserProfileAsync(currentUserId);

            if (userProfile == null)
            {
                return NotFound(new { message = "User not found" });
            }

            return Ok(userProfile);
        }
    }
}
