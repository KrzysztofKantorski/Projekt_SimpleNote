using FluentValidation;
using Projekt_SimpleNote.Dto.Auth;

namespace Projekt_SimpleNote.Validators
{
    public class RegisterDtoValidator : AbstractValidator<RegisterDto>
    {
        public RegisterDtoValidator()
        {
            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("Username is required")
                .MinimumLength(3).WithMessage("Username must have at least 3 characters")
                .MaximumLength(50).WithMessage("Incorrect username");
            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required.")
                .MinimumLength(6).WithMessage("Password must have at least 6 characters.")
                .Matches("[A-Z]").WithMessage("Password must have at least 1 capital letter")
                .Matches("[0-9]").WithMessage("Password must have at least one number.")
                .Matches("[^a-zA-Z0-9]").WithMessage("Password must have at least one special character.");
        }
    }
}
