using FluentValidation;
using Projekt_SimpleNote.Dto.Pagination;

namespace Projekt_SimpleNote.Validators
{
    public class PaginationParamsValidator: AbstractValidator<PaginationParamsDto>
    {
        public PaginationParamsValidator() {
            RuleFor(x => x.PageNumber)
                .GreaterThanOrEqualTo(1)
                    .WithMessage("Page number must be greater than or equal to 1.");

            RuleFor(x => x.PageSize)
                .InclusiveBetween(1, 20)
                    .WithMessage("Page size must be between 1 and 20.");
        }
    }
}
