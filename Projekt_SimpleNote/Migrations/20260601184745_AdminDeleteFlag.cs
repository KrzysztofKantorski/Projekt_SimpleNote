using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Projekt_SimpleNote.Migrations
{
    /// <inheritdoc />
    public partial class AdminDeleteFlag : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsHiddenByAdmin",
                table: "Notes",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsHiddenByAdmin",
                table: "Comments",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsHiddenByAdmin",
                table: "Notes");

            migrationBuilder.DropColumn(
                name: "IsHiddenByAdmin",
                table: "Comments");
        }
    }
}
