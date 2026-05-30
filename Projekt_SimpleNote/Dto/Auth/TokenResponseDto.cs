namespace Projekt_SimpleNote.Dto.Auth
{
    public record TokenResponseDto(
        string AccessToken,
        string RefreshToken
    );
}
