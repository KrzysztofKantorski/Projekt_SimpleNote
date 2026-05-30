using Projekt_SimpleNote.Dto.Auth;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IAuthService
    {
        Task<(bool Success, string Message)> RegisterAsync(RegisterDto dto);

        Task<(bool Success, string Message, TokenResponseDto? Tokens)> LoginAsync(LoginDto dto);

        Task<(bool Success, string Message, TokenResponseDto? Tokens)> RefreshTokenAsync(string refreshToken);

        Task<(bool Success, string Message)> LogoutAsync(string refreshToken);
    }
}

