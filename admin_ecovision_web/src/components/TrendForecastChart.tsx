import { useQuery } from '@tanstack/react-query'
import { api } from '../lib/api'
import { 
  Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, 
  ResponsiveContainer, Area, ComposedChart 
} from 'recharts'
import { TrendingUp, TrendingDown, AlertCircle, Lightbulb, RefreshCw } from 'lucide-react'

interface TrendForecastChartProps {
  historicalDays?: number
  forecastDays?: number
}

export default function TrendForecastChart({ 
  historicalDays = 14, 
  forecastDays = 7 
}: TrendForecastChartProps) {
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['trend-forecast', historicalDays, forecastDays],
    queryFn: async () => {
      const response = await api.getTrendForecast(historicalDays, forecastDays)
      return response.data.data
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
  })

  if (isLoading) {
    return (
      <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
        <div className="flex items-center justify-center py-12">
          <div className="text-center">
            <div className="w-12 h-12 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto mb-4"></div>
            <p className="text-gray-600">Đang tạo dự báo...</p>
          </div>
        </div>
      </div>
    )
  }

  if (error || !data) {
    return (
      <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
        <div className="flex items-center justify-center py-12">
          <div className="text-center">
            <AlertCircle className="w-12 h-12 text-red-500 mx-auto mb-4" />
            <p className="text-red-600 font-medium">Lỗi khi tạo dự báo</p>
            <button
              onClick={() => refetch()}
              className="mt-4 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
            >
              Thử lại
            </button>
          </div>
        </div>
      </div>
    )
  }

  const { historical, forecast, trend, insights } = data

  // Combine data for chart
  const chartData = [
    ...historical.map((item: any) => ({
      date: new Date(item.date).toLocaleDateString('vi-VN', { month: 'short', day: 'numeric' }),
      fullDate: item.date,
      actual: item.actual,
      predicted: null,
      lower: item.lower,
      upper: item.upper,
      type: 'historical'
    })),
    ...forecast.map((item: any) => ({
      date: new Date(item.date).toLocaleDateString('vi-VN', { month: 'short', day: 'numeric' }),
      fullDate: item.date,
      actual: null,
      predicted: item.predicted,
      lower: item.lower,
      upper: item.upper,
      type: 'forecast'
    }))
  ]

  const getTrendIcon = () => {
    if (trend.direction === 'increase') {
      return <TrendingUp className="w-6 h-6 text-orange-500" />
    }
    return <TrendingDown className="w-6 h-6 text-green-500" />
  }

  const getTrendColor = () => {
    if (Math.abs(trend.change_percent) < 5) return 'text-gray-600'
    return trend.direction === 'increase' ? 'text-orange-600' : 'text-green-600'
  }

  const getSeverityColor = () => {
    switch (insights.severity) {
      case 'significant':
        return 'bg-red-50 border-red-200'
      case 'moderate':
        return 'bg-yellow-50 border-yellow-200'
      default:
        return 'bg-blue-50 border-blue-200'
    }
  }

  return (
    <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-blue-600" />
            Xu Hướng & Dự Báo
          </h2>
          <p className="text-sm text-gray-500 mt-1">
            {historical.length} ngày qua • {forecast.length} ngày tới
          </p>
        </div>
        <button
          onClick={() => refetch()}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          title="Làm mới dự báo"
        >
          <RefreshCw className="w-5 h-5 text-gray-600" />
        </button>
      </div>

      {/* Trend Summary */}
      <div className="mb-6 p-4 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg border border-blue-200">
        <div className="flex items-start gap-4">
          <div className="flex-shrink-0 mt-1">
            {getTrendIcon()}
          </div>
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-2">
              <span className="text-2xl">{insights.icon}</span>
              <h3 className={`text-xl font-bold ${getTrendColor()}`}>
                {trend.direction === 'increase' ? '+' : ''}{trend.change_percent}%
              </h3>
              <span className="text-sm text-gray-600 capitalize">
                ({insights.severity})
              </span>
            </div>
            <p className="text-gray-700 font-medium">{insights.summary}</p>
            <div className="mt-2 flex items-center gap-4 text-sm text-gray-600">
              <span>Tuần trước: <strong>{trend.last_week_avg}</strong> reports/ngày</span>
              <span>•</span>
              <span>Tuần tới: <strong>{trend.next_week_avg}</strong> reports/ngày</span>
            </div>
          </div>
        </div>
      </div>

      {/* Chart */}
      <div className="mb-6">
        <ResponsiveContainer width="100%" height={350}>
          <ComposedChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
            <XAxis 
              dataKey="date" 
              tick={{ fontSize: 12 }}
              stroke="#9ca3af"
            />
            <YAxis 
              tick={{ fontSize: 12 }}
              stroke="#9ca3af"
              label={{ value: 'Số lượng reports', angle: -90, position: 'insideLeft', style: { fontSize: 12 } }}
            />
            <Tooltip 
              contentStyle={{ 
                backgroundColor: 'white', 
                border: '1px solid #e5e7eb',
                borderRadius: '8px',
                boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
              }}
              formatter={(value: any, name: string) => {
                if (name === 'actual') return [value, 'Thực tế']
                if (name === 'predicted') return [value, 'Dự báo']
                if (name === 'lower') return [value, 'Dưới']
                if (name === 'upper') return [value, 'Trên']
                return [value, name]
              }}
            />
            <Legend 
              wrapperStyle={{ fontSize: '14px' }}
              formatter={(value) => {
                if (value === 'actual') return 'Dữ liệu thực tế'
                if (value === 'predicted') return 'Dự báo'
                if (value === 'lower') return 'Khoảng tin cậy'
                return value
              }}
            />
            
            {/* Confidence interval */}
            <Area
              type="monotone"
              dataKey="upper"
              stroke="none"
              fill="#93c5fd"
              fillOpacity={0.2}
            />
            <Area
              type="monotone"
              dataKey="lower"
              stroke="none"
              fill="#93c5fd"
              fillOpacity={0.2}
            />
            
            {/* Historical line */}
            <Line
              type="monotone"
              dataKey="actual"
              stroke="#3b82f6"
              strokeWidth={3}
              dot={{ fill: '#3b82f6', r: 4 }}
              activeDot={{ r: 6 }}
              connectNulls={false}
            />
            
            {/* Forecast line */}
            <Line
              type="monotone"
              dataKey="predicted"
              stroke="#f97316"
              strokeWidth={3}
              strokeDasharray="5 5"
              dot={{ fill: '#f97316', r: 4 }}
              activeDot={{ r: 6 }}
              connectNulls={false}
            />
          </ComposedChart>
        </ResponsiveContainer>
      </div>

      {/* Insights & Recommendations */}
      <div className={`p-4 rounded-lg border ${getSeverityColor()}`}>
        <div className="flex items-start gap-3">
          <Lightbulb className="w-5 h-5 text-yellow-600 flex-shrink-0 mt-0.5" />
          <div className="flex-1">
            <h4 className="font-semibold text-gray-900 mb-3">Đề Xuất Hành Động</h4>
            <ul className="space-y-2">
              {insights.recommendations.map((rec: string, idx: number) => (
                <li key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                  <span className="text-blue-500 font-bold flex-shrink-0">•</span>
                  <span>{rec}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      {/* Model Info */}
      <div className="mt-4 text-xs text-gray-500 text-center">
        Model: {data.model === 'prophet' ? 'Prophet (AI)' : 'Linear Regression'} • 
        Cập nhật: {new Date().toLocaleString('vi-VN')}
      </div>
    </div>
  )
}
