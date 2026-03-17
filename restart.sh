#!/bin/bash

echo ""
echo "================================================"
echo "  CyberFinRisk — Killing existing sessions..."
echo "================================================"

# Kill backend processes (uvicorn/python)
pkill -f "uvicorn main:app" || true
fuser -k 8000/tcp 2>/dev/null || true

# Kill frontend processes (node/next)
pkill -f "next dev" || true
fuser -k 3000/tcp 2>/dev/null || true

echo "  ✓ Old sessions killed."
echo ""

echo "================================================"
echo "  Starting Backend (Uvicorn on :8000)..."
echo "================================================"

cd backend
# Check if venv exists and activate it
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Start backend in the background and redirect output to a log file
nohup uvicorn main:app --reload --port 8000 > backend_dev.log 2>&1 &
cd ..

# Short delay to let backend start connecting to MongoDB before frontend spins up
sleep 3

echo "  ✓ Backend started in background (logs: backend/backend_dev.log)"
echo ""

echo "================================================"
echo "  Starting Frontend (Next.js on :3000)..."
echo "================================================"

cd frontend
# Start frontend in the background and redirect output to a log file
nohup npm run dev > frontend_dev.log 2>&1 &
cd ..

echo "  ✓ Frontend started in background (logs: frontend/frontend_dev.log)"
echo ""

echo "================================================"
echo "  All done! Open http://localhost:3000"
echo "  (To monitor logs: tail -f frontend/frontend_dev.log)"
echo "  (To stop: fuser -k 3000/tcp && fuser -k 8000/tcp)"
echo "================================================"
echo ""
