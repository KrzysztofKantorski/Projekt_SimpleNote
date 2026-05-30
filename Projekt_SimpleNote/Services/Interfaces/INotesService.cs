using Projekt_SimpleNote.Dto.Notes;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface INotesService
    {
        Task<IEnumerable<NoteDto>> GetAllUserNotesAsync(long userId);

        Task<NoteDto?> GetNoteByIdAsync(long id, long userId);

        Task<NoteDto> CreateNoteAsync(CreateNoteDto dto, long userId);

        Task<(bool Success, string Message, NoteDto? Note)> UpdateNoteAsync(long id, UpdateNoteDto dto, long userId);

        Task<(bool Success, string Message)> DeleteNoteAsync(long id, long userId);
    }
}
