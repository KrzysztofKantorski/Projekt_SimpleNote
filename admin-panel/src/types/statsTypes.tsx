
export interface DashboardStatsDto {
  users: {
    active: number;
    banned: number;
  };
  notesOverTime: {
    date: string; 
    count: number;
  }[];
  subjectsDistribution: {
    subjectName: string;
    count: number;
  }[];
}