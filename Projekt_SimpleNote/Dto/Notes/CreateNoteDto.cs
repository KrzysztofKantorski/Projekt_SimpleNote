namespace Projekt_SimpleNote.Dto.Notes
{
    public record CreateNoteDto(
        string Title,
        string Content,
        string? SubjectName,       
        List<string>? TagNames,    
        bool IsPublic
   );
}
