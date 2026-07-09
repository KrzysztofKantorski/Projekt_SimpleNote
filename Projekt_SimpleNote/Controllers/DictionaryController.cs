using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/dictionaries")]
    [ApiController]
    [Authorize]
    public class DictionaryController : ControllerBase
    {

        private readonly IDictionaryService _dictionaryService;

        public DictionaryController(IDictionaryService dictionaryService)
        {
            _dictionaryService = dictionaryService;
        }


        //Get tags  

        [HttpGet("tags")]
        public async Task<IActionResult> GetTags([FromQuery] string? search)
        {
            var tags = await _dictionaryService.GetTagsAsync(search);
            return Ok(tags);
        }


        //Get subjects

        [HttpGet("subjects")]
        public async Task<IActionResult> GetSubjectsAsync(string? search)
        {
            var subjects = await _dictionaryService.GetSubjectsAsync(search);
            return Ok(subjects);
        }

    }
}
