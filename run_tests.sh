#!/bin/bash

# FlashCard Test Runner
# This script runs all tests for the FlashCard application

echo "🧪 Starting FlashCard Test Suite..."
echo "=================================="

# Check if we're in the right directory
if [ ! -d "FlashCard.xcodeproj" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Function to run tests with xcodebuild
run_tests() {
    local scheme=$1
    local destination=$2
    local test_plan=$3
    
    echo "📱 Running tests for scheme: $scheme"
    echo "🎯 Destination: $destination"
    
    if [ -n "$test_plan" ]; then
        echo "📋 Test Plan: $test_plan"
        xcodebuild test \
            -scheme "$scheme" \
            -destination "$destination" \
            -testPlan "$test_plan" \
            -derivedDataPath ./DerivedData \
            -resultBundlePath ./TestResults \
            -resultBundleVersion 3
    else
        xcodebuild test \
            -scheme "$scheme" \
            -destination "$destination" \
            -derivedDataPath ./DerivedData \
            -resultBundlePath ./TestResults \
            -resultBundleVersion 3
    fi
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ Tests passed for $scheme"
    else
        echo "❌ Tests failed for $scheme"
    fi
    
    return $exit_code
}

# Function to run specific test targets
run_unit_tests() {
    echo ""
    echo "🔬 Running Unit Tests..."
    echo "------------------------"
    
    # Run unit tests on iOS Simulator
    run_tests "FlashCard" "platform=iOS Simulator,name=iPhone 16,OS=18.5"
    local unit_test_result=$?
    
    return $unit_test_result
}

run_ui_tests() {
    echo ""
    echo "🎨 Running UI Tests..."
    echo "---------------------"
    
    # Run UI tests on iOS Simulator
    run_tests "FlashCard" "platform=iOS Simulator,name=iPhone 16,OS=18.5"
    local ui_test_result=$?
    
    return $ui_test_result
}

run_all_tests() {
    echo ""
    echo "🚀 Running All Tests..."
    echo "----------------------"
    
    # Run all tests
    run_tests "FlashCard" "platform=iOS Simulator,name=iPhone 16,OS=18.5"
    local all_test_result=$?
    
    return $all_test_result
}

# Function to clean up
cleanup() {
    echo ""
    echo "🧹 Cleaning up..."
    rm -rf ./DerivedData
    rm -rf ./TestResults
    echo "✅ Cleanup complete"
}

# Function to show test results
show_results() {
    echo ""
    echo "📊 Test Results Summary"
    echo "======================"
    
    if [ -d "./TestResults" ]; then
        echo "📁 Test results saved to: ./TestResults"
        echo "📈 View results with: xcrun xccov view --report TestResults"
    else
        echo "❌ No test results found"
    fi
}

# Function to show help
show_help() {
    echo "FlashCard Test Runner"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  unit     Run unit tests only"
    echo "  ui       Run UI tests only"
    echo "  all      Run all tests (default)"
    echo "  clean    Clean up test artifacts"
    echo "  help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 unit     # Run unit tests"
    echo "  $0 ui       # Run UI tests"
    echo "  $0 all      # Run all tests"
    echo "  $0 clean    # Clean up"
}

# Main script logic
case "${1:-all}" in
    "unit")
        run_unit_tests
        test_result=$?
        ;;
    "ui")
        run_ui_tests
        test_result=$?
        ;;
    "all")
        run_all_tests
        test_result=$?
        ;;
    "clean")
        cleanup
        exit 0
        ;;
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    *)
        echo "❌ Unknown option: $1"
        show_help
        exit 1
        ;;
esac

# Show results
show_results

# Final status
echo ""
echo "🏁 Test Suite Complete"
echo "====================="

if [ $test_result -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "💥 Some tests failed. Check the output above for details."
    exit $test_result
fi 