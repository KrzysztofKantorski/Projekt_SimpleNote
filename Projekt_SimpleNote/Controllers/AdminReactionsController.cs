using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [ApiController]
    [Route("api/admin/reactions")]
    [Authorize(Roles = "Admin")]
    public class AdminReactionsController : ControllerBase
    {
        private readonly IAdminReactionsService _adminReactionsService;
        private readonly IValidator<CreateReactionTypeDto> _validator;
        private readonly IValidator<PaginationParamsDto> _paginationValidator;

        public AdminReactionsController(IAdminReactionsService adminReactionsService, IValidator<CreateReactionTypeDto> validator, IValidator<PaginationParamsDto> paginationValidator)
        {
            _adminReactionsService = adminReactionsService;
            _validator = validator;
            _paginationValidator = paginationValidator;
        }
        [HttpGet]
        public async Task<IActionResult> GetAllReactionTypes(
            [FromQuery] PaginationParamsDto paginationParams
            )
        {
            var validationResult = await _paginationValidator.ValidateAsync(paginationParams);
            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }
            var result = await _adminReactionsService.GetAllReactionTypesAsync(paginationParams);
            return Ok(result);

        }

        [HttpPost]
        public async Task<IActionResult> AddReactionType([FromBody] CreateReactionTypeDto dto)
        {
            var validationResult = await _validator.ValidateAsync(dto);
            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }

            var result = await _adminReactionsService.AddReactionTypeAsync(dto);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }

            return Created(string.Empty, result.Data);
        }



        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateReactionType([FromRoute] long id, [FromBody] CreateReactionTypeDto dto)
        {
            if (id <= 0) return BadRequest(new { message = "Incorrect reaction id" });
            var validationResult = await _validator.ValidateAsync(dto);

            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }

            var result = await _adminReactionsService.UpdateSubjectAsync(id, dto);
            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }
            return Ok(result.Data);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReactionType([FromRoute] long id)
        {
            if (id <= 0) return BadRequest(new { message = "Incorrect reaction id" });

            var result = await _adminReactionsService.DeleteReactionTypeAsync(id);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }

            return NoContent();
        }
    }
}
