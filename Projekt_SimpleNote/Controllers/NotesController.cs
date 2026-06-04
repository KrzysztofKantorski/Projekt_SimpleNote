using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Dto.Notes;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/notes")]
    [ApiController]
    [Authorize]
    public class NotesController : ControllerBase
    {

        private readonly INotesService _notesService;
        private readonly IValidator<CreateNoteDto> _createNoteValidator;
        private readonly IValidator<UpdateNoteDto> _updateNoteValidator;
        public NotesController(INotesService notesService, IValidator<CreateNoteDto> createNoteValidator, IValidator<UpdateNoteDto> updateNoteValidator)
        {
            _notesService = notesService;
            _createNoteValidator = createNoteValidator;
            _updateNoteValidator = updateNoteValidator;
        }

        //Get note by note and user id

        [HttpGet("{id}")]
        public async Task<IActionResult> GetNoteById([FromRoute] long id)
        {
            var currentUserId = HttpContext.GetCurrentUserId();
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
            var currentUserId = HttpContext.GetCurrentUserId();
            var notes = await _notesService.GetAllUserNotesAsync(currentUserId);

            return Ok(notes);

        }



        //Create note

        [HttpPost]
        public async Task<IActionResult> CreateNote(CreateNoteDto dto)
        {

            var validationResult = await _createNoteValidator.ValidateAsync(dto);

            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }
            var currentUserId = HttpContext.GetCurrentUserId();

            var newNote = await _notesService.CreateNoteAsync(dto, currentUserId);

            return Ok(newNote);
        }




        //Update note

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateNote(long id, [FromBody] UpdateNoteDto dto)
        {
            var validationResult = await _updateNoteValidator.ValidateAsync(dto);

            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));
            }
            var currentUserId = HttpContext.GetCurrentUserId();

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
            var currentUserId = HttpContext.GetCurrentUserId();
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
