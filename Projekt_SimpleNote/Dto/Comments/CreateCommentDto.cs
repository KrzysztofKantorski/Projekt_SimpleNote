namespace Projekt_SimpleNote.Dto.Comments
{
    public record CreateCommentDto(
       string Content,
       long? ParentCommentId
     );
}
