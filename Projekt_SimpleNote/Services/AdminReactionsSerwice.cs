using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class AdminReactionsSerwice: IAdminReactionsService
    {
        private readonly ApplicationDbContext _context;

        public AdminReactionsSerwice(ApplicationDbContext context)
        {
            _context = context;
        }


        //Get all reaction types
        public async Task<PagedResult<ReactionTypeDto>> GetAllReactionTypesAsync(PaginationParamsDto paginationParams)
        {

            var reactionTypes = await _context.ReactionTypes
                .Select(rt => new ReactionTypeDto
                (
                    rt.Id,
                    rt.Name, 
                    rt.IconUrl
                ))
                .ToPagedResultAsync(paginationParams.PageNumber, paginationParams.PageSize);

            return (reactionTypes);
        }

        //Add new reaction type
        public async Task<(bool Success, string Message, ReactionTypeDto? Data)> AddReactionTypeAsync(CreateReactionTypeDto dto)
        {
            //check if reaction alerdy extsts
            var existingReaction = await _context.ReactionTypes
                .AnyAsync(
                    r => r.Name.ToLower() == dto.Name.ToLower()
                );

            if (existingReaction)
            {
                return (false, "This reaction alerdy exists.", null);
            }

            var newReaction = new ReactionType
            {
                Name = dto.Name,
                IconUrl = dto.IconUrl
            };

            await _context.ReactionTypes.AddAsync(newReaction);
            await _context.SaveChangesAsync();

            var resultDto = new ReactionTypeDto
                (
                    newReaction.Id,
                    newReaction.Name, 
                    newReaction.IconUrl
                );

            return (true, "New reaction was added", resultDto);

        }

        //Update reaction type
        public async Task<(bool Success, string Message, ReactionTypeDto? Data)> UpdateSubjectAsync(long id, CreateReactionTypeDto dto)
        {
            var reaction = await _context.ReactionTypes.FirstOrDefaultAsync(s => s.Id == id);

            if (reaction == null)
            {
                return (false, "Subject not found.", null);
            }

            //Check if the new name is already taken by another subject
            var nameConflict = await _context.ReactionTypes
                .AnyAsync(
                    s => s.Id != id 
                    && s.Name.ToLower() == dto.Name.ToLower()
                );

            if (nameConflict)
            {
                return (false, "This subject alerdy exists", null);
            }

            reaction.Name = dto.Name;
            reaction.IconUrl = dto.IconUrl;

            await _context.SaveChangesAsync();

            var subjectDto = new ReactionTypeDto
                (
                    reaction.Id,
                    reaction.Name, 
                    reaction.IconUrl
                );
            return (true, "Reaction updated", subjectDto);

        }



        //Delete reaction type
        public async Task<(bool Success, string Message)> DeleteReactionTypeAsync(long id)
        {
            // Get reaction type, check if it was used in notes
            var reactionType = await _context.ReactionTypes
                .Include(rt => rt.Reactions)
                .FirstOrDefaultAsync(rt => rt.Id == id);


            if (reactionType == null)
            {
                return (false, "Reaction does not exist.");
            }

            // Reaction cannot be deleted - data inconsistency
            if (reactionType.Reactions.Any())
            {
                return (false, "This reaction is used in notes. It cannot be deleted");
            }

            _context.ReactionTypes.Remove(reactionType);
            await _context.SaveChangesAsync();

            return (true, "");
        }

    }
}
