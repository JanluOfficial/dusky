#!/bin/bash

# -------------------------------------------------------------
# ANDROID SCREEN MIRRORING (AND SECOND DISPLAY)
# Script created by Janlu (https://github.com/JanluOfficial)
#
# This script handles launching scrcpy with specific
# parameters to allow both traditional mirroring and
# simulating an extra monitor being plugged in. Useful if
# you frequently need to access Samsung DeX or similar.
# -------------------------------------------------------------

# Utility Variables
DESKTOP=0
PARAMS=""
TITLE="Android Screen Mirroring"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-audio)
            PARAMS+="--no-audio " # Disable Audio Streaming (Audio will keep coming out of the Phones Speaker)
            shift
            ;;
        --desktop)
            PARAMS+="--mouse=uhid " # Enable UHID Mouse

            DESKTOP=1
            TITLE="Android Second Screen"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to clean up the virtual display when the script is terminated
cleanup() {
    if [ $DESKTOP -eq 1 ]; then
        echo "Cleaning up..."
        echo "Removing the virtual display..."
        notify-send -a "Android Screen Mirroring" "Cleaning up" "Removing the virtual display..."
        adb shell settings put global overlay_display_devices none
        echo "Virtual display removed."
    fi
    exit 0
}

# Trap to call cleanup function when the script is closed
trap cleanup EXIT

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "Error: adb is not installed or not in PATH. Please install Android Debug Bridge."
    notify-send -u critical -a "Android Screen Mirroring" "adb is not installed" "Please install the scrcpy package before continuing"
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q device$; then
    echo "Error: No Android device connected. Please connect a device and try again."
    notify-send -u critical -a "Android Screen Mirroring" "No Android devices connected" "Please connect a device via USB or Wi-Fi"
    exit 1
fi

# Function to get the list of display IDs
get_display_ids() {
    adb shell dumpsys display | grep "mDisplayId=" | awk '{print $1}' | cut -d= -f2 | sort -u
}

if [ $DESKTOP -eq 1 ]; then
    # Get initial display IDs
    initial_displays=$(get_display_ids)

    # Create a virtual display on the Android device
    echo "Creating a virtual display..."
    notify-send -a "Android Screen Mirroring" "Creating virtual display" "This may take a moment"
    adb shell settings put global overlay_display_devices 1920x1080/180

    # Wait for the new display to be recognized
    sleep 2

    # Get new display IDs
    new_displays=$(get_display_ids)

    # Find the new display ID
    secondary_display_id=$(comm -13 <(echo "$initial_displays") <(echo "$new_displays") | tr -d '[:space:]')

    if [ -z "$secondary_display_id" ]; then
        echo "Failed to detect the new display ID."
        cleanup
        exit 1
    else
        echo "Detected secondary display ID: $secondary_display_id"
        PARAMS+="--display-id $secondary_display_id"
    fi
fi 

# Check if scrcpy is available
if ! command -v scrcpy &> /dev/null; then
    echo "Error: scrcpy is not installed or not in PATH. Please install scrcpy."
    cleanup
    exit 1
fi

# Start scrcpy with the provided options and detected display ID
echo "Starting scrcpy on the virtual display..."
echo "[DEBUG] Parameters: " $PARAMS
if [ $DESKTOP -eq 1 ]; then
  notify-send -a "Android Screen Mirroring" "Successfully connected" "To unlock the mouse, press SUPER"
else
  notify-send -a "Android Screen Mirroring" "Successfully connected"
fi
scrcpy -b 4M --keyboard=uhid --window-title="$TITLE" --max-fps=60 $PARAMS

# The cleanup function will be called automatically when the script exits
