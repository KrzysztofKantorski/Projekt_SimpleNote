using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class CommentsService: ICommentsService
    {
        private readonly ApplicationDbContext _context;

        public CommentsService(ApplicationDbContext context)
        {
            _context = context;
        }

        //Get note commetns (and replies)
        public async Task<(bool Success, string Message, IEnumerable<CommentDto>? Comments)> GetCommentsAsync(
            long noteId,
            long currentUserId
        )
        {
            //Check if note exists
            var note = await _context.Notes
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    n => n.Id == noteId
                );

            if (note == null)
            {
                return (false, "Note does not exist.", null);
            }

            if (!note.IsPublic && note.UserId != currentUserId) {
                return (false, "Permision denied.", null);
            }

            var comments = await _context.Comments
                .AsNoTracking()
                .Include(c => c.User)

                //Get replies to comments
                .Include(c => c.Replies)
                    .ThenInclude(r => r.User)
                .Where(c => c.NoteId == noteId && c.ParentCommentId == null)

                //Display comments from newest
                .OrderByDescending(c => c.CreatedAt) 
                .ToListAsync();

            var commentsDto = comments.Select(c => new CommentDto(
                c.Id,
                c.Content,
                c.User.Username,
                c.CreatedAt,

                //Comment replies
                c.Replies.OrderBy(r => r.CreatedAt).Select(r => new CommentDto(
                    r.Id,
                    r.Content,
                    r.User.Username,
                    r.CreatedAt,
                    new List<CommentDto>()
                )).ToList()

            )).ToList();

            return (true, "", commentsDto);
        }



        //Add comment to note
        public async Task<(bool Success, string Message, CommentDto? Data)> CreateCommentAsync
        (
            long noteId, 
            long currentUserId, 
            CreateCommentDto dto
        )
        {
            //Check if note exists
            var note = await _context.Notes
                .FirstOrDefaultAsync(
                    n => n.Id == noteId
                );

            if (note == null)
            {
                return (false, "Note does not exist.", null);
            }

            if (!note.IsPublic && note.UserId != currentUserId)
            {
                return (false, "Permision denied.", null);
            }

            //check if user created comment or replied to existing one
            if (dto.ParentCommentId.HasValue)
            {
                var parentComment = await _context.Comments
                    .FirstOrDefaultAsync(
                        c => c.Id == dto.ParentCommentId
                    );

                if (parentComment == null)
                {
                    return (false, "Comment does not exist.", null);
                }

                if (parentComment.NoteId != noteId)
                {
                    return (false, "You cant answer to this comment.", null);
                }
               
            }

            //Create comment object
            var newComment = new Comment
            {
                NoteId = noteId,
                UserId = currentUserId,
                ParentCommentId = dto.ParentCommentId,
                Content = dto.Content.Trim(),
                CreatedAt = DateTime.UtcNow
            };

            //Save comment to db
            _context.Comments.Add(newComment);
            await _context.SaveChangesAsync();

            //Get user data
            var user = await _context.Users.FindAsync(currentUserId);

            //Save data to dto
            var commentDto = new CommentDto(
                newComment.Id,
                newComment.Content,
                user!.Username,
                newComment.CreatedAt,

                //Replies
                new List<CommentDto>()
            );

            return (true, "Comment added successfully", commentDto);
        }


        //Delete comment based on comment id
        public async Task<(bool Success, string Message)> DeleteCommentAsync
        (
            long noteId, 
            long commentId,
            long currentUserId
        )
        {

            //check if comment exists
            var comment = await _context.Comments
                .Include(c => c.Replies)
                .FirstOrDefaultAsync(c => c.Id == commentId);

            if (comment == null)
            {
                return (false, "Comment does not exist");
            }

            //check if comment belongs to note
            if (comment.NoteId != noteId)
            {
                return (false, "Comment does not belong to note");
            }

            //check if comment belongs to user
            if (comment.UserId != currentUserId)
            {
                return (false, "Access denied");
            }

            //Ef core will also delete replies to deleted comments
            _context.Comments.Remove(comment);
            await _context.SaveChangesAsync();

            return (true, "");
        }

    }
}
