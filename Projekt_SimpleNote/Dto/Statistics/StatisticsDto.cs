namespace Projekt_SimpleNote.Dto.Statistics
{
    public record DashboardStatsDto(
        UserStatisticsDto Users,
        IEnumerable<NoteStatisticsDto> NotesOverTime,
        IEnumerable<SubjectStatistics> SubjectsDistribution
    );
}
