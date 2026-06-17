export interface LoginDto {
  username: string;
  password: string;
}

export interface LoginResponse {
  message: string;
  tokens: Tokens;
}

export interface UserProfileDto {
  id: number;
  username: string;
  role: string;
}


export interface Tokens {
  accessToken: string;
  refreshToken: string;
}