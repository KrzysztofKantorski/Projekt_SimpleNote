namespace Projekt_SimpleNote.Dto.Interactions
{
    public record CommentDto(
         long Id,
         string Content,
         string AuthorName,
         DateTime CreatedAt,

         //Replies to comment
         List<CommentDto> Replies
     );
}
