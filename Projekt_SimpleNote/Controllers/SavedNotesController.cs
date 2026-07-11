using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Services.Interfaces;
using System.Security.Claims;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/saved-notes")]
    [ApiController]
    [Authorize]
    public class SavedNotesController : ControllerBase
    {
        private readonly ISavedNotesService _savedNotesService;

        public SavedNotesController(ISavedNotesService savedNotesService)
        {
            _savedNotesService = savedNotesService;
        }

        //Get notes saved by user

        [HttpGet]
        public async Task<IActionResult> GetSavedNotes()
        {
            var currentUserId = HttpContext.GetCurrentUserId();
            var result = await _savedNotesService.GetSavedNotesAsync(currentUserId);
            return Ok(result);
        }


        //Save note from community

        [HttpPost("{noteId}")]
        public async Task<IActionResult> SaveNote([FromRoute] long noteId)
        {

            var currentUserId = HttpContext.GetCurrentUserId();
            if (currentUserId <= 0)
            {
                return Unauthorized(new { messasge = "Incorrect data" });
            }
            if (noteId <= 0)
            {
                return BadRequest(new { message = "You must provide proper note id" });
            }

            var result = await _savedNotesService.AddNoteToSavedAsync(noteId, currentUserId);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }

            return NoContent();
        }


        //Delete saved note

        [HttpDelete("{noteId}")]
        public async Task<IActionResult> RemoveSavedNote([FromRoute] long noteId)
        {
            var currentUserId = HttpContext.GetCurrentUserId();
            if (currentUserId <= 0)
            {
                return Unauthorized(new { messasge = "Incorrect data" });
            }

            if (noteId <= 0)
            {
                return BadRequest(new { message = "You must provide proper note id" });
            }

          
            var result = await _savedNotesService.RemoveNoteFromSavedAsync(noteId, currentUserId);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }
               

            return NoContent();
        }
    }
}
