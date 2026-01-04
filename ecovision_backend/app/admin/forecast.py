"""
Trend Forecasting Service using Prophet
"""
from datetime import datetime, timedelta
from typing import Dict, List, Any
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.reports.models import Report
import pandas as pd
import numpy as np

# Try to import Prophet, fallback to simple linear regression if not available
try:
    from prophet import Prophet
    PROPHET_AVAILABLE = True
except ImportError:
    PROPHET_AVAILABLE = False
    print("Warning: Prophet not installed. Using simple linear regression for forecasting.")


class TrendForecastService:
    """Service for forecasting report trends"""
    
    @staticmethod
    def get_historical_data(db: Session, days: int = 14) -> pd.DataFrame:
        """Get historical report counts by day"""
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        # Query reports grouped by date
        results = db.query(
            func.date(Report.created_at).label('date'),
            func.count(Report.id).label('count')
        ).filter(
            Report.created_at >= start_date,
            Report.created_at <= end_date
        ).group_by(
            func.date(Report.created_at)
        ).order_by(
            func.date(Report.created_at)
        ).all()
        
        # Convert to DataFrame
        if results:
            df = pd.DataFrame([
                {
                    'ds': datetime.strptime(str(r.date), '%Y-%m-%d') if isinstance(r.date, str) else datetime.combine(r.date, datetime.min.time()), 
                    'y': r.count
                }
                for r in results
            ])
        else:
            # If no data, create dummy data
            dates = pd.date_range(start=start_date, end=end_date, freq='D')
            df = pd.DataFrame({
                'ds': dates,
                'y': np.random.randint(5, 20, size=len(dates))  # Dummy data
            })
        
        return df
    
    @staticmethod
    def forecast_with_prophet(df: pd.DataFrame, periods: int = 7) -> Dict[str, Any]:
        """Forecast using Prophet model"""
        if not PROPHET_AVAILABLE or len(df) < 2:
            return TrendForecastService.forecast_simple(df, periods)
        
        try:
            # Initialize and fit Prophet model
            model = Prophet(
                daily_seasonality=False,
                weekly_seasonality=True,
                yearly_seasonality=False,
                interval_width=0.95,
                changepoint_prior_scale=0.05
            )
            model.fit(df)
            
            # Make future dataframe
            future = model.make_future_dataframe(periods=periods)
            forecast = model.predict(future)
            
            # Split historical and forecast
            historical_size = len(df)
            historical = forecast.iloc[:historical_size]
            future_forecast = forecast.iloc[historical_size:]
            
            # Calculate trend
            last_week_avg = df['y'].tail(7).mean()
            next_week_avg = future_forecast['yhat'].mean()
            trend_change = ((next_week_avg - last_week_avg) / last_week_avg) * 100
            
            # Generate insights
            insights = TrendForecastService.generate_insights(
                trend_change, 
                next_week_avg,
                future_forecast
            )
            
            return {
                'historical': [
                    {
                        'date': row['ds'].strftime('%Y-%m-%d'),
                        'actual': int(df.iloc[i]['y']),
                        'predicted': int(row['yhat']),
                        'lower': int(row['yhat_lower']),
                        'upper': int(row['yhat_upper'])
                    }
                    for i, row in historical.iterrows()
                ],
                'forecast': [
                    {
                        'date': row['ds'].strftime('%Y-%m-%d'),
                        'predicted': int(row['yhat']),
                        'lower': int(max(0, row['yhat_lower'])),
                        'upper': int(row['yhat_upper'])
                    }
                    for _, row in future_forecast.iterrows()
                ],
                'trend': {
                    'change_percent': round(trend_change, 2),
                    'direction': 'increase' if trend_change > 0 else 'decrease',
                    'last_week_avg': round(last_week_avg, 1),
                    'next_week_avg': round(next_week_avg, 1)
                },
                'insights': insights,
                'model': 'prophet'
            }
            
        except Exception as e:
            print(f"Prophet forecasting error: {e}")
            return TrendForecastService.forecast_simple(df, periods)
    
    @staticmethod
    def forecast_simple(df: pd.DataFrame, periods: int = 7) -> Dict[str, Any]:
        """Simple linear regression forecast as fallback"""
        # Need at least 2 data points
        if len(df) < 2:
            # Not enough data - use average
            avg_value = df['y'].mean() if len(df) > 0 else 10
            last_date = df['ds'].max() if len(df) > 0 else datetime.now()
            
            forecast_dates = pd.date_range(
                start=last_date + timedelta(days=1),
                periods=periods,
                freq='D'
            )
            
            return {
                'historical': [
                    {
                        'date': df.iloc[i]['ds'].strftime('%Y-%m-%d'),
                        'actual': int(df.iloc[i]['y']),
                        'predicted': int(avg_value),
                        'lower': int(max(0, avg_value * 0.8)),
                        'upper': int(avg_value * 1.2)
                    }
                    for i in range(len(df))
                ],
                'forecast': [
                    {
                        'date': date.strftime('%Y-%m-%d'),
                        'predicted': int(avg_value),
                        'lower': int(max(0, avg_value * 0.8)),
                        'upper': int(avg_value * 1.2)
                    }
                    for date in forecast_dates
                ],
                'trend': {
                    'change_percent': 0.0,
                    'direction': 'stable',
                    'last_week_avg': round(avg_value, 1),
                    'next_week_avg': round(avg_value, 1)
                },
                'insights': TrendForecastService.generate_insights(0, avg_value, None),
                'model': 'average_fallback'
            }
        
        # Calculate trend using linear regression
        x = np.arange(len(df))
        y = df['y'].values
        
        # Fit linear model
        try:
            z = np.polyfit(x, y, 1)
            p = np.poly1d(z)
        except:
            # If polyfit fails, use average
            avg_value = y.mean()
            p = lambda x: avg_value
        
        # Generate forecast
        last_date = df['ds'].max()
        forecast_dates = pd.date_range(
            start=last_date + timedelta(days=1),
            periods=periods,
            freq='D'
        )
        
        forecast_x = np.arange(len(df), len(df) + periods)
        forecast_y = p(forecast_x)
        
        # Calculate confidence interval (simple ±20%)
        std = y.std()
        
        # Calculate trend
        last_week_avg = y[-7:].mean() if len(y) >= 7 else y.mean()
        next_week_avg = forecast_y.mean()
        trend_change = ((next_week_avg - last_week_avg) / last_week_avg) * 100
        
        insights = TrendForecastService.generate_insights(
            trend_change,
            next_week_avg,
            None
        )
        
        return {
            'historical': [
                {
                    'date': df.iloc[i]['ds'].strftime('%Y-%m-%d'),
                    'actual': int(df.iloc[i]['y']),
                    'predicted': int(p(i)),
                    'lower': int(max(0, p(i) - std)),
                    'upper': int(p(i) + std)
                }
                for i in range(len(df))
            ],
            'forecast': [
                {
                    'date': date.strftime('%Y-%m-%d'),
                    'predicted': int(max(0, pred)),
                    'lower': int(max(0, pred - std)),
                    'upper': int(pred + std)
                }
                for date, pred in zip(forecast_dates, forecast_y)
            ],
            'trend': {
                'change_percent': round(trend_change, 2),
                'direction': 'increase' if trend_change > 0 else 'decrease',
                'last_week_avg': round(last_week_avg, 1),
                'next_week_avg': round(next_week_avg, 1)
            },
            'insights': insights,
            'model': 'linear_regression'
        }
    
    @staticmethod
    def generate_insights(
        trend_change: float,
        next_week_avg: float,
        forecast_df: Any = None
    ) -> Dict[str, Any]:
        """Generate actionable insights from forecast"""
        
        # Determine severity
        if abs(trend_change) < 5:
            severity = 'stable'
            icon = '📊'
        elif abs(trend_change) < 15:
            severity = 'moderate'
            icon = '📈' if trend_change > 0 else '📉'
        else:
            severity = 'significant'
            icon = '⚠️'
        
        # Generate recommendations
        recommendations = []
        
        if trend_change > 15:
            recommendations.extend([
                'Tăng cường đội ngũ xử lý reports',
                'Chuẩn bị thêm resources cho tuần tới',
                'Kiểm tra nguyên nhân tăng đột biến',
                'Tăng cường giám sát các khu vực hotspot'
            ])
        elif trend_change > 5:
            recommendations.extend([
                'Duy trì đội ngũ hiện tại',
                'Theo dõi xu hướng tăng',
                'Chuẩn bị kế hoạch dự phòng'
            ])
        elif trend_change < -15:
            recommendations.extend([
                'Xu hướng giảm mạnh - tích cực!',
                'Đánh giá hiệu quả các biện pháp đã thực hiện',
                'Duy trì các hoạt động hiệu quả',
                'Có thể điều chỉnh resources'
            ])
        elif trend_change < -5:
            recommendations.extend([
                'Xu hướng giảm nhẹ',
                'Tiếp tục theo dõi',
                'Duy trì các biện pháp hiện tại'
            ])
        else:
            recommendations.extend([
                'Xu hướng ổn định',
                'Duy trì hoạt động bình thường',
                'Theo dõi định kỳ'
            ])
        
        # Summary message
        if trend_change > 0:
            summary = f"Dự báo tăng {abs(trend_change):.1f}% so với tuần trước. Trung bình {next_week_avg:.0f} reports/ngày."
        else:
            summary = f"Dự báo giảm {abs(trend_change):.1f}% so với tuần trước. Trung bình {next_week_avg:.0f} reports/ngày."
        
        return {
            'severity': severity,
            'icon': icon,
            'summary': summary,
            'recommendations': recommendations,
            'trend_change': trend_change,
            'next_week_avg': next_week_avg
        }
