using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Pagination;

namespace Projekt_SimpleNote.Extensions
{
    public static class QueryablePaginationExtension
    {
        public static async Task<PagedResult<T>> ToPagedResultAsync<T>(this IQueryable<T> query, int pageNumber, int pageSize)
        {
            //Count the total number of items in the query
            var totalCount = await query.CountAsync();

            //Get the items for the current page
            var items = await query
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResult<T>(items, totalCount, pageNumber, pageSize);
        }
    }
}
