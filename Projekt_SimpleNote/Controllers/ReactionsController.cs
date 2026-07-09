using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Services.Interfaces;
using System.Security.Claims;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/")]
    [ApiController]
    [Authorize]
    public class ReactionsController : ControllerBase
    {
        private readonly IReactionsService _reactionsService;

        public ReactionsController(IReactionsService reactionsService)
        {
            _reactionsService = reactionsService;
        }


        //Get avaliable reactions

        [HttpGet("reaction-types")]
        public async Task<IActionResult> GetReactions()
        {
            var result = await _reactionsService.GetAvailableReactionsAsync();
            return Ok(result);
        }


        //Get notes reactions

        [HttpGet("notes/{noteId}/reactions")]
        public async Task<IActionResult> GetNoteReactionsSummary([FromRoute] long noteId)
        {
            var currentUserId = HttpContext.GetCurrentUserId();

            if (noteId <= 0)
            {
                return BadRequest(new { message = "Incorrect note" });
            }

            var result = await _reactionsService.GetNoteReactionsSummaryAsync(noteId, currentUserId);

            return Ok(result);

        }



        //Add reaction to note

        [HttpPost("notes/{noteId}/reactions/{reactionId}")]

        public async Task<IActionResult> AddNoteReaction([FromRoute] long noteId, [FromRoute] long reactionId)
        {
            var currentUserId = HttpContext.GetCurrentUserId();

            if (noteId <= 0)
            {
                return BadRequest(new { message = "Incorrect note"});
            }

            if (reactionId <= 0)
            {
                return BadRequest(new { message = "Incorrect reaction" });
            }

            var result = await _reactionsService.AddReactionAsync(noteId, reactionId, currentUserId);

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



        //Delete reaction from note

        [HttpDelete("notes/{noteId}/reactions/{reactionId}")]

        public async Task<IActionResult> RemoveNoteReaction([FromRoute] long noteId, [FromRoute] long reactionId)
        {
            var currentUserId = HttpContext.GetCurrentUserId();
            

            if (noteId <= 0)
            {
                return BadRequest(new { message = "Incorrect note" });
            }

            if (reactionId <= 0)
            {
                return BadRequest(new { message = "Incorrect reaction" });
            }



            var result = await _reactionsService.RemoveReactionAsync(noteId, reactionId, currentUserId);

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
