"""
Tests for authentication
"""
import pytest
from app.auth.service import AuthService
from app.auth.schemas import UserCreate, UserLogin


def test_register_user(client, db):
    """Test user registration"""
    user_data = {
        "email": "newuser@example.com",
        "password": "password123",
        "name": "New User"
    }
    response = client.post("/api/v1/auth/register", json=user_data)
    assert response.status_code == 201
    assert response.json()["success"] is True


def test_login_user(client, test_user):
    """Test user login"""
    login_data = {
        "email": "test@example.com",
        "password": "testpassword"
    }
    response = client.post("/api/v1/auth/login", json=login_data)
    assert response.status_code == 200
    assert "tokens" in response.json()["data"]


def test_login_invalid_credentials(client):
    """Test login with invalid credentials"""
    login_data = {
        "email": "wrong@example.com",
        "password": "wrongpassword"
    }
    response = client.post("/api/v1/auth/login", json=login_data)
    assert response.status_code == 401

