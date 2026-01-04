import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import Dashboard from './pages/Dashboard'
import Reports from './pages/Reports'
import ReportDetailNew from './pages/ReportDetailNew'
import ReportsMap from './pages/ReportsMap'
import AQIStats from './pages/AQIStats'

function App() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/reports" element={<Reports />} />
          <Route path="/reports/:id" element={<ReportDetailNew />} />
          <Route path="/map" element={<ReportsMap />} />
          <Route path="/aqi" element={<AQIStats />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  )
}

export default App

