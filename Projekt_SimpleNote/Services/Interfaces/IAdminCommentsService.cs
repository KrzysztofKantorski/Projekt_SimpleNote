using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Dto.Pagination;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IAdminCommentsService
    {
        //Get all comments
        Task<PagedResult<CommentDto>> GetAllCommentsAsync(PaginationParamsDto paginationParams);

        //Delete comment based on comment id
        Task<(bool Success, string Message)> DeleteCommentAsync(long commentId);
    }
}
