import React from 'react';
import Pagination from '@mui/material/Pagination';
import Stack from '@mui/material/Stack';
import type { PaginationOptions } from '../types/paginationOptionsTypes';

export const CustomPagination: React.FC<PaginationOptions> = ({
  totalPages,
  currentPage,
  onPageChange,
}) => {
  if (totalPages <= 1) return null;

  return (
    <Stack spacing={2} sx={{ alignItems: 'center', mt: 3, mb: 3 }}>
      <Pagination
        count={totalPages}
        page={currentPage}
        onChange={onPageChange}
        color="primary"
        showFirstButton
        showLastButton
      />
    </Stack>
  );
};