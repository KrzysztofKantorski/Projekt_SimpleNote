using Projekt_SimpleNote.Dto.Admin;

namespace Projekt_SimpleNote.Services.Interfaces
{
    public interface IAdminSubjectsService
    {
        //Get all subjects
        Task<IEnumerable<SubjectDto>> GetAllSubjectsAsync();

        //Create new subject
        Task<(bool Success, string Message, SubjectDto? Data)> AddSubjectAsync(SubjectRequestDto dto);

        //Update existing subject
        Task<(bool Success, string Message, SubjectDto? Data)> UpdateSubjectAsync(long id, SubjectRequestDto dto);

        //Delete subject
        Task<(bool Success, string Message)> DeleteSubjectAsync(long id);
    }
}
