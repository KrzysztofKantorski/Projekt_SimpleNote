using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{

    [ApiController]
    [Route("api/admin/subjects")]
    [Authorize(Roles = "Admin")]
    public class AdminSubjectsController : ControllerBase
    {
        private readonly IAdminSubjectsService _adminSubjectsService;
        private readonly IValidator<SubjectRequestDto> _validator;
        private readonly IValidator<PaginationParamsDto> _paginationValidator;
        public AdminSubjectsController(IAdminSubjectsService adminSubjectsService, IValidator<SubjectRequestDto> validator, IValidator<PaginationParamsDto> paginationValidator)
        {
            _adminSubjectsService = adminSubjectsService;
            _validator = validator;
            _paginationValidator = paginationValidator;
        }
        [HttpGet]
        public async Task<IActionResult> GetAllSubjects(
            [FromQuery] PaginationParamsDto paginationParams
            )
        {
            var validationResult = await _paginationValidator.ValidateAsync(paginationParams);
            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }

            var result = await _adminSubjectsService.GetAllSubjectsAsync(paginationParams);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> AddSubject([FromBody] SubjectRequestDto dto)
        {
            var validationResult = await _validator.ValidateAsync(dto);
            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }

            var result = await _adminSubjectsService.AddSubjectAsync(dto);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }

            return Created(string.Empty, result.Data);
        }


        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSubject([FromRoute] long id, [FromBody] SubjectRequestDto dto)
        {
            if (id <= 0) return BadRequest(new { message = "Incorrect subject id" });

            var validationResult = await _validator.ValidateAsync(dto);
            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }

            var result = await _adminSubjectsService.UpdateSubjectAsync(id, dto);

            if (!result.Success)
            {
                if (result.Message.Contains("Not found"))
                { 
                    return NotFound(new { message = result.Message });
                } 

                return BadRequest(new { message = result.Message });
            }

            return Ok(result.Data);

        }


        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSubject([FromRoute] long id)
        {
            if (id <= 0) return BadRequest(new { message = "Incorrect subject id" });

            var result = await _adminSubjectsService.DeleteSubjectAsync(id);

            if (!result.Success)
            {
                if (result.Message.Contains("Not found"))
                {
                    return NotFound(new { message = result.Message });
                }

                return BadRequest(new { message = result.Message });
            }

            return NoContent(); 
        }
    }
}
