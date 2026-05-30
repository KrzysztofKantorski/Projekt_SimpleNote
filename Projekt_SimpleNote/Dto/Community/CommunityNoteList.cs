namespace Projekt_SimpleNote.Dto.Community
{
    public record CommunityNoteListDto(
        long Id,
        string Title,
        string AuthorName,     
        string? SubjectName,
        List<string> TagNames,
        DateTime CreatedAt
    );
}
