using Projekt_SimpleNote.Dto.Community;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface ICommunityService
    {
        //Get notes from users based on filters
        Task<IEnumerable<CommunityNoteListDto>> GetPublicNotesAsync(
             string? phrase,
             string? subject,
             string? tag,
             long currentUserId
         );


        //Get note details by note id
        Task<CommunityNoteDetailsDto?> GetPublicNoteByIdAsync(long noteId, long currentUserId);
    }
}
