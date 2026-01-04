-- EcoVision Database Schema for SQLite
-- Based on BACKEND_DATABASE_DESIGN.md

-- Enable foreign keys
PRAGMA foreign_keys = ON;

-- ============================================
-- 1. USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    email_verified_at TIMESTAMP,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- ============================================
-- 2. AQI STATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS aqi_stations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    address TEXT,
    city TEXT,
    district TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_aqi_stations_location ON aqi_stations(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_aqi_stations_city ON aqi_stations(city);

-- ============================================
-- 3. AQI READINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS aqi_readings (
    id TEXT PRIMARY KEY,
    station_id TEXT NOT NULL,
    aqi INTEGER NOT NULL,
    pm25 REAL,
    pm10 REAL,
    o3 REAL,
    no2 REAL,
    so2 REAL,
    co REAL,
    temperature REAL,
    humidity REAL,
    pressure REAL,
    wind_speed REAL,
    recorded_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES aqi_stations(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_aqi_readings_station_time ON aqi_readings(station_id, recorded_at);
CREATE INDEX IF NOT EXISTS idx_aqi_readings_recorded_at ON aqi_readings(recorded_at);

-- ============================================
-- 4. REPORTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS reports (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    type TEXT NOT NULL, -- 'air_pollution', 'water_pollution', 'trash', etc.
    description TEXT,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    address TEXT,
    severity TEXT DEFAULT 'medium', -- 'low', 'medium', 'high', 'critical'
    status TEXT DEFAULT 'pending', -- 'pending', 'reviewing', 'resolved', 'rejected'
    tracking_code TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_reports_user ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_location ON reports(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at);

-- ============================================
-- 5. REPORT IMAGES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS report_images (
    id TEXT PRIMARY KEY,
    report_id TEXT NOT NULL,
    image_url TEXT NOT NULL,
    thumbnail_url TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_report_images_report ON report_images(report_id);

-- ============================================
-- 6. REPORT RESPONSES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS report_responses (
    id TEXT PRIMARY KEY,
    report_id TEXT NOT NULL,
    responder_id TEXT, -- Admin/Staff user_id
    message TEXT NOT NULL,
    status TEXT DEFAULT 'resolved', -- 'resolved', 'in_progress', 'rejected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_report_responses_report ON report_responses(report_id);

-- ============================================
-- 7. MESSAGES TABLE (Chat)
-- ============================================
CREATE TABLE IF NOT EXISTS messages (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    content TEXT NOT NULL,
    is_user INTEGER DEFAULT 1, -- 1 = user, 0 = bot
    session_id TEXT, -- Group messages by session
    message_metadata TEXT, -- JSON store actions, suggestions, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_messages_user_session ON messages(user_id, session_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- ============================================
-- 8. ROUTES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS routes (
    id TEXT PRIMARY KEY,
    start_latitude REAL NOT NULL,
    start_longitude REAL NOT NULL,
    end_latitude REAL NOT NULL,
    end_longitude REAL NOT NULL,
    start_address TEXT,
    end_address TEXT,
    strategy TEXT NOT NULL, -- 'cleanest', 'fastest', 'balanced'
    avg_aqi INTEGER NOT NULL,
    max_aqi INTEGER NOT NULL,
    distance_km REAL NOT NULL,
    duration_minutes INTEGER NOT NULL,
    coordinates TEXT NOT NULL, -- JSON array of {lat, lng}
    segment_aqis TEXT NOT NULL, -- JSON array of AQI values per segment
    features TEXT, -- JSON array of route features
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_routes_strategy ON routes(strategy);
CREATE INDEX IF NOT EXISTS idx_routes_location ON routes(start_latitude, start_longitude);

-- ============================================
-- 9. USER ROUTES TABLE (Saved Routes)
-- ============================================
CREATE TABLE IF NOT EXISTS user_routes (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    route_id TEXT NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
    UNIQUE(user_id, route_id)
);

CREATE INDEX IF NOT EXISTS idx_user_routes_user ON user_routes(user_id);

-- ============================================
-- 10. RECOMMENDATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS recommendations (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    type TEXT NOT NULL, -- 'exercise', 'weather', 'air_quality', etc.
    title TEXT NOT NULL,
    description TEXT,
    time_range TEXT, -- "6:00 - 8:00 AM"
    icon TEXT, -- Icon name
    icon_color TEXT, -- Hex color
    priority INTEGER DEFAULT 0, -- Higher = more important
    is_read INTEGER DEFAULT 0,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_recommendations_user_priority ON recommendations(user_id, priority DESC);
CREATE INDEX IF NOT EXISTS idx_recommendations_user_unread ON recommendations(user_id, is_read);

-- ============================================
-- 11. USER SETTINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS user_settings (
    id TEXT PRIMARY KEY,
    user_id TEXT UNIQUE NOT NULL,
    aqi_notifications INTEGER DEFAULT 1,
    auto_location INTEGER DEFAULT 1,
    reminder_notifications INTEGER DEFAULT 0,
    favorite_location_lat REAL,
    favorite_location_lon REAL,
    favorite_location_name TEXT,
    language TEXT DEFAULT 'vi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- TRIGGER: Update updated_at timestamp
-- ============================================
CREATE TRIGGER IF NOT EXISTS update_users_updated_at 
    AFTER UPDATE ON users
    BEGIN
        UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER IF NOT EXISTS update_aqi_stations_updated_at 
    AFTER UPDATE ON aqi_stations
    BEGIN
        UPDATE aqi_stations SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER IF NOT EXISTS update_reports_updated_at 
    AFTER UPDATE ON reports
    BEGIN
        UPDATE reports SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER IF NOT EXISTS update_user_settings_updated_at 
    AFTER UPDATE ON user_settings
    BEGIN
        UPDATE user_settings SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;


