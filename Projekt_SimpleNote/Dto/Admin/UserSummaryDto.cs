namespace Projekt_SimpleNote.Dto.Admin
{
    public record UserSummaryDto(
        long Id,
        string Username,
        bool IsActive,
        DateTime CreatedAt
    );
}
