namespace Projekt_SimpleNote.Dto.Pagination
{
    public record PagedResult<T>(
        IEnumerable<T> Items,
        int TotalCount,
        int CurrentPage,
        int PageSize)
    {
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
    }
}
