"""
Quick test script for forecast endpoint
"""
import sys
sys.path.insert(0, '.')

from app.admin.forecast import TrendForecastService
from app.database import SessionLocal
import json

def test_forecast():
    print("=" * 50)
    print("Testing Trend Forecast Service")
    print("=" * 50)
    
    db = SessionLocal()
    
    try:
        # Get historical data
        print("\n1. Getting historical data...")
        df = TrendForecastService.get_historical_data(db, days=14)
        print(f"   ✓ Got {len(df)} days of data")
        print(f"   Data range: {df['ds'].min()} to {df['ds'].max()}")
        print(f"   Report counts: {df['y'].tolist()}")
        
        # Generate forecast
        print("\n2. Generating forecast...")
        result = TrendForecastService.forecast_with_prophet(df, periods=7)
        print(f"   ✓ Forecast generated using: {result['model']}")
        print(f"   Historical points: {len(result['historical'])}")
        print(f"   Forecast points: {len(result['forecast'])}")
        
        # Show trend
        print("\n3. Trend Analysis:")
        trend = result['trend']
        print(f"   Direction: {trend['direction']}")
        print(f"   Change: {trend['change_percent']}%")
        print(f"   Last week avg: {trend['last_week_avg']}")
        print(f"   Next week avg: {trend['next_week_avg']}")
        
        # Show insights
        print("\n4. Insights:")
        insights = result['insights']
        print(f"   Severity: {insights['severity']}")
        print(f"   Icon: {insights['icon']}")
        print(f"   Summary: {insights['summary']}")
        print(f"   Recommendations:")
        for rec in insights['recommendations']:
            print(f"     • {rec}")
        
        # Show sample forecast
        print("\n5. Sample Forecast (next 3 days):")
        for item in result['forecast'][:3]:
            print(f"   {item['date']}: {item['predicted']} reports (range: {item['lower']}-{item['upper']})")
        
        print("\n" + "=" * 50)
        print("✓ Test completed successfully!")
        print("=" * 50)
        
        return result
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return None
    finally:
        db.close()

if __name__ == "__main__":
    test_forecast()
