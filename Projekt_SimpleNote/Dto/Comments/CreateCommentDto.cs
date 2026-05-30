namespace Projekt_SimpleNote.Dto.Interactions
{
    public record CreateCommentDto(
       string Content,
       long? ParentCommentId
     );
}
