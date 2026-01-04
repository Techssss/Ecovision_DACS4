"""
Tests for AQI module
"""
import pytest


def test_get_aqi_by_location(client, test_user):
    """Test getting AQI by location"""
    # First login to get token
    login_response = client.post("/api/v1/auth/login", json={
        "email": "test@example.com",
        "password": "testpassword"
    })
    token = login_response.json()["data"]["tokens"]["access_token"]
    
    headers = {"Authorization": f"Bearer {token}"}
    response = client.get(
        "/api/v1/aqi/location?lat=16.0544&lon=108.2022",
        headers=headers
    )
    assert response.status_code == 200
    assert "aqi" in response.json()["data"]

