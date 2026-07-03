import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { banUser, getAllUsers } from '../api/adminUsers';

// Hook do pobierania listy
export const useUsersQuery = (pageNumber: number, pageSize: number) => {
  return useQuery({
    queryKey: ['users', pageNumber, pageSize],
    queryFn: () => getAllUsers(pageNumber, pageSize),
  });
};

export const useBanUser = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: banUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    }
  });
};