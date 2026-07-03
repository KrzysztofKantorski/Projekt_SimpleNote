using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Services.Interfaces;
using Projekt_SimpleNote.Validators;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/admin/comments")]
    [Authorize(Roles = "Admin")]
    [ApiController]
    public class AdminCommentsController : ControllerBase
    {
        private readonly IAdminCommentsService _adminCommentsService;
        private readonly IValidator<PaginationParamsDto> _paginationValidator;
        public AdminCommentsController(IAdminCommentsService adminCommentsService, IValidator<PaginationParamsDto> paginationValidator)
        {
            _adminCommentsService = adminCommentsService;
            _paginationValidator = paginationValidator;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllComments(
                [FromQuery] PaginationParamsDto paginationParams
            )
        {
            var validationResult = await _paginationValidator.ValidateAsync(paginationParams);

            if (!validationResult.IsValid)
            {
                //Client sent incorrect parameters
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }
            var result = await _adminCommentsService.GetAllCommentsAsync(paginationParams);
            return Ok(result);
        }

        [HttpDelete("{commentId}")]
        public async Task<IActionResult> DeleteComment([FromRoute] long commentId)
        {
            if (commentId <= 0) return BadRequest(new { message = "Incorrect comment id" });
            var result = await _adminCommentsService.DeleteCommentAsync(commentId);
            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }
            return NoContent();
        }
    }
}
