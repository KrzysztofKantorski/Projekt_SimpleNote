export interface CommentDto {
  id: number;
  content: string;
  authorName: string; 
  createdAt: string;
  replies: CommentDto[]; 
}