using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Dto.Notes;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/notes")]
    [ApiController]
    [Authorize]
    public class NotesController : ControllerBase
    {
        private long currentUserId => Convert.ToInt64(HttpContext.Items["CurrentUserId"]);
        private readonly INotesService _notesService;
        public NotesController(INotesService notesService)
        {
            _notesService = notesService;
        }

        //Get note by note and user id

        [HttpGet("{id}")]
        public async Task<IActionResult> GetNoteById([FromRoute] long id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "You must provide proper note id" });
            }

            
            var note = await _notesService.GetNoteByIdAsync(id, currentUserId);

            if (note == null)
            {
                return NotFound(new { message = "Note does not exist." });
            }

            return Ok(note);

        }


        //Get user Notes

        [HttpGet]
        public async Task<IActionResult> GetAllNotes()
        {
           
            var notes = await _notesService.GetAllUserNotesAsync(currentUserId);

            return Ok(notes);

        }



        //Create note

        [HttpPost]
        public async Task<IActionResult> CreateNote(CreateNoteDto dto)
        {
           

            var newNote = await _notesService.CreateNoteAsync(dto, currentUserId);

            return Ok(newNote);
        }




        //Update note

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateNote(long id, [FromBody] UpdateNoteDto dto)
        {
           

            var result = await _notesService.UpdateNoteAsync(id, dto, currentUserId);

            //If note was not found
            if (!result.Success)
            {
                return NotFound(new { message = result.Message });
            }

            return Ok(result.Note);
        }


        //Delete note by note and user id

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteNote([FromRoute] long id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "You must provide proper note id" });
            }

            var result = await _notesService.DeleteNoteAsync(id, currentUserId);
            if (!result.Success)
            {
                return BadRequest(result.Message);
            }
            return NoContent();
        }
    }
}
