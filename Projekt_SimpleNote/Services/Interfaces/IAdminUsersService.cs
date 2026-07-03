using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IAdminUsersService
    {
        //Get all users 
        Task<PagedResult<UserSummaryDto>> GetAllUsersAsync(PaginationParamsDto paginationParams);


        //Get user details
        Task<(bool Success, string Message, UserDetailsAdminDto? Data)> GetUserByIdAsync(long userId);


        //Ban user
        Task<(bool Success, string Message)> BanUserAsync(long userId);
    }
}
