import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getSubjects, createSubject, updateSubject, deleteSubject } from '../api/adminSubjects';
import type { SubjectRequestDto } from '../types/subjectTypes';

export const useSubjectsQuery = (pageNumber: number, pageSize: number) => {
  return useQuery({
    queryKey: ['subjects', pageNumber, pageSize],
    queryFn: () => getSubjects(pageNumber, pageSize)
  });
};

export const useDeleteSubject = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteSubject,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
    }
  });
};

export const useCreateSubject = (onSuccessCallback?: () => void) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createSubject,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
      if (onSuccessCallback) onSuccessCallback(); 
    }
  });
};

export const useUpdateSubject = (onSuccessCallback?: () => void) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: number, data: SubjectRequestDto }) => updateSubject(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
      if (onSuccessCallback) onSuccessCallback();
    }
  });
};