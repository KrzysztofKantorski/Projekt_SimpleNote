namespace Projekt_SimpleNote.Dto.Notes
{
    public record NoteDto(
      long Id,
      string Title,
      string Content,
      string? SubjectName,
      List<string>? TagNames,
      DateTime CreatedAt,
      DateTime? UpdatedAt
   );

}
