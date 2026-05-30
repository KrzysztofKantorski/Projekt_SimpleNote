using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Community;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class SavedNotesService: ISavedNotesService
    {
        private readonly ApplicationDbContext _context;
        public SavedNotesService(ApplicationDbContext context)
        {
            _context = context;
        }


       //Get notes saved by user
        public async Task<IEnumerable<CommunityNoteListDto>> GetSavedNotesAsync(long currentUserId)
        {
           
            var query = _context.Notes
                .AsNoTracking()
                .Where(n => n.SavedByUsers.Any(u => u.Id == currentUserId))
                .AsQueryable();

            var savedNotes = await query
                //Sort from newest
                .OrderByDescending(n => n.CreatedAt) 
                .Select(n => new CommunityNoteListDto(
                    n.Id,
                    n.Title,

                    //Note author
                    n.User.Username, 
                    n.Subject != null ? n.Subject.Name : null,
                    n.Tags.Select(t => t.Name).ToList(),
                    n.CreatedAt
                ))
                .ToListAsync();

            return savedNotes;
        }



        //Add community note to saved
        public async Task<(bool Success, string Message)> AddNoteToSavedAsync(long noteId, long currentUserId)
        {
            //Check note id and 
            var note = await _context.Notes
                .Include(n => n.SavedByUsers)
                .FirstOrDefaultAsync(n => n.Id == noteId);

            if (note == null)
            {
                return (false, "Note does not exist");
            }

            //Check if note is created by the same user
            if (note.UserId == currentUserId)
            {
                return (false, "You cant save your own note");
            }

            //Check if user alerdy saved note
            if (note.SavedByUsers.Any(u => u.Id == currentUserId))
            {
                return (true, "Note is alerdy saved");
            }

            //Check if user exists
            var user = await _context.Users.FindAsync(currentUserId);

            if (user == null)
            {
                return (false, "User not found");
            }

            note.SavedByUsers.Add(user);
            await _context.SaveChangesAsync();
            return (true, "Added to saved.");
        }




        //Delete community note from saved
        public async Task<(bool Success, string Message)> RemoveNoteFromSavedAsync(long noteId, long currentUserId)
        {
            //Check note id and 
            var note = await _context.Notes
                .Include(n => n.SavedByUsers)
                .FirstOrDefaultAsync(n => n.Id == noteId);

            if (note == null)
            {
                return (false, "Note does not exist");
            }


            //Check if note was saved by user
            var user = note.SavedByUsers.FirstOrDefault(u => u.Id == currentUserId);

            if (user == null)
            {
                return (true, "Note is not saved");
            }

            note.SavedByUsers.Remove(user);
            await _context.SaveChangesAsync();

            return (true, "Noted deleted from saved");
        }
    }
}
