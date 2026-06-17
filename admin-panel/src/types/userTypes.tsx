export interface UserSummaryDto {
  id: number; 
  username: string;
  isActive: boolean;
  createdAt: string; 
}


export interface UserDetailsAdminDto {
  id: number;
  username: string;
  isActive: boolean;
  createdAt: string;
  totalNotes: number;
  totalComments: number;
  totalReactions: number;
}


export interface UserDetailsResponse {
  message: string;
  data: UserDetailsAdminDto;
}