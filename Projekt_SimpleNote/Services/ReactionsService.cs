using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Reactions;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class ReactionsService : IReactionsService
    {
        private readonly ApplicationDbContext _context;

        public ReactionsService(ApplicationDbContext context)
        {
            _context = context;
        }


        //Get avaliable reactions 
        public async Task<IEnumerable<AvailableReactionDto>> GetAvailableReactionsAsync()
        {
            //Query data
            var reactions = await _context.ReactionTypes
                .AsNoTracking()
                .ToListAsync();


            //Map to dto
            var reactionsDto = reactions.Select(n => new AvailableReactionDto(
                n.Id,
                n.Name,
                n.IconUrl
            ));

            return reactionsDto;
        }


        //Get note reactions

        public async Task<IEnumerable<NoteReactionSummaryDto>> GetNoteReactionsSummaryAsync(long noteId, long currentUserId)
        {

            var noteReactions = await _context.ReactionTypes
                .AsNoTracking()
                .Where(rt => rt.Reactions
                    .Count(
                        nr => nr.NoteId == noteId) > 0
                    )
                .Select(rt => new NoteReactionSummaryDto(
                     rt.Id,
                     rt.Name,
                     rt.IconUrl,
                     rt.Reactions
                        .Count(nr => nr.NoteId == noteId),
                     rt.Reactions
                        .Any
                        (
                            nr => nr.NoteId == noteId && 
                            nr.UserId == currentUserId
                        )
                ))
                .ToListAsync();

            return noteReactions;
        }


        //Add reaction to note

        public async Task<(bool Success, string Message)> AddReactionAsync
            (long noteId, long reactionTypeId, long currentUserId)
        {
      
            //Check if note exists
            var note = await _context.Notes.FirstOrDefaultAsync(n => n.Id == noteId);

            //Check if note is null
            if (note == null) {
                return (false, "Note does not exist");
            }

            //Check if note is public and belongs to user
            if(!note.IsPublic && note.UserId != currentUserId)
            {
                return (false, "Access denied");
            }

            //Check if user tries to add reaction to his own note
            if (note.UserId == currentUserId)
            {
                return (false, "You cannot add reactions to your own notes");
            }

            //Check if provided reaction exists
            var reaction = await _context.ReactionTypes
                .AnyAsync(r => r.Id == reactionTypeId);

            if(!reaction)
            {
                return (false, "Provided reaction does not exist");
            }

            //Check if user alerdy selected reaction
            var alerdyReacted = await _context.NoteReactions
                .AnyAsync
                (
                    n => n.NoteId == noteId &&
                    n.UserId == currentUserId &&
                    n.ReactionTypeId == reactionTypeId 
                );

            if (alerdyReacted)
            {
             
                return (false, "Reaction has alerdy been added");
            }

            var reactionObject = new NoteReaction
            {
                NoteId = noteId,
                UserId = currentUserId,
                ReactionTypeId = reactionTypeId,
                CreatedAt = DateTime.UtcNow
            };

            _context.NoteReactions.Add(reactionObject);
            await _context.SaveChangesAsync();

            return (true, "");

        }


        //Delete reaction from note

        public async Task<(bool Success, string Message)> RemoveReactionAsync
            (long noteId, long reactionTypeId, long currentUserId)
        {
            //
            var reaction = await _context.NoteReactions
                .FirstOrDefaultAsync
                (
                    nr => nr.NoteId == noteId && 
                    nr.UserId == currentUserId && 
                    nr.ReactionTypeId == reactionTypeId
                );

            if (reaction == null)
            {
                return (true, "Reaction does not exist.");
            }

            _context.NoteReactions.Remove(reaction);
            await _context.SaveChangesAsync();

            return (true, "");
        }


    }



}
