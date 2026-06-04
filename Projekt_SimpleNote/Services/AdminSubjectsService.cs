using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class AdminSubjectsService: IAdminSubjectsService
    {
        private readonly ApplicationDbContext _context;

        public AdminSubjectsService(ApplicationDbContext context)
        {
            _context = context;
        }


       //Get all subjects
       public async Task<IEnumerable<SubjectDto>> GetAllSubjectsAsync()
        {
            //Get all subjects
            var subjects = await _context.Subjects
                .Select(s => new SubjectDto
                (
                    s.Id,
                    s.Name
                ))
                .ToListAsync();

            return subjects;
        }



        //Add new subject
        public async Task<(bool Success, string Message, SubjectDto? Data)> AddSubjectAsync(SubjectRequestDto dto)
        {
            //Check if subject exists
            var existingSubject = await _context.Subjects
                .AnyAsync(s => s.Name.ToLower() == dto.Name.ToLower());

            if (existingSubject)
            {
                return (false, "Subject with this name alerdy exists", null);
            }
            var subject = new Subject
            {
                Name = dto.Name
            };

            await _context.Subjects.AddAsync(subject);
            await _context.SaveChangesAsync();

            var subjectDto = new SubjectDto
                (
                    subject.Id, 
                    subject.Name
                );

            return (true, "Dodano nowy przedmiot.", subjectDto);
        }



        //Update subject

        public async Task<(bool Success, string Message, SubjectDto? Data)> UpdateSubjectAsync(long id, SubjectRequestDto dto)
        {
            //Check if subject exists

            var subject = await _context.Subjects.FirstOrDefaultAsync(s => s.Id == id);

            if (subject == null)
            {
                return (false, "Subject does not exist.", null);
            }


            //Check if updated name conflicts with other subject

            var nameConflict = await _context.Subjects
                .AnyAsync
                    (
                        s => s.Id != id && 
                        s.Name.ToLower() == dto.Name.ToLower()
                    );


            if (nameConflict)
            {
                return (false, "Subject with this name alerdy exists", null);
            }

            subject.Name = dto.Name;
            await _context.SaveChangesAsync();

            var updatedSubjectDto = new SubjectDto
                (
                    subject.Id,
                    subject.Name
                );

            return (true, "Subject updated.", updatedSubjectDto);

        }



        //Delete subject
        public async Task<(bool Success, string Message)> DeleteSubjectAsync(long id)
        {
            //Check if subject exists and is used in notes
            var subject = await _context.Subjects
                .Include(s => s.Notes)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (subject == null)
            {
                return (false, "Subject does not exist.");
            }

            // If subject was used in notes
            if (subject.Notes.Any())
            {
                return (false, "This subject is used in notes. It cannot be removed.");
            }

            _context.Subjects.Remove(subject);
            await _context.SaveChangesAsync();

            return (true, "Subject deleted");
        }
    }
}
