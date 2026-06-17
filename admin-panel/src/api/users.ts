import { api } from './axiosConfig';
import type {UserProfileDto } from "../types/authTypes";

//Get user info
export const getMe = async (): Promise<UserProfileDto> => {
  const response = await api.get<UserProfileDto>('/users/me');
  return response.data;
};