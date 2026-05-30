using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Notes;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services.Interfaces;


namespace Projekt_SimpleNote.Services
{
    public class NotesService: INotesService
    {
        //Dbcontext
        private readonly ApplicationDbContext _context;

        //Validators
        private readonly IValidator<CreateNoteDto> _createNoteValidator;
        private readonly IValidator<UpdateNoteDto> _updateNoteValidator;

        public NotesService(ApplicationDbContext context, IValidator<CreateNoteDto> createNoteValidator, IValidator<UpdateNoteDto> updateNoteValidator)
        {
            _context = context;
            _createNoteValidator = createNoteValidator;
            _updateNoteValidator = updateNoteValidator;
        }

        //Get user notes
        public async Task<IEnumerable<NoteDto>> GetAllUserNotesAsync(long userId)
        {
            //Get user notes
            var notes = await _context.Notes
                .Include(n => n.Subject)
                .Include(n => n.Tags)
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.CreatedAt)
                .ToListAsync();

            //Save to dto
            var notesDto = notes.Select(n => new NoteDto(
                Id: n.Id,
                Title: n.Title,
                Content: n.Content,
                SubjectName: n.Subject?.Name,
                TagNames: n.Tags.Select(t => t.Name).ToList(),
                CreatedAt: n.CreatedAt,
                UpdatedAt: n.UpdatedAt
            )).ToList();

            return notesDto;
        }

        //Get note by note and user id
        public async Task<NoteDto?> GetNoteByIdAsync(long id, long userId)
        {
            var note = await _context.Notes
                .Include(n => n.Subject)
                .Include(n => n.Tags)
                .FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId);

            if (note == null)
            {
                return null; 
            }

            return new NoteDto(
                Id: note.Id,
                Title: note.Title,
                Content: note.Content,
                SubjectName: note.Subject?.Name,
                TagNames: note.Tags.Select(t => t.Name).ToList(),
                CreatedAt: note.CreatedAt,
                UpdatedAt: note.UpdatedAt
            );
        }



        //Create note
        public async Task<NoteDto> CreateNoteAsync(CreateNoteDto dto, long userId)
        {
            //Validate dto
            await _createNoteValidator.ValidateAndThrowAsync(dto);

            //Search subject or create new one
            Subject? subjectEntity = null;
            if (!string.IsNullOrWhiteSpace(dto.SubjectName))
            {
                var SubjectNameTrimmed = dto.SubjectName.Trim();

                //Search for subject in db
                subjectEntity = await _context.Subjects.FirstOrDefaultAsync(s => s.Name == SubjectNameTrimmed);

                //Save new subject to db
                if (subjectEntity == null) 
                {
                    subjectEntity = new Subject { Name = SubjectNameTrimmed };
                }

            }

            var tagsToAttach = new List<Tag>();

            if (dto.TagNames != null && dto.TagNames.Any())
            {
                //Clean user tags
                var cleanedTagNames = dto.TagNames.Select(t => t.Trim().ToLower()).ToList();

                //Search for tags in db
                var existingTags = await _context.Tags
                .Where(t => cleanedTagNames.Contains(t.Name.ToLower()))
                .ToListAsync();

                tagsToAttach.AddRange(existingTags);
                var existingTagNames = existingTags.Select(t => t.Name.ToLower());

                //Find new tags
                var newTagNames = cleanedTagNames.Except(existingTagNames);

                //Add new tags to db
                foreach (var newTagName in newTagNames)
                {
                    tagsToAttach.Add(new Tag { Name = newTagName });
                }
            }

            var noteEntity = new Note
            {
                Title = dto.Title.Trim(),
                Content = dto.Content.Trim(),
                IsPublic = dto.IsPublic,
                CreatedAt = DateTime.UtcNow,
                UserId = userId,
                Subject = subjectEntity,
                Tags = tagsToAttach
            };

            //Save data
            await _context.Notes.AddAsync(noteEntity);
            await _context.SaveChangesAsync();

            //Return dto
            return new NoteDto(
                Id: noteEntity.Id,
                Title: noteEntity.Title,
                Content: noteEntity.Content,
                SubjectName: noteEntity.Subject?.Name,
                TagNames: noteEntity.Tags.Select(t => t.Name).ToList(),
                CreatedAt: noteEntity.CreatedAt,
                UpdatedAt: noteEntity.UpdatedAt
            );

        }


        //Update note
        public async Task<(bool Success, string Message, NoteDto? Note)> UpdateNoteAsync(long id, UpdateNoteDto dto, long userId)
        {
            await _updateNoteValidator.ValidateAndThrowAsync(dto);

            //Check if note exists and belongs to user
            var existingNote = await _context.Notes
                .Include(n => n.Subject)
                .Include(n => n.Tags)
                .FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId); 

            if (existingNote == null)
            {
                return (false, "Note does not exist or you dont have permission", null);
            }

            //Update fields
            existingNote.Title = dto.Title.Trim();
            existingNote.Content = dto.Content.Trim();
            existingNote.IsPublic = dto.IsPublic;
            existingNote.UpdatedAt = DateTime.UtcNow;


            Subject? subjectEntity = null;
            if (!string.IsNullOrWhiteSpace(dto.SubjectName))
            {
                var SubjectNameTrimmed = dto.SubjectName.Trim();

                //Search for subject in db
                subjectEntity = await _context.Subjects.FirstOrDefaultAsync(s => s.Name == SubjectNameTrimmed);

                //Save new subject to db
                if (subjectEntity == null)
                {
                    subjectEntity = new Subject { Name = SubjectNameTrimmed };
                    await _context.Subjects.AddAsync(subjectEntity);
                }

                existingNote.Subject = subjectEntity;

            }
            else
            {
                existingNote.Subject = null; 
            }

            //Delete unused tags
            existingNote.Tags.Clear();
           
            if (dto.TagNames != null && dto.TagNames.Any())
            {
                //Get tags from dto
                var cleanedTagNames = dto.TagNames.Select(t => t.Trim().ToLower()).ToList();

                //Search tags in db
                var existingTags = await _context.Tags
                    .Where(t => cleanedTagNames.Contains(t.Name.ToLower()))
                    .ToListAsync();

                //Add existing tags to note
                foreach (var tag in existingTags)
                {
                    existingNote.Tags.Add(tag);
                }

                var existingTagNames = existingTags.Select(t => t.Name.ToLower());

                //Find new tags
                var newTagNames = cleanedTagNames.Except(existingTagNames);

                //Add new tags
                foreach (var newTagName in newTagNames)
                {
                    existingNote.Tags.Add(new Tag { Name = newTagName });
                }
            }

            //Save changes to db
            await _context.SaveChangesAsync();

            //Map to dto
            var updatedNoteDto = new NoteDto(
                Id: existingNote.Id,
                Title: existingNote.Title,
                Content: existingNote.Content,
                SubjectName: existingNote.Subject?.Name,
                TagNames: existingNote.Tags.Select(t => t.Name).ToList(),
                CreatedAt: existingNote.CreatedAt,
                UpdatedAt: existingNote.UpdatedAt
            );
            return (true, "Note updated successfully", updatedNoteDto);
        }


        public async Task<(bool Success, string Message)> DeleteNoteAsync(long id, long userId)
        {
            var deletedRows = await _context.Notes
                .Where(n => n.Id == id && n.UserId == userId)
                .ExecuteDeleteAsync();

            if (deletedRows == 0)
            {
                return (false, "Note does not exists or you dont have permission");
            }
            return (true, "");
        }





    }


}
