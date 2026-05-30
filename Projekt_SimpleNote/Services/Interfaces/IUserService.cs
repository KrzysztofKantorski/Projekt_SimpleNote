using Projekt_SimpleNote.Dto.Users;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IUserService
    {
        Task<UserProfileDto?> GetUserProfileAsync(long userId);
    }
}
