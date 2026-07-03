using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IAdminReactionsService
    {
        //Get all reaction types
        Task<PagedResult<ReactionTypeDto>> GetAllReactionTypesAsync(PaginationParamsDto paginationParams);

        //Create new reaction type
        Task<(bool Success, string Message, ReactionTypeDto? Data)> AddReactionTypeAsync(CreateReactionTypeDto dto);


        //Delete reaction type
        Task<(bool Success, string Message)> DeleteReactionTypeAsync(long id);


        //Update reaction type
        Task<(bool Success, string Message, ReactionTypeDto? Data)> UpdateSubjectAsync(long id, CreateReactionTypeDto dto);
    }
}
