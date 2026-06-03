using Projekt_SimpleNote.Dto.Comments;// Upewnij się, że plik NoteCommentsDto istnieje w tym namespace

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IAdminCommentsService
    {
        //Get all comments
        Task<IEnumerable<CommentDto>> GetAllCommentsAsync();

        //Delete comment based on comment id
        Task<(bool Success, string Message)> DeleteCommentAsync(long commentId);
    }
}
