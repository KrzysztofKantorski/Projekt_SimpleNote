using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Community;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class CommunityService: ICommunityService
    {
        private readonly ApplicationDbContext _context;

        public CommunityService(ApplicationDbContext context)
        {
            _context = context;
        }

        //Get notes from community

        public async Task <IEnumerable<CommunityNoteListDto>> GetPublicNotesAsync(
             string? phrase,
             string? subject,
             string? tag,
             long currentUserId)
        {

            //Get only notes that are public and dont belong to current user
            var notes = _context.Notes
                .AsNoTracking()
                .Where(n => n.IsPublic && n.UserId != currentUserId)
                .AsQueryable();



            //Check all filters

            if (!string.IsNullOrEmpty(phrase))
            {
                var phraseLower = phrase.Trim().ToLower();

                notes = notes
                    .Where(n => n.Title
                        .ToLower()
                        .Contains(phraseLower)
                    );
            }

            if (!string.IsNullOrEmpty(subject))
            {
                var subjectLower = subject.Trim().ToLower();

                notes = notes.Where(n => n.Subject != null && n.Subject.Name.ToLower() == subjectLower);
            }

            if (!string.IsNullOrWhiteSpace(tag))
            {
                var tagLower = tag.Trim().ToLower();
                notes = notes
                    .Where(n => n.Tags
                        .Any(t => t.Name
                            .ToLower() == tagLower
                        )
                    );
            }


            var DisplayNotes = await notes
                .OrderByDescending(n => n.CreatedAt)
                .Take(50)
                .Select(n => new CommunityNoteListDto(
                    n.Id,
                    n.Title,
                    n.User.Username,
                    n.Subject != null ? n.Subject.Name : null,
                    n.Tags.Select(t => t.Name).ToList(),
                    n.CreatedAt
                ))
                .ToListAsync();

            return DisplayNotes;
        }


        //Display community note details based on note id

        public async Task<CommunityNoteDetailsDto?> GetPublicNoteByIdAsync(long noteId, long currentUserId)
        {

            //Query data

            var note = await _context.Notes
                .AsNoTracking()
                .Include(n => n.User)
                .Include(n => n.Subject)
                .Include(n => n.Tags)
                .Include(n => n.SavedByUsers) 
                .FirstOrDefaultAsync(n => n.Id == noteId && n.IsPublic);

            if(note == null )
            {
                return(null);
            }

            //Map to dto
            var noteDto =  new CommunityNoteDetailsDto(
                Id: note.Id,
                Title: note.Title,
                Content: note.Content,
                AuthorName: note.User.Username,
                SubjectName: note.Subject?.Name,
                TagNames: note.Tags.Select(t => t.Name).ToList(),
                CreatedAt: note.CreatedAt,
                UpdatedAt: note.UpdatedAt,
                IsSavedByCurrentUser: note.SavedByUsers.Any(u => u.Id == currentUserId)
            );

            return (noteDto);

        }
    }
}
