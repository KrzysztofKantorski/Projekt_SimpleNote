using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Services.Interfaces;
using System.Security.Claims;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/notes/")]
    [ApiController]
    [Authorize]
    public class CommentsController : ControllerBase
    {

        private readonly ICommentsService _commentsService;
        private readonly IValidator<CreateCommentDto> _validator;

        public CommentsController(ICommentsService noteInteractionsService, IValidator<CreateCommentDto> validator)
        {
            _commentsService = noteInteractionsService;
            _validator = validator;
        }


        //Get note comments

        [HttpGet("{noteId}/comments")]
        public async Task<IActionResult> GetComments([FromRoute] long noteId)
        {
            var currentUserId = HttpContext.GetCurrentUserId();
            var result = await _commentsService.GetCommentsAsync(noteId, currentUserId);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }

            return Ok(result.Comments);
        }



        //Create comment or reply


        [HttpPost("{noteId}/comments")]
        public async Task<IActionResult> CreateComment([FromRoute] long noteId, [FromBody] CreateCommentDto dto)
        {
            var validationResult = await _validator.ValidateAsync(dto);

            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }

            var currentUserId = HttpContext.GetCurrentUserId();
            var result = await _commentsService.CreateCommentAsync(noteId, currentUserId, dto);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }

            return NoContent();
        }


        //Delete comment (with replies)

        [HttpDelete("{noteId}/comments/{commentId}")]
        public async Task<IActionResult> DeleteComment([FromRoute] long noteId, [FromRoute] long commentId)
        {
            var currentUserId = HttpContext.GetCurrentUserId();
            var result = await _commentsService.DeleteCommentAsync(noteId, commentId, currentUserId);

            if (!result.Success)
            {
                if (result.Message.Contains("Access denied"))
                {
                    return Forbid(); 
                }
                return BadRequest(new { message = result.Message });
            }

            return NoContent();
        }

    }
}
