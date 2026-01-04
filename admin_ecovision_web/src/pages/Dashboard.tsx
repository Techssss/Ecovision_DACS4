import { useQuery } from '@tanstack/react-query'
import { api } from '../lib/api'
import { MapPin, AlertTriangle, Heart, Sparkles } from 'lucide-react'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts'

// Recommendations
const recommendations = [
  { icon: AlertTriangle, text: 'Nhóm nhạy cảm nên chế ra ngoài' },
  { icon: Heart, text: 'Sử dụng khẩu trang N95' },
  { icon: Sparkles, text: 'Hạn chế tập thể dục ngoài trời' },
]

// Helper function to get AQI status
const getAQIStatus = (aqi: number) => {
  if (aqi <= 50) return { status: 'Tốt', color: 'green' }
  if (aqi <= 100) return { status: 'Vừa phải', color: 'yellow' }
  if (aqi <= 150) return { status: 'Không tốt', color: 'orange' }
  if (aqi <= 200) return { status: 'Xấu', color: 'red' }
  return { status: 'Rất xấu', color: 'purple' }
}

export default function Dashboard() {
  // Fetch dashboard stats
  const { isLoading: statsLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: () => api.getDashboardStats(),
  })

  // Fetch AQI data for last 30 days
  const { data: aqiData, isLoading: aqiLoading } = useQuery({
    queryKey: ['aqi-stats', 30],
    queryFn: () => api.getAQIStats(30),
  })

  const isLoading = statsLoading || aqiLoading
  const aqiStats = aqiData?.data?.data

  // Process AQI chart data from API
  const aqiChartData = aqiStats?.daily?.slice(-6).map((day: any) => ({
    month: new Date(day.date).toLocaleDateString('en-US', { month: 'short' }),
    aqi: Math.round(day.average),
  })) || []

  // Mock district data (will be replaced with real data later)
  const districtAQI = [
    { 
      name: 'Hải Châu', 
      aqi: Math.round(aqiStats?.overall?.average || 44),
      ...getAQIStatus(Math.round(aqiStats?.overall?.average || 44))
    },
    { 
      name: 'Liên Chiểu', 
      aqi: Math.round((aqiStats?.overall?.max || 53) * 0.8),
      ...getAQIStatus(Math.round((aqiStats?.overall?.max || 53) * 0.8))
    },
    { 
      name: 'Thanh Khê', 
      aqi: Math.round((aqiStats?.overall?.min || 38) * 1.2),
      ...getAQIStatus(Math.round((aqiStats?.overall?.min || 38) * 1.2))
    },
  ]

  // Mock polluted districts (will be replaced with real data later)
  const pollutedDistricts = [
    { name: 'Liên Chiểu', district: 'Đà Nẵng', aqi: aqiStats?.overall?.max || 177 },
    { name: 'Cẩm Lệ', district: 'Đà Nẵng', aqi: Math.round((aqiStats?.overall?.max || 164) * 0.93) },
    { name: 'Sơn Trà', district: 'Đà Nẵng', aqi: Math.round((aqiStats?.overall?.max || 158) * 0.89) },
    { name: 'Ngũ Hành Sơn', district: 'Đà Nẵng', aqi: Math.round((aqiStats?.overall?.max || 156) * 0.88) },
  ]

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Đang tải dữ liệu...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-1">Tổng quan chất lượng không khí Đà Nẵng</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column - AQI Chart */}
        <div className="lg:col-span-2 space-y-6">
          {/* AQI Chart */}
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <div className="mb-4">
              <h2 className="text-lg font-semibold">Biểu Đồ AQI</h2>
              <p className="text-sm text-gray-600 mt-1">Chỉ số chất lượng không khí theo tháng</p>
            </div>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={aqiChartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="month" stroke="#9ca3af" />
                <YAxis stroke="#9ca3af" />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="aqi"
                  stroke="#3b82f6"
                  strokeWidth={3}
                  dot={{ fill: '#3b82f6', r: 5 }}
                  activeDot={{ r: 7 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* District AQI Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {districtAQI.map((district) => (
              <div
                key={district.name}
                className="bg-white rounded-lg p-6 shadow-sm border border-gray-200"
              >
                <div className="flex items-center justify-between mb-2">
                  <h3 className="text-sm font-medium text-gray-600">{district.name}</h3>
                  <span
                    className={`px-2 py-1 text-xs font-medium rounded ${
                      district.color === 'green'
                        ? 'bg-green-100 text-green-800'
                        : 'bg-yellow-100 text-yellow-800'
                    }`}
                  >
                    {district.status}
                  </span>
                </div>
                <p className="text-4xl font-bold text-gray-900">{district.aqi}</p>
                <p className="text-xs text-gray-500 mt-1">AQI Index</p>
              </div>
            ))}
          </div>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          {/* Most Polluted Districts */}
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <MapPin className="w-5 h-5 text-red-600" />
              Nơi Ô Nhiễm Nhất
            </h2>
            <div className="space-y-3">
              {pollutedDistricts.map((district, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                >
                  <div className="flex items-center gap-3">
                    <MapPin className="w-4 h-4 text-gray-400" />
                    <div>
                      <p className="font-medium text-gray-900">{district.name}</p>
                      <p className="text-xs text-gray-500">{district.district}</p>
                    </div>
                  </div>
                  <span className="text-lg font-bold text-red-600">{district.aqi}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Recommendations */}
          <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <h2 className="text-lg font-semibold mb-4">Khuyến Nghị</h2>
            <div className="space-y-3">
              {recommendations.map((rec, index) => (
                <div key={index} className="flex items-start gap-3">
                  <rec.icon className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                  <p className="text-sm text-gray-700">{rec.text}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
