using Projekt_SimpleNote.Dto.Comments;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface ICommentsService
    {
        //Get note comments (and replies)
        Task<(bool Success, string Message, IEnumerable<CommentDto>? Comments)> GetCommentsAsync
            (long noteId, long currentUserId);

        //Add comment to note
        Task<(bool Success, string Message, CommentDto? Data)> CreateCommentAsync
            (long noteId, long currentUserId, CreateCommentDto dto);

        //Delete comment from note
        Task<(bool Success, string Message)> DeleteCommentAsync
            (long noteId, long currentUserId, long commentId);
    }
}
