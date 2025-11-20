#!/bin/bash

# WeatherBuddy Setup Verification Script
# This script checks if all necessary files are in place

echo "🌤️  WeatherBuddy Setup Verification"
echo "===================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for checks
PASSED=0
FAILED=0

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ((FAILED++))
    fi
}

# Function to check if directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ((FAILED++))
    fi
}

echo "Checking core Swift files..."
check_file "WeatherBuddy/WeatherBuddyApp.swift"
check_file "WeatherBuddy/RiveWeatherView.swift"
check_file "WeatherBuddy/WeatherViewModel.swift"
check_file "WeatherBuddy/LocationManager.swift"
check_file "WeatherBuddy/RiveModels.swift"
check_file "WeatherBuddy/WeatherService.swift"
check_file "WeatherBuddy/WeatherRiveViewModel.swift"
echo ""

echo "Checking component files..."
check_file "WeatherBuddy/Views/Components/WeatherSearchBar.swift"
check_file "WeatherBuddy/Views/Components/RiveAnimationView.swift"
echo ""

echo "Checking service files..."
check_file "WeatherBuddy/Services/RiveDataBindingManager.swift"
echo ""

echo "Checking configuration files..."
check_file "WeatherBuddy/Configuration/Constants.swift"
echo ""

echo "Checking Rive animation file..."
check_file "WeatherBuddy/weatherbuddy_final.riv"
echo ""

echo "Checking project structure..."
check_dir "WeatherBuddy.xcodeproj"
check_dir "WeatherBuddy/Assets.xcassets"
check_dir "WeatherBuddy/Views"
check_dir "WeatherBuddy/Services"
check_dir "WeatherBuddy/Configuration"
echo ""

echo "Checking documentation..."
check_file "README.md"
echo ""

# Check for location permissions in project.pbxproj
echo "Checking location permissions..."
if grep -q "NSLocationWhenInUseUsageDescription" "WeatherBuddy.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✓${NC} Location permissions configured"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC}  Location permissions not configured"
    echo "   → Add NSLocationWhenInUseUsageDescription to Info tab in Xcode"
    echo "   → Or add to project.pbxproj INFOPLIST_KEY settings"
fi
echo ""

# Check Open-Meteo API configuration (no API key needed!)
echo "Checking Weather API configuration..."
if grep -q "open-meteo.com" "WeatherBuddy/WeatherService.swift"; then
    echo -e "${GREEN}✓${NC} Using Open-Meteo API (free, no API key required)"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Weather API not properly configured"
    ((FAILED++))
fi
echo ""

# Check temperature unit
echo "Checking temperature configuration..."
if grep -q "temperature_unit=fahrenheit" "WeatherBuddy/WeatherService.swift"; then
    echo -e "${GREEN}✓${NC} Temperature unit set to Fahrenheit"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC}  Temperature unit not specified (may default to Celsius)"
fi
echo ""

# Summary
echo "===================================="
echo "Summary:"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
    echo ""
    echo "⚠️  Please complete the missing items before running the app."
    echo "📖 See README.md for detailed instructions."
    exit 1
else
    echo -e "${GREEN}Failed: 0${NC}"
    echo ""
    echo "🎉 All checks passed! You're ready to build the app."
    echo ""
    echo "Next steps:"
    echo "1. Open WeatherBuddy.xcodeproj in Xcode"
    echo "2. Add RiveRuntime package if not already added:"
    echo "   → File → Add Package Dependencies"
    echo "   → https://github.com/rive-app/rive-ios"
    echo "3. Verify weatherbuddy_final.riv is in Xcode project"
    echo "4. Build and run (⌘R)"
    echo ""
    echo "📖 For more information, see README.md"
    exit 0
fi
