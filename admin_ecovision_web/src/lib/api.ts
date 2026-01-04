import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1'

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Add auth token interceptor
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export const api = {
  // Dashboard
  getDashboardStats: () => apiClient.get('/admin/dashboard/stats'),

  // Reports
  getReports: (params?: {
    status?: string
    type?: string
    severity?: string
    limit?: number
    offset?: number
  }) => apiClient.get('/admin/reports', { params }),

  getReportDetail: (id: string) => apiClient.get(`/admin/reports/${id}`),

  updateReportStatus: (id: string, status: string, message?: string) =>
    apiClient.put(`/admin/reports/${id}/status`, null, {
      params: { new_status: status, message },
    }),

  deleteReport: (id: string) =>
    apiClient.delete(`/admin/reports/${id}`),

  // AQI
  getAQIStats: (days: number = 7) =>
    apiClient.get('/admin/aqi/stats', { params: { days } }),

  // Trend Forecast
  getTrendForecast: (historicalDays: number = 14, forecastDays: number = 7) =>
    apiClient.get('/admin/trend-forecast', { 
      params: { historical_days: historicalDays, forecast_days: forecastDays } 
    }),
}

