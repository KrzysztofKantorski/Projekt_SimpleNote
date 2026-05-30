using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Services.Interfaces;

namespace Projekt_SimpleNote.Services
{
    public class DictionaryService: IDictionaryService
    {
        //Dbcontext
        private readonly ApplicationDbContext _context;

        public DictionaryService(ApplicationDbContext context)
        {
            _context = context;
        }


        //Get tasks based on user search (limit to 20)
        public async Task<IEnumerable<string>> GetTagsAsync(string? search, int limit = 20)
        {
            var tags = _context.Tags.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var searchLower = search.Trim().ToLower();
                tags = tags
                    .Where(t => t.Name.ToLower()
                    .Contains(searchLower)
                    );
            }

            return await tags
                .OrderBy(t => t.Name)
                .Take(limit)
                .Select(t => t.Name)
                .ToListAsync();

        }


        //Get subjects based on user search (limit 20)
        public async Task<IEnumerable<string>> GetSubjectsAsync(string? search, int limit = 20)
        {
            var subjects = _context.Subjects.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var searchLower = search.Trim().ToLower();
                subjects = subjects
                    .Where(t => t.Name.ToLower()
                    .Contains(searchLower)
                    );
            }

            return await subjects
                .OrderBy(s => s.Name)
                .Take(limit)
                .Select(s => s.Name)
                .ToListAsync();
        }

    }
}
