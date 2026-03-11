#!/bin/bash
# HotCar Location Debug Script

echo "🔍 HotCar Location Debug"
echo "========================"
echo ""

# Check simulator location
echo "📍 Simulator Location Setting:"
xcrun simctl location "iPhone 15 Pro" show 2>&1 | grep -v "Usage:" | head -5
echo ""

# Check app logs
echo "📱 HotCar App Location Logs (last 5 minutes):"
xcrun simctl spawn "iPhone 15 Pro" log show --predicate 'process == "hotcar"' --last 5m --style compact --debug 2>/dev/null | grep -i "location\|cache" | tail -30

echo ""
echo "✅ Debug complete"
