using Projekt_SimpleNote.Dto.Community;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface ISavedNotesService
    {
        //Save note from community based on id
        Task<(bool Success, string Message)> AddNoteToSavedAsync(long noteId, long currentUserId);


        //Delete note from community based on id
        Task<(bool Success, string Message)> RemoveNoteFromSavedAsync(long noteId, long currentUserId);


        //Get all notes saved from community
        Task<IEnumerable<CommunityNoteListDto>> GetSavedNotesAsync(long currentUserId);
    }
}
