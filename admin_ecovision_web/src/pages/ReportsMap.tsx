import { useQuery } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import { api } from '../lib/api'
import { MapPin, Navigation, Filter, RefreshCw } from 'lucide-react'
import { MapContainer, TileLayer, Marker, Popup, Circle } from 'react-leaflet'
import { useState, useEffect } from 'react'
import L from 'leaflet'

// Import Leaflet CSS
import 'leaflet/dist/leaflet.css'

// Fix Leaflet default marker icon issue
const fixLeafletIcons = () => {
  // @ts-ignore
  delete L.Icon.Default.prototype._getIconUrl
  
  L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  })
}

// Custom marker icons for different severities
const createCustomIcon = (severity: string) => {
  const colors: Record<string, string> = {
    critical: '#ef4444',
    high: '#f97316',
    medium: '#eab308',
    low: '#22c55e',
  }
  
  return L.divIcon({
    className: 'custom-marker',
    html: `
      <div style="
        background-color: ${colors[severity] || '#6b7280'};
        width: 36px;
        height: 36px;
        border-radius: 50% 50% 50% 0;
        transform: rotate(-45deg);
        border: 3px solid white;
        box-shadow: 0 3px 10px rgba(0,0,0,0.4);
        display: flex;
        align-items: center;
        justify-content: center;
      ">
        <div style="
          transform: rotate(45deg);
          color: white;
          font-size: 18px;
          font-weight: bold;
        ">!</div>
      </div>
    `,
    iconSize: [36, 36],
    iconAnchor: [18, 36],
    popupAnchor: [0, -36],
  })
}

export default function ReportsMap() {
  const navigate = useNavigate()
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [severityFilter, setSeverityFilter] = useState<string>('all')
  const [mapType, setMapType] = useState<'street' | 'satellite'>('street')

  // Fix Leaflet icons on mount
  useEffect(() => {
    fixLeafletIcons()
  }, [])

  // Fetch reports for map
  const { data: reportsData, isLoading, error, refetch } = useQuery({
    queryKey: ['reports-map', statusFilter, severityFilter],
    queryFn: async () => {
      const filters: any = { limit: 100, offset: 0 } // Backend max is 100
      
      if (statusFilter !== 'all') {
        filters.status = statusFilter
      }
      if (severityFilter !== 'all') {
        filters.severity = severityFilter
      }
      
      console.log('Fetching reports with filters:', filters)
      const result = await api.getReports(filters)
      console.log('Reports fetched:', result?.data?.data?.length || 0)
      return result
    },
  })

  const reports = reportsData?.data?.data || []
  
  // Filter out reports without valid coordinates
  const validReports = reports.filter((r: any) => 
    r.latitude && r.longitude && 
    !isNaN(r.latitude) && !isNaN(r.longitude) &&
    r.latitude >= -90 && r.latitude <= 90 &&
    r.longitude >= -180 && r.longitude <= 180
  )
  
  console.log('Valid reports for map:', validReports.length)

  // Calculate center based on valid reports
  const mapCenter: [number, number] = validReports.length > 0
    ? [validReports[0].latitude, validReports[0].longitude]
    : [10.762622, 106.660172] // Default: Ho Chi Minh City
  
  console.log('Map center:', mapCenter)

  // Statistics
  const stats = {
    total: reports.length,
    pending: reports.filter((r: any) => r.status === 'pending').length,
    reviewing: reports.filter((r: any) => r.status === 'reviewing').length,
    resolved: reports.filter((r: any) => r.status === 'resolved').length,
    critical: reports.filter((r: any) => r.severity === 'critical').length,
    high: reports.filter((r: any) => r.severity === 'high').length,
    medium: reports.filter((r: any) => r.severity === 'medium').length,
    low: reports.filter((r: any) => r.severity === 'low').length,
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
            <Navigation className="w-8 h-8 text-blue-600" />
            Bản Đồ Reports
          </h1>
          <p className="text-gray-600 mt-1">Xem vị trí và phân bố các reports trên bản đồ</p>
        </div>
        <div className="flex items-center gap-3">
          {/* Map Type Toggle */}
          <div className="flex items-center gap-2 bg-white border border-gray-300 rounded-lg p-1">
            <button
              onClick={() => setMapType('street')}
              className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
                mapType === 'street'
                  ? 'bg-blue-500 text-white'
                  : 'text-gray-700 hover:bg-gray-100'
              }`}
            >
              🗺️ Bản đồ
            </button>
            <button
              onClick={() => setMapType('satellite')}
              className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
                mapType === 'satellite'
                  ? 'bg-blue-500 text-white'
                  : 'text-gray-700 hover:bg-gray-100'
              }`}
            >
              🛰️ Vệ tinh
            </button>
          </div>
          <button
            onClick={() => refetch()}
            className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Làm mới</span>
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center gap-2 mb-4">
          <Filter className="w-5 h-5 text-gray-600" />
          <h2 className="text-lg font-semibold text-gray-900">Bộ Lọc</h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Trạng Thái
            </label>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="all">Tất cả</option>
              <option value="pending">Pending</option>
              <option value="reviewing">Reviewing</option>
              <option value="resolved">Resolved</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Độ Nghiêm Trọng
            </label>
            <select
              value={severityFilter}
              onChange={(e) => setSeverityFilter(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="all">Tất cả</option>
              <option value="critical">Critical</option>
              <option value="high">High</option>
              <option value="medium">Medium</option>
              <option value="low">Low</option>
            </select>
          </div>
        </div>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-3">
        <div className="bg-white rounded-lg p-4 border-l-4 border-blue-500 shadow-sm">
          <p className="text-xs text-gray-600 font-medium mb-1">Tổng</p>
          <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border-l-4 border-yellow-500 shadow-sm">
          <p className="text-xs text-gray-600 font-medium mb-1">Pending</p>
          <p className="text-2xl font-bold text-yellow-600">{stats.pending}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border-l-4 border-blue-500 shadow-sm">
          <p className="text-xs text-gray-600 font-medium mb-1">Reviewing</p>
          <p className="text-2xl font-bold text-blue-600">{stats.reviewing}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border-l-4 border-green-500 shadow-sm">
          <p className="text-xs text-gray-600 font-medium mb-1">Resolved</p>
          <p className="text-2xl font-bold text-green-600">{stats.resolved}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border-l-4 border-red-500 shadow-sm">
          <p className="text-xs text-gray-600 font-medium mb-1">Critical</p>
          <p className="text-2xl font-bold text-red-600">{stats.critical}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border-l-4 border-orange-500 shadow-sm">
          <p className="text-xs text-gray-600 font-medium mb-1">High</p>
          <p className="text-2xl font-bold text-orange-600">{stats.high}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border-l-4 border-yellow-500 shadow-sm">
          <p className="text-xs text-gray-600 font-medium mb-1">Medium</p>
          <p className="text-2xl font-bold text-yellow-600">{stats.medium}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border-l-4 border-green-500 shadow-sm">
          <p className="text-xs text-gray-600 font-medium mb-1">Low</p>
          <p className="text-2xl font-bold text-green-600">{stats.low}</p>
        </div>
      </div>

      {/* Map */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        {/* Legend */}
        <div className="p-4 bg-gray-50 border-b border-gray-200">
          <div className="flex items-center justify-between flex-wrap gap-4">
            <div className="flex items-center gap-2">
              <MapPin className="w-5 h-5 text-gray-600" />
              <span className="font-semibold text-gray-900">Chú Thích:</span>
            </div>
            <div className="flex items-center gap-6 text-sm flex-wrap">
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full bg-red-500 border-2 border-white shadow"></div>
                <span className="text-gray-700">Critical</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full bg-orange-500 border-2 border-white shadow"></div>
                <span className="text-gray-700">High</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full bg-yellow-500 border-2 border-white shadow"></div>
                <span className="text-gray-700">Medium</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full bg-green-500 border-2 border-white shadow"></div>
                <span className="text-gray-700">Low</span>
              </div>
            </div>
          </div>
        </div>

        {/* Map Container */}
        <div className="h-[calc(100vh-400px)] min-h-[600px]">
          {isLoading ? (
            <div className="h-full flex items-center justify-center bg-gray-50">
              <div className="text-center">
                <div className="w-12 h-12 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto mb-4"></div>
                <p className="text-gray-600">Đang tải bản đồ...</p>
              </div>
            </div>
          ) : error ? (
            <div className="h-full flex items-center justify-center bg-red-50">
              <div className="text-center">
                <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <MapPin className="w-8 h-8 text-red-600" />
                </div>
                <p className="text-red-600 font-medium text-lg">Lỗi khi tải dữ liệu</p>
                <p className="text-sm text-red-500 mt-2">{(error as any)?.message || 'Không thể kết nối tới server'}</p>
                <button
                  onClick={() => refetch()}
                  className="mt-4 px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
                >
                  Thử lại
                </button>
              </div>
            </div>
          ) : validReports.length > 0 ? (
            <MapContainer
              center={mapCenter}
              zoom={12}
              style={{ height: '100%', width: '100%' }}
              scrollWheelZoom={true}
            >
              {/* Map Tiles - Switch between Street and Satellite */}
              {mapType === 'street' ? (
                // Using OpenTopoMap - Beautiful topographic map, politically neutral
                <TileLayer
                  attribution='Map data: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
                  url="https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
                  maxZoom={17}
                />
              ) : (
                // Using Esri World Imagery - Satellite view
                <TileLayer
                  attribution='Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
                  url="https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                  maxZoom={19}
                />
              )}
              
              {validReports.map((report: any) => {
                console.log('Rendering marker for report:', report.id, report.latitude, report.longitude)
                return (
                <Marker
                  key={report.id}
                  position={[report.latitude, report.longitude]}
                  icon={createCustomIcon(report.severity)}
                >
                  <Popup maxWidth={300}>
                    <div className="p-3">
                      <h3 className="font-bold text-gray-900 mb-3 text-lg capitalize border-b pb-2">
                        {report.type.replace(/_/g, ' ')}
                      </h3>
                      <div className="space-y-2 text-sm mb-3">
                        <div className="flex items-center justify-between">
                          <span className="text-gray-600 font-medium">Trạng thái:</span>
                          <span className={`px-2 py-1 rounded text-xs font-semibold ${
                            report.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                            report.status === 'reviewing' ? 'bg-blue-100 text-blue-800' :
                            report.status === 'resolved' ? 'bg-green-100 text-green-800' :
                            'bg-red-100 text-red-800'
                          }`}>
                            {report.status}
                          </span>
                        </div>
                        <div className="flex items-center justify-between">
                          <span className="text-gray-600 font-medium">Độ nghiêm trọng:</span>
                          <span className={`px-2 py-1 rounded text-xs font-semibold ${
                            report.severity === 'critical' ? 'bg-red-100 text-red-800' :
                            report.severity === 'high' ? 'bg-orange-100 text-orange-800' :
                            report.severity === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                            'bg-green-100 text-green-800'
                          }`}>
                            {report.severity}
                          </span>
                        </div>
                        <div className="pt-2 border-t">
                          <p className="text-gray-600 font-medium mb-1">Địa chỉ:</p>
                          <p className="text-gray-900">{report.address || 'N/A'}</p>
                        </div>
                        <div>
                          <p className="text-gray-600 font-medium mb-1">Mã tracking:</p>
                          <p className="font-mono text-xs bg-gray-100 px-2 py-1 rounded">
                            {report.tracking_code}
                          </p>
                        </div>
                        {report.description && (
                          <div>
                            <p className="text-gray-600 font-medium mb-1">Mô tả:</p>
                            <p className="text-gray-700 text-xs line-clamp-2">
                              {report.description}
                            </p>
                          </div>
                        )}
                      </div>
                      <button
                        onClick={() => navigate(`/reports/${report.id}`)}
                        className="w-full px-4 py-2 bg-blue-500 text-white text-sm font-medium rounded-lg hover:bg-blue-600 transition-colors flex items-center justify-center gap-2"
                      >
                        <MapPin className="w-4 h-4" />
                        <span>Xem Chi Tiết</span>
                      </button>
                    </div>
                  </Popup>
                  
                  {/* Circle to show area of impact */}
                  <Circle
                    center={[report.latitude, report.longitude]}
                    radius={
                      report.severity === 'critical' ? 500 :
                      report.severity === 'high' ? 300 :
                      report.severity === 'medium' ? 200 : 100
                    }
                    pathOptions={{
                      color: report.severity === 'critical' ? '#ef4444' :
                             report.severity === 'high' ? '#f97316' :
                             report.severity === 'medium' ? '#eab308' : '#22c55e',
                      fillColor: report.severity === 'critical' ? '#ef4444' :
                                 report.severity === 'high' ? '#f97316' :
                                 report.severity === 'medium' ? '#eab308' : '#22c55e',
                      fillOpacity: 0.1,
                      weight: 1,
                      opacity: 0.5,
                    }}
                  />
                </Marker>
              )
              })}
            </MapContainer>
          ) : (
            <div className="h-full flex items-center justify-center bg-gray-50">
              <div className="text-center">
                <MapPin className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-600 font-medium text-lg">Không có reports nào</p>
                <p className="text-sm text-gray-500 mt-2">Thử thay đổi bộ lọc để xem reports khác</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
