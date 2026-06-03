namespace Projekt_SimpleNote.Dto.Admin
{
    public record UserDetailsAdminDto(
         long Id,
         string Username,
         bool IsActive,
         DateTime CreatedAt,
         int TotalNotes,      
         int TotalComments,
         int TotalReactions
     );
}
