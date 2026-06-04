using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/community")]
    [ApiController]
    [Authorize]
    public class CommunityController : ControllerBase
    {
        private readonly ICommunityService _communityService;

        public CommunityController(ICommunityService communityService)
        {
            _communityService = communityService;
        }



        //Get community notes (for displaying to list) based on filters
        [AllowAnonymous]
        [HttpGet("notes")]
        public async Task<IActionResult> GetCommunityNotes(
            [FromQuery] string? phrase,
            [FromQuery] string? subject,
            [FromQuery] string? tag
        )
        {
            var currentUserId = HttpContext.GetOptionalCurrentUserId() ?? 0;
            var notes = await _communityService.GetPublicNotesAsync(phrase, subject, tag, currentUserId);

            return Ok(notes);
        }



        //Get community note details based on note id
        [AllowAnonymous]
        [HttpGet("notes/{id}")]
        public async Task<IActionResult> GetCommunityNoteDetails([FromRoute] long id)
        {
            var currentUserId = HttpContext.GetOptionalCurrentUserId() ?? 0;
            if (id <= 0)
            {
                return BadRequest(new { message = "You must provide proper note id" });
            }

            var noteDetails = await _communityService.GetPublicNoteByIdAsync(id, currentUserId);
            
            return Ok(noteDetails);

        }


        
    }
}
