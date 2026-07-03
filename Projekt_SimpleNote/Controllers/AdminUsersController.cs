using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/admin/users")]
    [ApiController]
    [Authorize(Roles="Admin")]
    public class AdminUsersController : ControllerBase
    {
        private readonly IAdminUsersService _adminUsersService;
        private readonly IValidator<PaginationParamsDto> _paginationValidator;

        public AdminUsersController(IAdminUsersService adminUsersService, IValidator<PaginationParamsDto> paginationValidator)
        {
            _adminUsersService = adminUsersService;
            _paginationValidator = paginationValidator;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllUsers(
            [FromQuery] PaginationParamsDto paginationParams
            )
        {
            var validationResult = await _paginationValidator.ValidateAsync(paginationParams);
            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }
            var result = await _adminUsersService.GetAllUsersAsync(paginationParams);
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
