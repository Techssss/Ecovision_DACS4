import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { api } from '../lib/api'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar } from 'recharts'

export default function AQIStats() {
  const [days, setDays] = useState(7)

  const { data, isLoading } = useQuery({
    queryKey: ['aqi-stats', days],
    queryFn: () => api.getAQIStats(days),
  })

  if (isLoading) {
    return <div className="text-center py-12">Loading...</div>
  }

  const stats = data?.data

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">AQI Statistics</h1>
          <p className="text-gray-600 mt-1">Thống kê chất lượng không khí</p>
        </div>
        <select
          value={days}
          onChange={(e) => setDays(Number(e.target.value))}
          className="px-4 py-2 border border-gray-300 rounded-lg"
        >
          <option value={7}>7 ngày</option>
          <option value={14}>14 ngày</option>
          <option value={30}>30 ngày</option>
        </select>
      </div>

      {/* Overall Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <p className="text-sm text-gray-600">AQI Trung Bình</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">
            {stats?.overall?.average?.toFixed(1) || '0'}
          </p>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <p className="text-sm text-gray-600">AQI Cao Nhất</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">
            {stats?.overall?.max || '0'}
          </p>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <p className="text-sm text-gray-600">AQI Thấp Nhất</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">
            {stats?.overall?.min || '0'}
          </p>
        </div>
      </div>

      {/* Daily AQI Chart */}
      {stats?.daily && stats.daily.length > 0 && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">AQI Theo Ngày</h2>
          <ResponsiveContainer width="100%" height={400}>
            <LineChart data={stats.daily}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line
                type="monotone"
                dataKey="average"
                stroke="#22c55e"
                strokeWidth={2}
                name="Trung Bình"
              />
              <Line
                type="monotone"
                dataKey="max"
                stroke="#ef4444"
                strokeWidth={2}
                name="Cao Nhất"
              />
              <Line
                type="monotone"
                dataKey="min"
                stroke="#3b82f6"
                strokeWidth={2}
                name="Thấp Nhất"
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* Daily AQI Bar Chart */}
      {stats?.daily && stats.daily.length > 0 && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">AQI Range Theo Ngày</h2>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={stats.daily}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="max" fill="#ef4444" name="Cao Nhất" />
              <Bar dataKey="average" fill="#22c55e" name="Trung Bình" />
              <Bar dataKey="min" fill="#3b82f6" name="Thấp Nhất" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}
    </div>
  )
}

