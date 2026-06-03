using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/admin/users")]
    [ApiController]
    [Authorize(Roles="Admin")]
    public class AdminUsersController : ControllerBase
    {
        private readonly IAdminUsersService _adminUsersService;

        public AdminUsersController(IAdminUsersService adminUsersService)
        {
            _adminUsersService = adminUsersService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllUsers()
        {
            var result = await _adminUsersService.GetAllUsersAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById([FromRoute] long id)
        {
            if (id <= 0) return BadRequest(new { message = "Incorrect user id" });

            var result = await _adminUsersService.GetUserByIdAsync(id);

            if (!result.Success)
            {
                return NotFound(new { message = result.Message }); 
            }

            return Ok(result.Data);
        }


        [HttpPatch("{id}/ban")]
        public async Task<IActionResult> BanUser([FromRoute] long id)
        {
            if (id <= 0) return BadRequest(new { message = "Incorrect user id" });

            var result = await _adminUsersService.BanUserAsync(id);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }

            return NoContent();
        }
    }
}
