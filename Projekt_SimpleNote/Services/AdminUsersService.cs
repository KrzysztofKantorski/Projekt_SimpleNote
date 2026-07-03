using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class AdminUsersService : IAdminUsersService
    {
        private readonly ApplicationDbContext _context;

        public AdminUsersService(ApplicationDbContext context)
        {
            _context = context;
        }

        //Get all users
        public async Task<PagedResult<UserSummaryDto>> GetAllUsersAsync(PaginationParamsDto paginationParams)
        {
            //return users
            return await _context.Users
                .AsNoTracking()
                .OrderByDescending(u => u.CreatedAt)
                .Select(u => new UserSummaryDto(
                    u.Id,
                    u.Username,
                    u.IsActive,
                    u.CreatedAt
                ))
                .ToPagedResultAsync(paginationParams.PageNumber, paginationParams.PageSize);
        }


        //Get users details - ef core provides count function

        public async Task<(bool Success, string Message, UserDetailsAdminDto? Data)> GetUserByIdAsync(long userId)
        {
            var user = await _context.Users
                .AsNoTracking()
                .Where(u => u.Id == userId)
                .Select(u => new UserDetailsAdminDto(
                    u.Id,
                    u.Username,
                    u.IsActive,
                    u.CreatedAt,
                    u.MyNotes.Count,
                    u.Comments.Count,
                    u.Reactions.Count
                ))
                .FirstOrDefaultAsync();

            if (user == null)
            {
                return (false, "User does not exist", null);
            }

            return (true, "User found successfully.", user);
        }


        //Ban user (change isActive flag to false and remove refresh token)
        public async Task<(bool Success, string Message)> BanUserAsync(long userId)
        {
            // Find user and his refresh token
            var user = await _context.Users
                .Include(u => u.RefreshTokens)
                .FirstOrDefaultAsync(u => u.Id == userId);

            //check if user exists
            if (user == null)
            {
                return (false, "User does not exist");
            }

            //Check if admin wants to ban another admin
            if (user.Role == "Admin")
            {
                return (false, "You cannot ban another admin user");
            }

            //Ban
            user.IsActive = false;

            //Logout user
            if (user.RefreshTokens.Any())
            {
                _context.RefreshTokens.RemoveRange(user.RefreshTokens);
            }

            await _context.SaveChangesAsync();

            return (true, "");
        }






    }
}
