@echo off
echo Starting EcoVision Backend Server...
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
pause

