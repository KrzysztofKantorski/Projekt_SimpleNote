using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Controllers
{
    [Route("api/admin/stats")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminStatsController : ControllerBase
    {
        private readonly IAdminStatisticsService _adminStatsService;

        public AdminStatsController(IAdminStatisticsService adminStatsService)
        {
            _adminStatsService = adminStatsService;
        }
        [HttpGet]
        public async Task<IActionResult> GetDashboardStats()
        {
            var result = await _adminStatsService.GetDashboardStatisticsAsync();

            return Ok(result);
        }
    }
}