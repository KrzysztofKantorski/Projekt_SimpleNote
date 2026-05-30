using Projekt_SimpleNote.Dto.Reactions;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IReactionsService
    {
        //Get avaliable note reactions
        Task<IEnumerable<AvailableReactionDto>> GetAvailableReactionsAsync();

        //Get note reactions
        Task<IEnumerable<NoteReactionSummaryDto>> GetNoteReactionsSummaryAsync(long noteId, long currentUserId);

        //Add reactions to note
        Task<(bool Success, string Message)> AddReactionAsync(long noteId, long reactionTypeId, long currentUserId);

        //Delete reactions from note
        Task<(bool Success, string Message)> RemoveReactionAsync(long noteId, long reactionTypeId, long currentUserId);
    }
}
