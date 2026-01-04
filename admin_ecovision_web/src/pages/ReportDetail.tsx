import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '../lib/api'
import { getClassNameVI, getClassIcon, getClassColor } from '../utils/classNames'
import { 
  MapPin, AlertCircle, CheckCircle, ArrowLeft, User, Calendar, 
  Lightbulb, Target, Users, Timer, Clock, Search, X, Layers,
  TrendingUp, Shield, FileText, ZoomIn, Image as ImageIcon
} from 'lucide-react'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'

// Fix default marker icon
delete (L.Icon.Default.prototype as any)._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
})

// Metadata Card Component
function MetadataCard({ icon: Icon, label, value, subValue, colorClass = 'text-blue-500' }: any) {
  return (
    <div className="bg-white rounded-lg p-4 border border-gray-200 hover:shadow-md transition-shadow">
      <div className="flex items-start gap-3">
        <div className={`${colorClass} mt-1`}>
          <Icon className="w-5 h-5" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-xs text-gray-500 uppercase tracking-wide mb-1">{label}</p>
          <p className="text-sm font-semibold text-gray-900 truncate">{value}</p>
          {subValue && <p className="text-xs text-gray-500 mt-1">{subValue}</p>}
        </div>
      </div>
    </div>
  )
}

// Image Viewer Component with Tabs
function ImageViewer({ images }: { images: any[] }) {
  const [selectedImage, setSelectedImage] = useState(0)
  const [viewMode, setViewMode] = useState<'original' | 'annotated'>('original')

  if (!images || images.length === 0) return null

  const currentImage = images[selectedImage]

  return (
    <div className="mb-6">
      <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
        <ImageIcon className="w-5 h-5" />
        Hình Ảnh ({images.length})
      </h2>
      
      {/* Image Tabs */}
      <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
        <div className="flex border-b border-gray-200 bg-gray-50">
          <button
            onClick={() => setViewMode('original')}
            className={`flex-1 px-4 py-3 text-sm font-medium transition-colors ${
              viewMode === 'original'
                ? 'bg-white text-blue-600 border-b-2 border-blue-600'
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            📷 Ảnh Gốc
          </button>
          <button
            onClick={() => setViewMode('annotated')}
            className={`flex-1 px-4 py-3 text-sm font-medium transition-colors ${
              viewMode === 'annotated'
                ? 'bg-white text-blue-600 border-b-2 border-blue-600'
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            🤖 Phân Tích AI
          </button>
        </div>

        {/* Main Image */}
        <div className="relative bg-gray-900">
          <img
            src={currentImage.image_url}
            alt="Report"
            className="w-full h-96 object-contain"
          />
          <button className="absolute top-4 right-4 p-2 bg-black/50 hover:bg-black/70 rounded-lg text-white transition-colors">
            <ZoomIn className="w-5 h-5" />
          </button>
        </div>

        {/* Image Info & Detections */}
        {viewMode === 'annotated' && currentImage.yolo_detections && currentImage.yolo_detections.length > 0 && (
          <div className="p-4 bg-gradient-to-r from-blue-50 to-purple-50 border-t border-gray-200">
            <h3 className="font-semibold mb-3 flex items-center gap-2">
              <Target className="w-4 h-4 text-blue-600" />
              YOLOv8 Detections
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
              {currentImage.yolo_detections.map((det: any, idx: number) => (
                <div
                  key={idx}
                  className={`flex items-center justify-between p-3 rounded-lg border ${getClassColor(det.class_name)}`}
                >
                  <span className="font-medium text-sm flex items-center gap-2">
                    <span>{getClassIcon(det.class_name)}</span>
                    <span>{getClassNameVI(det.class_name)}</span>
                  </span>
                  <span className="text-xs font-semibold">
                    {(det.confidence * 100).toFixed(1)}%
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Thumbnail Navigation */}
        {images.length > 1 && (
          <div className="p-4 bg-gray-50 border-t border-gray-200">
            <div className="flex gap-2 overflow-x-auto">
              {images.map((img, idx) => (
                <button
                  key={img.id}
                  onClick={() => setSelectedImage(idx)}
                  className={`flex-shrink-0 w-20 h-20 rounded-lg overflow-hidden border-2 transition-all ${
                    selectedImage === idx
                      ? 'border-blue-500 ring-2 ring-blue-200'
                      : 'border-gray-300 hover:border-gray-400'
                  }`}
                >
                  <img
                    src={img.thumbnail_url || img.image_url}
                    alt={`Thumbnail ${idx + 1}`}
                    className="w-full h-full object-cover"
                  />
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

// YOLO Analysis Card Component
function YOLOAnalysisCard({ analysis }: { analysis: any }) {
  if (!analysis || analysis.total_detections === 0) return null

  return (
    <div className="mb-6 bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 rounded-lg border border-blue-200 overflow-hidden">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 p-4">
        <div className="flex items-center justify-between text-white">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-white/20 rounded-lg">
              <Target className="w-5 h-5" />
            </div>
            <h2 className="text-lg font-bold">Phân Tích AI - YOLOv8</h2>
          </div>
          <div className="flex items-center gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold">{analysis.total_detections}</div>
              <div className="text-xs opacity-90">Phát hiện</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold">{analysis.detected_classes?.length || 0}</div>
              <div className="text-xs opacity-90">Loại</div>
            </div>
          </div>
        </div>
      </div>

      {/* Detection Summary */}
      {analysis.detection_summary && (
        <div className="p-4">
          <h3 className="font-semibold mb-3 flex items-center gap-2">
            <Layers className="w-4 h-4 text-indigo-600" />
            Chi Tiết Phát Hiện
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {Object.entries(analysis.detection_summary).map(([class_name, stats]: [string, any]) => (
              <div
                key={class_name}
                className={`p-4 rounded-lg border hover:shadow-md transition-shadow ${getClassColor(class_name)}`}
              >
                <div className="flex items-center justify-between mb-2">
                  <span className="font-semibold flex items-center gap-2">
                    <span className="text-2xl">{getClassIcon(class_name)}</span>
                    <span>{getClassNameVI(class_name)}</span>
                  </span>
                  <span className="px-2 py-1 bg-white/50 text-xs font-bold rounded-full">
                    x{stats.count}
                  </span>
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <TrendingUp className="w-4 h-4" />
                  <span>Độ tin cậy: {(stats.avg_confidence * 100).toFixed(1)}%</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

// AI Recommendations Component
function AIRecommendations({ report }: { report: any }) {
  const getRecommendations = () => {
    const recommendations = {
      solutions: [] as string[],
      authorities: [] as string[],
      priority: '',
      priorityLevel: 'medium' as 'low' | 'medium' | 'high' | 'critical',
      estimatedTime: '',
      preventiveMeasures: [] as string[],
    }

    switch (report.type) {
      case 'trash':
        recommendations.solutions = [
          'Triển khai đội dọn dẹp khẩn cấp trong vòng 24-48 giờ',
          'Lắp đặt thùng rác công cộng tại khu vực này',
          'Tăng cường tuần tra và giám sát bằng camera AI',
          'Tổ chức chiến dịch nâng cao ý thức cộng đồng',
        ]
        recommendations.authorities = ['Phòng Quản lý Đô thị', 'Công ty Môi trường Đô thị', 'UBND Phường/Xã']
        recommendations.priority = report.severity === 'critical' || report.severity === 'high' 
          ? 'Ưu tiên cao - Xử lý ngay' 
          : 'Ưu tiên trung bình - Xử lý trong 2-3 ngày'
        recommendations.priorityLevel = report.severity === 'critical' || report.severity === 'high' ? 'high' : 'medium'
        recommendations.estimatedTime = report.severity === 'critical' ? '24 giờ' : '2-3 ngày'
        recommendations.preventiveMeasures = [
          'Lắp camera giám sát khu vực',
          'Đặt biển cảnh báo phạt nặng',
          'Tổ chức tuyên truyền định kỳ',
        ]
        break

      case 'air_pollution':
        recommendations.solutions = [
          'Kiểm tra nguồn phát thải trong bán kính 500m',
          'Đo đạc chất lượng không khí chi tiết',
          'Yêu cầu cơ sở gây ô nhiễm lắp đặt hệ thống lọc khí',
          'Tạm dừng hoạt động nếu vượt ngưỡng cho phép',
        ]
        recommendations.authorities = ['Sở Tài nguyên & Môi trường', 'Thanh tra Môi trường', 'Trung tâm Quan trắc Môi trường']
        recommendations.priority = 'Ưu tiên cao - Ảnh hưởng sức khỏe cộng đồng'
        recommendations.priorityLevel = 'high'
        recommendations.estimatedTime = '1-2 tuần (điều tra + xử lý)'
        recommendations.preventiveMeasures = [
          'Giám sát liên tục chất lượng không khí',
          'Kiểm tra định kỳ các cơ sở sản xuất',
          'Yêu cầu báo cáo phát thải hàng tháng',
        ]
        break

      case 'water_pollution':
        recommendations.solutions = [
          'Lấy mẫu nước phân tích ngay lập tức',
          'Xác định nguồn xả thải bất hợp pháp',
          'Xử phạt và yêu cầu khắc phục vi phạm',
          'Triển khai biện pháp xử lý nước ô nhiễm',
        ]
        recommendations.authorities = ['Sở Tài nguyên & Môi trường', 'Chi cục Bảo vệ Môi trường', 'Công ty Cấp thoát nước']
        recommendations.priority = 'Ưu tiên rất cao - Nguy cơ dịch bệnh'
        recommendations.priorityLevel = 'critical'
        recommendations.estimatedTime = '3-5 ngày (khẩn cấp)'
        recommendations.preventiveMeasures = [
          'Lắp đặt hệ thống giám sát nước thải tự động',
          'Kiểm tra đột xuất các cơ sở xả thải',
          'Xây dựng hệ thống xử lý nước thải tập trung',
        ]
        break

      case 'noise_pollution':
        recommendations.solutions = [
          'Đo đạc mức độ tiếng ồn theo quy chuẩn',
          'Yêu cầu cơ sở vi phạm giảm thiểu tiếng ồn',
          'Lắp đặt vách cách âm nếu cần thiết',
          'Điều chỉnh giờ hoạt động phù hợp',
        ]
        recommendations.authorities = ['Phòng Quản lý Đô thị', 'Thanh tra Xây dựng', 'Công an Phường/Xã']
        recommendations.priority = 'Ưu tiên trung bình - Xử lý trong 1-2 tuần'
        recommendations.priorityLevel = 'medium'
        recommendations.estimatedTime = '1-2 tuần'
        recommendations.preventiveMeasures = [
          'Quy định giờ hoạt động rõ ràng',
          'Kiểm tra định kỳ các cơ sở gây ồn',
          'Tuyên truyền ý thức cộng đồng',
        ]
        break

      case 'industrial_pollution':
        recommendations.solutions = [
          'Thanh tra đột xuất cơ sở công nghiệp',
          'Kiểm tra giấy phép môi trường và hệ thống xử lý',
          'Lấy mẫu phân tích đa chỉ tiêu (nước, khí, đất)',
          'Xử phạt nghiêm và đình chỉ nếu vi phạm nghiêm trọng',
        ]
        recommendations.authorities = ['Sở Tài nguyên & Môi trường', 'Thanh tra Môi trường', 'Sở Công Thương', 'Công an Kinh tế']
        recommendations.priority = 'Ưu tiên rất cao - Vi phạm nghiêm trọng'
        recommendations.priorityLevel = 'critical'
        recommendations.estimatedTime = '1-3 tuần (điều tra toàn diện)'
        recommendations.preventiveMeasures = [
          'Giám sát 24/7 bằng camera và cảm biến',
          'Thanh tra định kỳ hàng tháng',
          'Yêu cầu báo cáo môi trường chi tiết',
        ]
        break

      default:
        recommendations.solutions = ['Cần đánh giá chi tiết tại hiện trường']
        recommendations.authorities = ['Sở Tài nguyên & Môi trường']
        recommendations.priority = 'Cần đánh giá'
        recommendations.priorityLevel = 'medium'
        recommendations.estimatedTime = 'Chưa xác định'
    }

    return recommendations
  }

  const rec = getRecommendations()

  const priorityColors = {
    low: 'from-green-500 to-emerald-600',
    medium: 'from-yellow-500 to-orange-600',
    high: 'from-orange-500 to-red-600',
    critical: 'from-red-600 to-rose-700',
  }

  return (
    <div className="mb-6">
      {/* Priority Banner */}
      <div className={`bg-gradient-to-r ${priorityColors[rec.priorityLevel]} text-white p-4 rounded-t-lg`}>
        <div className="flex items-center gap-3">
          <AlertCircle className="w-6 h-6" />
          <div>
            <div className="text-sm opacity-90">Mức Độ Ưu Tiên</div>
            <div className="text-xl font-bold">{rec.priority}</div>
          </div>
        </div>
      </div>

      <div className="bg-gradient-to-br from-purple-50 to-pink-50 border-x border-b border-purple-200 rounded-b-lg p-6">
        <div className="flex items-center gap-2 mb-6">
          <Lightbulb className="w-6 h-6 text-purple-600" />
          <h2 className="text-xl font-bold text-purple-900">Đề Xuất Giải Pháp AI</h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          {/* Timeline Card */}
          <div className="bg-white rounded-lg p-5 border border-purple-100 shadow-sm">
            <div className="flex items-center gap-3 mb-3">
              <div className="p-2 bg-blue-100 rounded-lg">
                <Timer className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <p className="text-xs text-gray-500 uppercase tracking-wide">Thời Gian Xử Lý</p>
                <p className="text-lg font-bold text-blue-600">{rec.estimatedTime}</p>
              </div>
            </div>
          </div>

          {/* Authorities Card */}
          <div className="bg-white rounded-lg p-5 border border-purple-100 shadow-sm">
            <div className="flex items-center gap-2 mb-3">
              <div className="p-2 bg-green-100 rounded-lg">
                <Users className="w-5 h-5 text-green-600" />
              </div>
              <h3 className="font-semibold text-gray-900">Đơn Vị Liên Quan</h3>
            </div>
            <ul className="space-y-2">
              {rec.authorities.map((auth, idx) => (
                <li key={idx} className="flex items-center gap-2 text-sm text-gray-700">
                  <div className="w-1.5 h-1.5 bg-green-500 rounded-full"></div>
                  <span>{auth}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Solutions */}
        <div className="bg-white rounded-lg p-5 border border-purple-100 shadow-sm mb-4">
          <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <div className="p-1.5 bg-purple-100 rounded">
              <Target className="w-4 h-4 text-purple-600" />
            </div>
            Giải Pháp Đề Xuất
          </h3>
          <ol className="space-y-3">
            {rec.solutions.map((solution, idx) => (
              <li key={idx} className="flex gap-3 text-gray-700">
                <span className="flex-shrink-0 w-6 h-6 bg-purple-600 text-white rounded-full flex items-center justify-center text-sm font-bold">
                  {idx + 1}
                </span>
                <span className="pt-0.5">{solution}</span>
              </li>
            ))}
          </ol>
        </div>

        {/* Preventive Measures */}
        {rec.preventiveMeasures.length > 0 && (
          <div className="bg-white rounded-lg p-5 border border-purple-100 shadow-sm">
            <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <div className="p-1.5 bg-green-100 rounded">
                <Shield className="w-4 h-4 text-green-600" />
              </div>
              Biện Pháp Phòng Ngừa
            </h3>
            <ul className="space-y-3">
              {rec.preventiveMeasures.map((measure, idx) => (
                <li key={idx} className="flex items-start gap-3 text-gray-700">
                  <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                  <span>{measure}</span>
                </li>
              ))}
            </ul>
          </div>
        )}

        <div className="mt-4 p-4 bg-amber-50 border border-amber-200 rounded-lg">
          <p className="text-sm text-amber-900 flex items-start gap-2">
            <Lightbulb className="w-4 h-4 flex-shrink-0 mt-0.5" />
            <span>
              <strong>Lưu ý:</strong> Đây là đề xuất tự động dựa trên AI và dữ liệu YOLOv8. 
              Cần khảo sát thực tế để có phương án xử lý chính xác nhất.
            </span>
          </p>
        </div>
      </div>
    </div>
  )
}

// Status Workflow Component
function StatusWorkflow({ report, onStatusChange, onDelete }: { report: any; onStatusChange: (status: string) => void; onDelete: () => void }) {
  const getStatusInfo = (status: string) => {
    switch (status) {
      case 'pending':
        return { icon: Clock, label: 'Đang chờ xử lý', color: 'yellow', bgColor: 'bg-yellow-100', textColor: 'text-yellow-800', borderColor: 'border-yellow-300' }
      case 'reviewing':
        return { icon: Search, label: 'Đang xem xét', color: 'blue', bgColor: 'bg-blue-100', textColor: 'text-blue-800', borderColor: 'border-blue-300' }
      case 'resolved':
        return { icon: CheckCircle, label: 'Đã giải quyết', color: 'green', bgColor: 'bg-green-100', textColor: 'text-green-800', borderColor: 'border-green-300' }
      case 'rejected':
        return { icon: X, label: 'Từ chối', color: 'red', bgColor: 'bg-red-100', textColor: 'text-red-800', borderColor: 'border-red-300' }
      default:
        return { icon: AlertCircle, label: status, color: 'gray', bgColor: 'bg-gray-100', textColor: 'text-gray-800', borderColor: 'border-gray-300' }
    }
  }

  const currentStatus = getStatusInfo(report.status)
  const CurrentIcon = currentStatus.icon

  return (
    <div className="border-t border-gray-200 pt-6">
      <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
        <FileText className="w-5 h-5" />
        Quản Lý Trạng Thái
      </h2>

      {/* Current Status */}
      <div className="mb-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
        <p className="text-sm text-gray-600 mb-2">Trạng thái hiện tại:</p>
        <div className={`inline-flex items-center gap-2 px-4 py-2 rounded-lg border ${currentStatus.bgColor} ${currentStatus.textColor} ${currentStatus.borderColor}`}>
          <CurrentIcon className="w-5 h-5" />
          <span className="font-semibold">{currentStatus.label}</span>
        </div>
      </div>

      {/* Status Actions */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        <button
          onClick={() => onStatusChange('reviewing')}
          disabled={report.status === 'reviewing'}
          className="flex items-center justify-center gap-2 px-4 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all font-medium"
        >
          <Search className="w-5 h-5" />
          <span>Đang Xem Xét</span>
        </button>
        <button
          onClick={() => onStatusChange('resolved')}
          disabled={report.status === 'resolved'}
          className="flex items-center justify-center gap-2 px-4 py-3 bg-green-500 text-white rounded-lg hover:bg-green-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all font-medium"
        >
          <CheckCircle className="w-5 h-5" />
          <span>Đã Giải Quyết</span>
        </button>
        <button
          onClick={() => onStatusChange('rejected')}
          disabled={report.status === 'rejected'}
          className="flex items-center justify-center gap-2 px-4 py-3 bg-red-500 text-white rounded-lg hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all font-medium"
        >
          <X className="w-5 h-5" />
          <span>Từ Chối</span>
        </button>
      </div>

      {/* Delete Button */}
      <div className="mt-6 pt-6 border-t border-gray-200">
        <button
          onClick={onDelete}
          className="flex items-center justify-center gap-2 px-4 py-3 bg-gray-100 text-red-600 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all font-medium border-2 border-red-200 hover:border-red-300 w-full"
        >
          <X className="w-5 h-5" />
          <span>Xóa Report</span>
        </button>
      </div>

      {/* Timeline */}
      <div className="mt-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
        <h3 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
          <Clock className="w-4 h-4" />
          Lịch Sử
        </h3>
        <div className="space-y-3">
          <div className="flex items-start gap-3">
            <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
            <div className="flex-1">
              <p className="text-sm text-gray-900">
                <span className="font-medium">Report được gửi</span> bởi {report.user?.name || 'User'}
              </p>
              <p className="text-xs text-gray-500 mt-1">
                {new Date(report.created_at).toLocaleString('vi-VN', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit'
                })}
              </p>
            </div>
          </div>
          {report.updated_at && report.updated_at !== report.created_at && (
            <div className="flex items-start gap-3">
              <div className="w-2 h-2 bg-green-500 rounded-full mt-2"></div>
              <div className="flex-1">
                <p className="text-sm text-gray-900">
                  <span className="font-medium">Cập nhật lần cuối</span>
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  {new Date(report.updated_at).toLocaleString('vi-VN', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                  })}
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// Main Component
export default function ReportDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const { data, isLoading, error } = useQuery({
    queryKey: ['report', id],
    queryFn: () => api.getReportDetail(id!),
  })

  const updateStatusMutation = useMutation({
    mutationFn: ({ status, message }: { status: string; message?: string }) =>
      api.updateReportStatus(id!, status, message),
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

  const handleDelete = () => {
    if (window.confirm('Bạn có chắc chắn muốn xóa report này? Hành động này không thể hoàn tác!')) {
      deleteReportMutation.mutate()
    }
  }

  if (isLoading) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <div className="relative">
          <div className="w-16 h-16 border-4 border-blue-200 rounded-full"></div>
          <div className="w-16 h-16 border-4 border-blue-600 rounded-full animate-spin border-t-transparent absolute top-0 left-0"></div>
        </div>
        <p className="mt-6 text-gray-600 font-medium">Đang tải chi tiết report...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <div className="inline-flex items-center justify-center w-16 h-16 bg-red-100 rounded-full mb-4">
          <AlertCircle className="w-8 h-8 text-red-500" />
        </div>
        <h3 className="text-xl font-semibold text-gray-900 mb-2">Lỗi khi tải report</h3>
        <p className="text-gray-600 mb-6">{(error as any)?.message || 'Không thể kết nối tới server'}</p>
        <button
          onClick={() => navigate('/reports')}
          className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 font-medium transition-colors"
        >
          Quay lại danh sách
        </button>
      </div>
    )
  }

  const report = data?.data?.data

  if (!report) {
    return (
      <div className="text-center py-12">
        <div className="inline-flex items-center justify-center w-16 h-16 bg-gray-100 rounded-full mb-4">
          <AlertCircle className="w-8 h-8 text-gray-400" />
        </div>
        <h3 className="text-xl font-semibold text-gray-900 mb-2">Report không tồn tại</h3>
        <button
          onClick={() => navigate('/reports')}
          className="mt-4 px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 font-medium transition-colors"
        >
          Quay lại danh sách
        </button>
      </div>
    )
  }

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'critical':
        return 'bg-red-500 text-white'
      case 'high':
        return 'bg-orange-500 text-white'
      case 'medium':
        return 'bg-yellow-500 text-white'
      case 'low':
        return 'bg-green-500 text-white'
      default:
        return 'bg-gray-500 text-white'
    }
  }

  const getRelativeTime = (date: string) => {
    const now = new Date()
    const past = new Date(date)
    const diffInSeconds = Math.floor((now.getTime() - past.getTime()) / 1000)
    
    if (diffInSeconds < 60) return 'Vừa xong'
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)} phút trước`
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)} giờ trước`
    return `${Math.floor(diffInSeconds / 86400)} ngày trước`
  }

  return (
    <div className="space-y-6 pb-8">
      {/* Back Button */}
      <button
        onClick={() => navigate('/reports')}
        className="flex items-center gap-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
      >
        <ArrowLeft className="w-5 h-5" />
        <span>Quay lại danh sách</span>
      </button>

      {/* Header Card */}
      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="bg-gradient-to-r from-blue-600 to-purple-600 p-6 text-white">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <h1 className="text-3xl font-bold mb-2 capitalize">
                {report.type.replace(/_/g, ' ')}
              </h1>
              <div className="flex items-center gap-3 text-blue-100">
                <span className="font-mono text-sm bg-white/20 px-3 py-1 rounded">
                  {report.tracking_code}
                </span>
                <span className="text-sm">{getRelativeTime(report.created_at)}</span>
              </div>
            </div>
            <div className={`px-4 py-2 rounded-lg font-bold text-sm ${getSeverityColor(report.severity)}`}>
              {report.severity.toUpperCase()}
            </div>
          </div>
        </div>

        {/* Metadata Grid */}
        <div className="p-6 bg-gray-50">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <MetadataCard
              icon={User}
              label="Người Báo Cáo"
              value={report.user?.name || 'N/A'}
              subValue={report.user?.email}
              colorClass="text-blue-500"
            />
            <MetadataCard
              icon={Calendar}
              label="Thời Gian"
              value={new Date(report.created_at).toLocaleDateString('vi-VN')}
              subValue={new Date(report.created_at).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}
              colorClass="text-purple-500"
            />
            <MetadataCard
              icon={MapPin}
              label="Vị Trí"
              value={report.address?.split(',')[0] || 'N/A'}
              subValue={`${report.latitude.toFixed(4)}, ${report.longitude.toFixed(4)}`}
              colorClass="text-green-500"
            />
            <MetadataCard
              icon={AlertCircle}
              label="Trạng Thái"
              value={report.status === 'pending' ? 'Chờ xử lý' : report.status === 'reviewing' ? 'Đang xem xét' : report.status === 'resolved' ? 'Đã giải quyết' : 'Từ chối'}
              subValue={`Cập nhật: ${getRelativeTime(report.updated_at || report.created_at)}`}
              colorClass={
                report.status === 'pending' ? 'text-yellow-500' :
                report.status === 'reviewing' ? 'text-blue-500' :
                report.status === 'resolved' ? 'text-green-500' : 'text-red-500'
              }
            />
          </div>
        </div>

        {/* Description */}
        <div className="p-6 border-t border-gray-200">
          <h2 className="text-lg font-semibold mb-3 flex items-center gap-2">
            <FileText className="w-5 h-5 text-gray-600" />
            Mô Tả Chi Tiết
          </h2>
          <p className="text-gray-700 leading-relaxed">{report.description || 'Không có mô tả'}</p>
        </div>

        {/* Map */}
        <div className="p-6 border-t border-gray-200">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <MapPin className="w-5 h-5 text-gray-600" />
            Vị Trí Trên Bản Đồ
          </h2>
          <div className="h-80 rounded-lg overflow-hidden border-2 border-gray-200 shadow-inner">
            <MapContainer
              center={[report.latitude, report.longitude]}
              zoom={15}
              style={{ height: '100%', width: '100%' }}
            >
              <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
              />
              <Marker position={[report.latitude, report.longitude]}>
                <Popup>
                  <div className="text-sm">
                    <p className="font-semibold">{report.type.replace(/_/g, ' ')}</p>
                    <p className="text-gray-600">{report.address}</p>
                  </div>
                </Popup>
              </Marker>
            </MapContainer>
          </div>
        </div>
      </div>

      {/* Images */}
      <ImageViewer images={report.images || []} />

      {/* YOLO Analysis */}
      <YOLOAnalysisCard analysis={report.yolo_analysis} />

      {/* AI Recommendations */}
      <AIRecommendations report={report} />

      {/* Status Management */}
      <div className="bg-white rounded-lg shadow-lg p-6">
        <StatusWorkflow
          report={report}
          onStatusChange={(status) => updateStatusMutation.mutate({ status })}
          onDelete={handleDelete}
        />
      </div>
    </div>
  )
}
