using FluentValidation;
using Projekt_SimpleNote.Dto.Admin;

namespace Projekt_SimpleNote.Validators
{
    public class CreateReactionTypeDtoValidator : AbstractValidator<CreateReactionTypeDto>
    {
       
            public CreateReactionTypeDtoValidator()
            {
                RuleFor(x => x.Name)
                    .NotEmpty().WithMessage("Reaction name is required.")
                    .MaximumLength(30).WithMessage("Incorrect reaction name.")
                    .MinimumLength(3).WithMessage("Incorrect reaction name.");

                RuleFor(x => x.IconUrl)
                    .NotEmpty().WithMessage("Icon image path is required.")
                    .MaximumLength(255).WithMessage(".Incorrect image path.")
                    .MinimumLength(1).WithMessage("Incorrect image path.");
       }
        
    }
}
