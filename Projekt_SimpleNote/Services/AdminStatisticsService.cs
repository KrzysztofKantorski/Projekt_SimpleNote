using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Statistics;
using Projekt_SimpleNote.Services.Interfaces;
using System;

namespace Projekt_SimpleNote.Services
{
    public class AdminStatisticsService: IAdminStatisticsService
    {
        private readonly ApplicationDbContext _context;

        public AdminStatisticsService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardStatsDto> GetDashboardStatisticsAsync()
        {
            //Get user stats - isActive and banned 
            var usersResult = await _context.Users
                .GroupBy(u => u.IsActive)
                .Select(g => new { IsActive = g.Key, Count = g.Count() })
                .ToListAsync();

            //Note statistics - how many in time
            var monthAgo = DateTime.UtcNow.AddDays(-30);
            var notesResultRaw = await _context.Notes
                .Where(n => n.CreatedAt >= monthAgo)
                .GroupBy(n => n.CreatedAt.Date)
                .Select(g => new { Date = g.Key, Count = g.Count() })
                .OrderBy(n => n.Date)
                .ToListAsync();

            //Subject statistics - how many of each used in notes
            var subjectsResultRaw = await _context.Notes
                .Where(n => n.Subject != null)
                .GroupBy(n => n.Subject!.Name)
                .Select(g => new { SubjectName = g.Key, Count = g.Count() })
                .OrderByDescending(s => s.Count)
                .ToListAsync();

            var activeUsers = usersResult.FirstOrDefault(u => u.IsActive)?.Count ?? 0;
            var bannedUsers = usersResult.FirstOrDefault(u => !u.IsActive)?.Count ?? 0;
            var userStats = new UserStatisticsDto(activeUsers, bannedUsers);

            var formattedNotesResult = notesResultRaw
                .Select(n => new NoteStatisticsDto(n.Date.ToString("yyyy-MM-dd"), n.Count))
                .ToList();

            var subjectsResult = subjectsResultRaw
                .Select(s => new SubjectStatistics(s.SubjectName, s.Count))
                .ToList();

            return new DashboardStatsDto(
                userStats,
                formattedNotesResult,
                subjectsResult
            );
        }
    }
}
