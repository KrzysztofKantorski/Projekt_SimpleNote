using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/admin/comments")]
    [Authorize(Roles = "Admin")]
    [ApiController]
    public class AdminCommentsController : ControllerBase
    {
        private readonly IAdminCommentsService _adminCommentsService;

        public AdminCommentsController(IAdminCommentsService adminCommentsService)
        {
            _adminCommentsService = adminCommentsService;
        }


        [HttpGet]
        public async Task<IActionResult> GetAllComments()
        {
            var result = await _adminCommentsService.GetAllCommentsAsync();
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
