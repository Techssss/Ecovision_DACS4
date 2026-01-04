import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import { api } from '../lib/api'
import { MapPin, AlertCircle, Clock, CheckCircle, XCircle, Eye, ChevronRight, FileText, Activity } from 'lucide-react'
import { 
  BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer 
} from 'recharts'

// Stat Card Component
function StatCard({ icon: Icon, label, value, color }: any) {
  return (
    <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm text-gray-600 mb-1">{label}</p>
          <p className="text-3xl font-bold text-gray-900">{value}</p>
        </div>
        <div className={`p-3 rounded-lg ${color}`}>
          <Icon className="w-6 h-6 text-white" />
        </div>
      </div>
    </div>
  )
}

export default function Reports() {
  const navigate = useNavigate()
  const [filters, setFilters] = useState({
    status: '',
    type: '',
    severity: '',
  })
  const [page, setPage] = useState(0)
  const limit = 20

  const { data, isLoading } = useQuery({
    queryKey: ['reports', filters, page],
    queryFn: () =>
      api.getReports({
        ...filters,
        offset: page * limit,
        limit,
      }),
  })

  // Fetch dashboard stats for statistics
  const { data: statsData } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: () => api.getDashboardStats(),
  })

  const reports = data?.data?.data || []
  const total = data?.data?.total || 0
  const stats = statsData?.data?.data
  const reportsStats = stats?.reports || {}

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'pending':
        return <Clock className="w-4 h-4 text-yellow-500" />
      case 'reviewing':
        return <AlertCircle className="w-4 h-4 text-blue-500" />
      case 'resolved':
        return <CheckCircle className="w-4 h-4 text-green-500" />
      case 'rejected':
        return <XCircle className="w-4 h-4 text-red-500" />
      default:
        return null
    }
  }

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'critical':
        return 'bg-red-100 text-red-800'
      case 'high':
        return 'bg-orange-100 text-orange-800'
      case 'medium':
        return 'bg-yellow-100 text-yellow-800'
      case 'low':
        return 'bg-green-100 text-green-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  // Parse backend data for charts
  const byType = reportsStats.by_type || {}
  
  // Reports by type
  const reportsByType = [
    { name: 'Rác thải', value: byType.trash || 0, color: '#ef4444' },
    { name: 'Ô nhiễm không khí', value: byType.air_pollution || 0, color: '#f59e0b' },
    { name: 'Ô nhiễm nước', value: byType.water_pollution || 0, color: '#3b82f6' },
    { name: 'Tiếng ồn', value: byType.noise_pollution || 0, color: '#8b5cf6' },
    { name: 'Ô nhiễm đất', value: byType.soil_pollution || 0, color: '#84cc16' },
    { name: 'Công nghiệp', value: byType.industrial_pollution || 0, color: '#6b7280' },
  ].filter(item => item.value > 0)

  // Reports by status
  const reportsByStatus = [
    { name: 'Pending', value: reportsStats.pending || 0, color: '#eab308' },
    { name: 'Reviewing', value: reportsStats.reviewing || 0, color: '#3b82f6' },
    { name: 'Resolved', value: reportsStats.resolved || 0, color: '#22c55e' },
    { name: 'Rejected', value: (reportsStats.total || 0) - (reportsStats.pending || 0) - (reportsStats.reviewing || 0) - (reportsStats.resolved || 0), color: '#ef4444' },
  ].filter(item => item.value > 0)

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Reports Management</h1>
        <p className="text-gray-600 mt-1">Quản lý tất cả reports từ users</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          icon={FileText}
          label="Tổng Reports"
          value={reportsStats.total || 0}
          color="bg-blue-500"
        />
        <StatCard
          icon={Clock}
          label="Đang Chờ"
          value={reportsStats.pending || 0}
          color="bg-yellow-500"
        />
        <StatCard
          icon={CheckCircle}
          label="Đã Giải Quyết"
          value={reportsStats.resolved || 0}
          color="bg-green-500"
        />
        <StatCard
          icon={Activity}
          label="Đang Xem Xét"
          value={reportsStats.reviewing || 0}
          color="bg-purple-500"
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Reports by Type */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Activity className="w-5 h-5 text-blue-600" />
            Phân Loại Theo Loại Ô Nhiễm
          </h2>
          {reportsByType.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={reportsByType}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {reportsByType.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-[300px] flex items-center justify-center text-gray-500">
              Chưa có dữ liệu
            </div>
          )}
        </div>

        {/* Reports by Status */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <AlertCircle className="w-5 h-5 text-orange-600" />
            Phân Loại Theo Trạng Thái
          </h2>
          {reportsByStatus.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={reportsByStatus}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="value" fill="#3b82f6">
                  {reportsByStatus.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-[300px] flex items-center justify-center text-gray-500">
              Chưa có dữ liệu
            </div>
          )}
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Status
            </label>
            <select
              value={filters.status}
              onChange={(e) => setFilters({ ...filters, status: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500"
            >
              <option value="">Tất cả</option>
              <option value="pending">Pending</option>
              <option value="reviewing">Reviewing</option>
              <option value="resolved">Resolved</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Loại Ô Nhiễm
            </label>
            <select
              value={filters.type}
              onChange={(e) => setFilters({ ...filters, type: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500"
            >
              <option value="">Tất cả</option>
              <option value="air_pollution">Air Pollution</option>
              <option value="water_pollution">Water Pollution</option>
              <option value="trash">Trash</option>
              <option value="noise_pollution">Noise Pollution</option>
              <option value="soil_pollution">Soil Pollution</option>
              <option value="industrial_pollution">Industrial Pollution</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Độ Nghiêm Trọng
            </label>
            <select
              value={filters.severity}
              onChange={(e) => setFilters({ ...filters, severity: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500"
            >
              <option value="">Tất cả</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
          </div>
        </div>
      </div>

      {/* Reports List */}
      <div className="bg-white rounded-lg shadow">
        {isLoading ? (
          <div className="text-center py-12">Loading...</div>
        ) : reports.length === 0 ? (
          <div className="text-center py-12 text-gray-500">Không có reports nào</div>
        ) : (
          <div className="divide-y divide-gray-200">
            {reports.map((report: any) => (
              <div
                key={report.id}
                className="p-6 hover:bg-gray-50 transition-colors border-l-4 border-transparent hover:border-blue-500"
              >
                <div className="flex items-start justify-between gap-4">
                  <div 
                    className="flex-1 cursor-pointer"
                    onClick={() => navigate(`/reports/${report.id}`)}
                  >
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="text-lg font-semibold text-gray-900 capitalize">
                        {report.type.replace('_', ' ')}
                      </h3>
                      {getStatusIcon(report.status)}
                      <span
                        className={`px-2 py-1 text-xs font-medium rounded-full ${getSeverityColor(
                          report.severity
                        )}`}
                      >
                        {report.severity}
                      </span>
                    </div>
                    <p className="text-gray-600 mb-2 line-clamp-2">{report.description || 'Không có mô tả'}</p>
                    <div className="flex items-center gap-4 text-sm text-gray-500 mb-2">
                      <div className="flex items-center gap-1">
                        <MapPin className="w-4 h-4" />
                        <span>{report.address || 'N/A'}</span>
                      </div>
                      <span>Tracking: <span className="font-mono">{report.tracking_code}</span></span>
                      <span>
                        {new Date(report.created_at).toLocaleDateString('vi-VN', {
                          year: 'numeric',
                          month: 'short',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
                      </span>
                    </div>
                    {report.user && (
                      <div className="text-sm text-gray-500 mb-2">
                        <span className="font-medium">Người báo cáo:</span> {report.user.name || report.user.email}
                      </div>
                    )}
                    {report.images && report.images.length > 0 && (
                      <div className="mt-3 flex gap-2">
                        {report.images.slice(0, 3).map((img: any) => (
                          <img
                            key={img.id}
                            src={img.thumbnail_url || img.image_url}
                            alt="Report"
                            className="w-16 h-16 object-cover rounded border border-gray-200"
                          />
                        ))}
                        {report.images.length > 3 && (
                          <div className="w-16 h-16 bg-gray-200 rounded flex items-center justify-center text-sm text-gray-600 border border-gray-200">
                            +{report.images.length - 3}
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation()
                      navigate(`/reports/${report.id}`)
                    }}
                    className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors flex-shrink-0"
                  >
                    <Eye className="w-4 h-4" />
                    <span>Xem chi tiết</span>
                    <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Pagination */}
        {total > limit && (
          <div className="p-6 border-t border-gray-200 flex items-center justify-between">
            <p className="text-sm text-gray-600">
              Hiển thị {page * limit + 1} - {Math.min((page + 1) * limit, total)} / {total}
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setPage((p) => Math.max(0, p - 1))}
                disabled={page === 0}
                className="px-4 py-2 border border-gray-300 rounded-lg disabled:opacity-50"
              >
                Previous
              </button>
              <button
                onClick={() => setPage((p) => p + 1)}
                disabled={(page + 1) * limit >= total}
                className="px-4 py-2 border border-gray-300 rounded-lg disabled:opacity-50"
              >
                Next
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

