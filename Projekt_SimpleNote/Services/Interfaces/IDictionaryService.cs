namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IDictionaryService
    {
        //Get tags to display in list
        Task<IEnumerable<string>> GetTagsAsync(string? search, int limit = 20);

        //Get subjects
        Task<IEnumerable<string>> GetSubjectsAsync(string? search, int limit = 20);
    }
}
