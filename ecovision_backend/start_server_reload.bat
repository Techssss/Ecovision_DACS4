@echo off
echo Starting EcoVision Backend Server with Auto-Reload...
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause

