using DotNetEnv;
using FluentValidation;
using Projekt_SimpleNote.Dto.Auth;
using Projekt_SimpleNote.Dto.Interactions;
using Projekt_SimpleNote.Dto.Notes;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Middleware;
using Projekt_SimpleNote.Services;
using Projekt_SimpleNote.Services.Interfaces;
using Projekt_SimpleNote.Validators;

Env.Load();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDatabaseConfiguration(builder.Configuration);


//Global exception handler
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();


builder.Services.AddCorsConfiguration();
builder.Services.AddControllers();
builder.Services.AddOpenApi();


//Validators
builder.Services.AddScoped<IValidator<RegisterDto>, RegisterDtoValidator>();
builder.Services.AddScoped<IValidator<LoginDto>, LoginDtoValidator>();
builder.Services.AddScoped<IValidator<CreateNoteDto>, CreateNoteDtoValidator>();
builder.Services.AddScoped<IValidator<UpdateNoteDto>, UpdateNoteDtoValidator>();
builder.Services.AddScoped<IValidator<CreateCommentDto>, CreateCommentDtoValidator>();


//Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<INotesService, NotesService>();
builder.Services.AddScoped<IDictionaryService, DictionaryService>();
builder.Services.AddScoped<ICommunityService, CommunityService>();
builder.Services.AddScoped<ISavedNotesService, SavedNotesService>();
builder.Services.AddScoped<ICommentsService, CommentsService>();
builder.Services.AddScoped<IReactionsService, ReactionsService>();



builder.Services.AddJwtConfiguration();

var app = builder.Build();

app.UseExceptionHandler();

app.UseHttpsRedirection();

app.UseCors("AdminPanelPolicy");

app.UseAuthentication();

app.UseAuthorization();

app.UseMiddleware<UserContextMiddleware>();

app.MapControllers();

app.Run();
