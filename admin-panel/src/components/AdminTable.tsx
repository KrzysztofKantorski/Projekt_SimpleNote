import { Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow } from '@mui/material';

interface AdminTableProps {
  headers: string[];
  children: React.ReactNode;
}

export const AdminTable = ({ headers, children }: AdminTableProps) => {
  return (
    <TableContainer component={Paper} elevation={2} sx={{ borderRadius: 2 }}>
      <Table>
        <TableHead sx={{ bgcolor: 'text.primary' }}>
          <TableRow>
            {headers.map((header, index) => (
              <TableCell 
                key={index} 
                sx={{ 
                  color: 'background.paper',
                  fontWeight: 'bold',
                  textAlign: index === headers.length - 1 ? 'right' : 'left' 
                }}
              >
                {header}
              </TableCell>
            ))}
          </TableRow>
        </TableHead>
        <TableBody>
          {children}
        </TableBody>
      </Table>
    </TableContainer>
  );
};