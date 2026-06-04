using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class AdminCommentsService: IAdminCommentsService
    {
        private readonly ApplicationDbContext _context;

        public AdminCommentsService(ApplicationDbContext context)
        {
            _context = context;
        }
        

        //Get all comments
        public async Task<IEnumerable<CommentDto>> GetAllCommentsAsync()
        {

             var commentsDto = await _context.Comments
                .AsNoTracking()
                .Where(c => c.ParentCommentId == null && !c.IsHiddenByAdmin)
                .OrderByDescending(c => c.CreatedAt)
                .Select(c => new CommentDto(
                     c.Id,
                     c.Content,
                     c.User.Username,
                     c.CreatedAt,
                     c.Replies
                         .Where(r => !r.IsHiddenByAdmin)
                         .OrderBy(r => r.CreatedAt)
                         .Select(r => new CommentDto(
                             r.Id,
                             r.Content,
                             r.User.Username,
                             r.CreatedAt,
                             new List<CommentDto>()
                         ))
                         .ToList()
                 ))
                 .ToListAsync();

             return commentsDto;
        }

        //Delete comment with replies
        public async Task<(bool Success, string Message)> DeleteCommentAsync(long commentId)
        {
            //Find comment based on id  
            var comment = await _context.Comments
                .Include(c => c.Replies)
                .FirstOrDefaultAsync(c => c.Id == commentId);


            if (comment == null)
            {
                return (false, "Comment not found");
            }

            comment.IsHiddenByAdmin = true;


            //Hide all replies

            if (comment.Replies != null && comment.Replies.Any())
            {
                foreach (var reply in comment.Replies)
                {
                    reply.IsHiddenByAdmin = true;
                }
            }


            await _context.SaveChangesAsync();
            return (true, "");
        }
    }
}
