using Projekt_SimpleNote.Dto.Admin;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IAdminUsersService
    {
        //Get all users 
        Task<IEnumerable<UserSummaryDto>> GetAllUsersAsync();


        //Get user details
        Task<(bool Success, string Message, UserDetailsAdminDto? Data)> GetUserByIdAsync(long userId);


        //Ban user
        Task<(bool Success, string Message)> BanUserAsync(long userId);
    }
}
