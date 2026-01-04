import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '../lib/api'
import { getClassNameVI, getClassIcon, getClassColor } from '../utils/classNames'
import { 
  MapPin, AlertCircle, CheckCircle, ArrowLeft, User, Mail, Calendar, 
  ChevronDown, ChevronUp, ZoomIn, Maximize2, Check, Shield, Target, Users
} from 'lucide-react'
import { MapContainer, TileLayer, Marker } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'

// Fix Leaflet icons
delete (L.Icon.Default.prototype as any)._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
})

// Priority Badge Component
function PriorityBadge({ severity }: { severity: string }) {
  const config = {
    critical: { bg: 'bg-red-50', text: 'text-red-700', border: 'border-red-200', icon: '🚨', label: 'Khẩn cấp', time: '24 giờ' },
    high: { bg: 'bg-orange-50', text: 'text-orange-700', border: 'border-orange-200', icon: '⚠️', label: 'Ưu tiên cao', time: '24-48 giờ' },
    medium: { bg: 'bg-amber-50', text: 'text-amber-700', border: 'border-amber-200', icon: '⚠️', label: 'Trung bình', time: '2-3 ngày' },
    low: { bg: 'bg-green-50', text: 'text-green-700', border: 'border-green-200', icon: '✓', label: 'Thấp', time: '1 tuần' },
  }[severity] || config.medium

  return (
    <div className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-lg border ${config.bg} ${config.text} ${config.border}`}>
      <span>{config.icon}</span>
      <span className="font-medium text-sm">{config.label}</span>
      <span className="text-xs opacity-75">• {config.time}</span>
    </div>
  )
}

// Collapsible Card Component
function CollapsibleCard({ 
  title, 
  icon: Icon, 
  children, 
  defaultOpen = true,
  badge 
}: { 
  title: string
  icon: any
  children: React.ReactNode
  defaultOpen?: boolean
  badge?: React.ReactNode
}) {
  const [isOpen, setIsOpen] = useState(defaultOpen)

  return (
    <div className="bg-white rounded-lg border border-gray-200 shadow-sm">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full px-5 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors"
      >
        <div className="flex items-center gap-3">
          <Icon className="w-5 h-5 text-gray-600" />
          <h3 className="font-semibold text-gray-900">{title}</h3>
          {badge}
        </div>
        {isOpen ? <ChevronUp className="w-5 h-5 text-gray-400" /> : <ChevronDown className="w-5 h-5 text-gray-400" />}
      </button>
      {isOpen && (
        <div className="px-5 pb-5 border-t border-gray-100">
          {children}
        </div>
      )}
    </div>
  )
}

// Main Component
export default function ReportDetailNew() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [imageZoom, setImageZoom] = useState(false)

  const { data, isLoading, error } = useQuery({
    queryKey: ['report', id],
    queryFn: () => api.getReportDetail(id!),
  })

  const updateStatusMutation = useMutation({
    mutationFn: ({ status }: { status: string }) => api.updateReportStatus(id!, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['report', id] })
      queryClient.invalidateQueries({ queryKey: ['reports'] })
    },
  })

  const deleteReportMutation = useMutation({
    mutationFn: () => api.deleteReport(id!),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['reports'] })
      navigate('/reports')
    },
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (error || !data?.data?.data) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen">
        <AlertCircle className="w-16 h-16 text-red-500 mb-4" />
        <p className="text-gray-600">Không tìm thấy report</p>
        <button onClick={() => navigate('/reports')} className="mt-4 text-blue-600 hover:underline">
          Quay lại danh sách
        </button>
      </div>
    )
  }

  const report = data.data.data
  const mainImage = report.images?.[0]
  const detections = mainImage?.yolo_detections || []
  const totalDetections = report.yolo_analysis?.total_detections || 0

  // Get AI recommendations
  const getRecommendations = () => {
    const base = {
      actions: [
        'Triển khai đội dọn dẹp khẩn cấp trong vòng 24-48 giờ',
        'Lắp đặt thùng rác công cộng tại khu vực này',
        'Tăng cường tuần tra và giám sát bằng camera AI',
        'Tổ chức chiến dịch nâng cao ý thức cộng đồng',
      ],
      preventive: [
        'Lắp camera giám sát khu vực',
        'Đặt biển cảnh báo phạt nặng',
        'Tổ chức tuyên truyền định kỳ',
      ],
      agencies: [
        { name: 'Phòng Quản lý Đô thị', role: 'Chủ trì', color: 'bg-blue-100 text-blue-700' },
        { name: 'Công ty Môi trường Đô thị', role: 'Thực hiện', color: 'bg-green-100 text-green-700' },
        { name: 'UBND Phường/Xã', role: 'Phối hợp', color: 'bg-purple-100 text-purple-700' },
      ],
    }
    return base
  }

  const recommendations = getRecommendations()

  const handleDelete = () => {
    if (window.confirm('Xóa report này? Không thể hoàn tác!')) {
      deleteReportMutation.mutate()
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-8">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-10 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <button
            onClick={() => navigate('/reports')}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-3"
          >
            <ArrowLeft className="w-4 h-4" />
            <span className="text-sm font-medium">Quay lại</span>
          </button>

          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
              <div className="flex items-center gap-3 mb-2">
                <h1 className="text-2xl font-bold text-gray-900">{report.tracking_code}</h1>
                <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                  report.status === 'pending' ? 'bg-yellow-100 text-yellow-700' :
                  report.status === 'reviewing' ? 'bg-blue-100 text-blue-700' :
                  report.status === 'resolved' ? 'bg-green-100 text-green-700' :
                  'bg-red-100 text-red-700'
                }`}>
                  {report.status}
                </span>
              </div>
              <div className="flex flex-wrap items-center gap-4 text-sm text-gray-600">
                <div className="flex items-center gap-1.5">
                  <User className="w-4 h-4" />
                  <span>{report.user?.name || 'N/A'}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Mail className="w-4 h-4" />
                  <span>{report.user?.email || 'N/A'}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Calendar className="w-4 h-4" />
                  <span>{new Date(report.created_at).toLocaleDateString('vi-VN')}</span>
                </div>
              </div>
            </div>
            <PriorityBadge severity={report.severity} />
          </div>

          <div className="mt-3 flex items-center gap-2 text-sm text-gray-600">
            <MapPin className="w-4 h-4" />
            <span>{report.address}</span>
            <span className="text-gray-400">•</span>
            <span className="text-xs text-gray-500">{report.latitude.toFixed(4)}, {report.longitude.toFixed(4)}</span>
          </div>
        </div>
      </div>

      {/* Main Content - 2 Column Layout */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-6">
        <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
          {/* Left Column - Image (Sticky) */}
          <div className="lg:col-span-3">
            <div className="lg:sticky lg:top-24">
              <div className="bg-white rounded-lg border border-gray-200 shadow-sm overflow-hidden">
                {mainImage ? (
                  <div className="relative group">
                    <img
                      src={mainImage.image_url}
                      alt="Report"
                      className="w-full h-auto"
                      id="report-image"
                    />
                    
                    {/* Bounding Boxes Overlay */}
                    {detections.length > 0 && (
                      <svg
                        className="absolute top-0 left-0 w-full h-full pointer-events-none"
                        viewBox="0 0 640 640"
                        preserveAspectRatio="none"
                      >
                        {detections.map((det: any, idx: number) => {
                          const [x1, y1, x2, y2] = det.bbox
                          const width = x2 - x1
                          const height = y2 - y1
                          
                          // Color based on class
                          const colors = {
                            'Graffiti': { stroke: '#9333ea', fill: '#9333ea20' },
                            'garbage': { stroke: '#ef4444', fill: '#ef444420' },
                            'sand on road': { stroke: '#f59e0b', fill: '#f59e0b20' },
                          }
                          const color = colors[det.class_name as keyof typeof colors] || { stroke: '#3b82f6', fill: '#3b82f620' }
                          
                          return (
                            <g key={idx}>
                              {/* Bounding box */}
                              <rect
                                x={x1}
                                y={y1}
                                width={width}
                                height={height}
                                fill={color.fill}
                                stroke={color.stroke}
                                strokeWidth="3"
                                rx="4"
                              />
                              {/* Label */}
                              <rect
                                x={x1}
                                y={y1 - 28}
                                width={Math.max(width, 120)}
                                height="26"
                                fill={color.stroke}
                                rx="4"
                              />
                              <text
                                x={x1 + 8}
                                y={y1 - 10}
                                fill="white"
                                fontSize="14"
                                fontWeight="600"
                                fontFamily="system-ui, -apple-system, sans-serif"
                              >
                                {getClassIcon(det.class_name)} {getClassNameVI(det.class_name)} {(det.confidence * 100).toFixed(0)}%
                              </text>
                            </g>
                          )
                        })}
                      </svg>
                    )}
                    
                    {totalDetections > 0 && (
                      <div className="absolute top-4 left-4 bg-black/75 text-white px-3 py-2 rounded-lg backdrop-blur-sm">
                        <div className="text-xs font-medium">AI Detection</div>
                        <div className="text-lg font-bold">{totalDetections} phát hiện</div>
                      </div>
                    )}
                    <div className="absolute top-4 right-4 flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button className="p-2 bg-black/75 text-white rounded-lg hover:bg-black/90">
                        <ZoomIn className="w-5 h-5" />
                      </button>
                      <button className="p-2 bg-black/75 text-white rounded-lg hover:bg-black/90">
                        <Maximize2 className="w-5 h-5" />
                      </button>
                    </div>
                  </div>
                ) : (
                  <div className="aspect-video bg-gray-100 flex items-center justify-center">
                    <span className="text-gray-400">Không có ảnh</span>
                  </div>
                )}

                {/* Detection Summary */}
                {detections.length > 0 && (
                  <div className="p-4 bg-gradient-to-r from-blue-50 to-purple-50 border-t border-gray-200">
                    <div className="flex flex-wrap gap-2">
                      {detections.map((det: any, idx: number) => (
                        <div
                          key={idx}
                          className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-medium ${getClassColor(det.class_name)}`}
                        >
                          <span>{getClassIcon(det.class_name)}</span>
                          <span>{getClassNameVI(det.class_name)}</span>
                          <span className="text-xs opacity-75">{(det.confidence * 100).toFixed(0)}%</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Map Preview */}
                <div className="h-48 border-t border-gray-200">
                  <MapContainer
                    center={[report.latitude, report.longitude]}
                    zoom={14}
                    style={{ height: '100%', width: '100%' }}
                    zoomControl={false}
                    dragging={false}
                    scrollWheelZoom={false}
                  >
                    <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                    <Marker position={[report.latitude, report.longitude]} />
                  </MapContainer>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column - Analysis & Actions */}
          <div className="lg:col-span-2 space-y-4">
            {/* AI Detection Card */}
            <CollapsibleCard
              title="AI Analysis - YOLOv8"
              icon={Target}
              defaultOpen={false}
              badge={
                totalDetections > 0 && (
                  <span className="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs font-medium rounded-full">
                    {totalDetections} detections
                  </span>
                )
              }
            >
              <div className="pt-4 space-y-3">
                {report.yolo_analysis?.detection_summary && Object.entries(report.yolo_analysis.detection_summary).map(([className, stats]: [string, any]) => (
                  <div key={className} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center gap-2">
                      <span className="text-xl">{getClassIcon(className)}</span>
                      <span className="font-medium text-gray-900">{getClassNameVI(className)}</span>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-semibold text-gray-900">x{stats.count}</div>
                      <div className="text-xs text-gray-500">{(stats.avg_confidence * 100).toFixed(0)}% confidence</div>
                    </div>
                  </div>
                ))}
              </div>
            </CollapsibleCard>

            {/* Description Card */}
            <CollapsibleCard title="Mô Tả" icon={AlertCircle}>
              <p className="pt-4 text-gray-700 leading-relaxed">
                {report.description || 'Không có mô tả'}
              </p>
            </CollapsibleCard>

            {/* Recommended Actions Card */}
            <CollapsibleCard title="Giải Pháp Đề Xuất" icon={CheckCircle}>
              <div className="pt-4 space-y-2">
                {recommendations.actions.map((action, idx) => (
                  <label key={idx} className="flex items-start gap-3 p-3 hover:bg-gray-50 rounded-lg cursor-pointer group">
                    <input type="checkbox" className="mt-0.5 w-4 h-4 text-blue-600 rounded border-gray-300" />
                    <span className="text-sm text-gray-700 group-hover:text-gray-900">{action}</span>
                  </label>
                ))}
              </div>
            </CollapsibleCard>

            {/* Preventive Measures */}
            <CollapsibleCard title="Biện Pháp Phòng Ngừa" icon={Shield} defaultOpen={false}>
              <div className="pt-4 space-y-2">
                {recommendations.preventive.map((measure, idx) => (
                  <label key={idx} className="flex items-start gap-3 p-3 hover:bg-gray-50 rounded-lg cursor-pointer group">
                    <input type="checkbox" className="mt-0.5 w-4 h-4 text-green-600 rounded border-gray-300" />
                    <span className="text-sm text-gray-700 group-hover:text-gray-900">{measure}</span>
                  </label>
                ))}
              </div>
            </CollapsibleCard>

            {/* Assigned Agencies */}
            <div className="bg-white rounded-lg border border-gray-200 shadow-sm p-5">
              <div className="flex items-center gap-3 mb-4">
                <Users className="w-5 h-5 text-gray-600" />
                <h3 className="font-semibold text-gray-900">Đơn Vị Chịu Trách Nhiệm</h3>
              </div>
              <div className="space-y-3">
                {recommendations.agencies.map((agency, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div>
                      <div className="font-medium text-gray-900">{agency.name}</div>
                      <div className="text-xs text-gray-500 mt-0.5">{agency.role}</div>
                    </div>
                    <span className={`px-2 py-1 rounded text-xs font-medium ${agency.color}`}>
                      {agency.role}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Status Actions */}
            <div className="bg-white rounded-lg border border-gray-200 shadow-sm p-5">
              <h3 className="font-semibold text-gray-900 mb-4">Cập Nhật Trạng Thái</h3>
              <div className="grid grid-cols-2 gap-2">
                <button
                  onClick={() => updateStatusMutation.mutate({ status: 'reviewing' })}
                  disabled={report.status === 'reviewing'}
                  className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 text-sm font-medium"
                >
                  Xem xét
                </button>
                <button
                  onClick={() => updateStatusMutation.mutate({ status: 'resolved' })}
                  disabled={report.status === 'resolved'}
                  className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 disabled:opacity-50 text-sm font-medium"
                >
                  Giải quyết
                </button>
              </div>
              <button
                onClick={handleDelete}
                className="w-full mt-3 px-4 py-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-100 border border-red-200 text-sm font-medium"
              >
                Xóa Report
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
