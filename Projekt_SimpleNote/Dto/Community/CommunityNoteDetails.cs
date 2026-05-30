namespace Projekt_SimpleNote.Dto.Community
{
    public record CommunityNoteDetailsDto(
        long Id,
        string Title,
        string Content, 
        string AuthorName,
        string? SubjectName,
        List<string> TagNames,
        DateTime CreatedAt,
        DateTime? UpdatedAt,
        bool IsSavedByCurrentUser 
    );
}
