using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Users;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class UserService: IUserService
    {
        private readonly ApplicationDbContext _context;

        public UserService(ApplicationDbContext context)
        {
            _context = context;
        }
        
        public async Task<UserProfileDto?> GetUserProfileAsync(long userId)
        {
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
            {
                return null;
            }

            return new UserProfileDto(user.Id, user.Username, user.Role);
        } 
    }
}
