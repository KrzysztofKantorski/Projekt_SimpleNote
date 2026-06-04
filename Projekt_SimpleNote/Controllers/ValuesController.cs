using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Extensions;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/test")]
    [ApiController]
    public class ValuesController : ControllerBase
    {
        [HttpGet("")]
        public IActionResult GetCommunityNotes()
        {
            var notes = new List<object>
            {
                new { Note = "note 1", Visibility = "public" },
                new { Note = "note 2", Visibility = "public" },
                new { Note = "note 3", Visibility = "public" }
            };

            return Ok(notes);
        }
    }
}
