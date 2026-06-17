using Projekt_SimpleNote.Dto.Statistics;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IAdminStatisticsService
    {
        //Get statistics for charts
        Task<DashboardStatsDto> GetDashboardStatisticsAsync();
    }
}
