#!/bin/bash
set -eu

# Default timezone, tag and build version
DEFAULT_TZ="Europe/Kiev"
DEFAULT_TAG="hun1er/ubuntu-hlds"
DEFAULT_BUILD="8684"

# Available HLDS build versions
AVAILABLE_BUILDS=("8684" "10211")

# Color codes for messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Print a color-coded message
print_message() {
    echo -e "${1}${2}${NC}"
}

# Display help information
print_help() {
    cat << EOF
Usage: $0 [options]

Options:
  -t, --tag <tag>       Specify the custom tag for the Docker image.
  -b, --build <version> Specify the HLDS build version (default: $DEFAULT_BUILD).
  -z, --timezone <tz>   Specify the timezone (default: $DEFAULT_TZ).
  -h, --help            Show this help message and exit.

If no options are provided, the script will prompt for input in interactive mode.
EOF
}

# Validate build version
validate_build_version() {
    local build="$1"

    if [[ ! " ${AVAILABLE_BUILDS[*]} " =~ (^|[[:space:]])$build($|[[:space:]]) ]]; then
        print_message "$RED" "Error: HLDS build version '$build' is not available. Available builds are: ${AVAILABLE_BUILDS[*]}"
        exit 1
    fi
}

# Build the Docker image
build_image() {
    local tz="$1"
    local tag="$2"
    local build="$3"

    validate_build_version "$build"
    print_message "$GREEN" "Building Docker image with tag '$tag' and HLDS build $build ..."
    docker build --build-arg TZ="$tz" --build-arg HLDS_BUILD="$build" --tag "$tag" .
    print_message "$GREEN" "'$tag' was successfully built."
}

# Interactive mode
interactive_mode() {
    if [[ -z "$custom_tz" ]]; then
        read -rp "Enter the timezone (default: $DEFAULT_TZ): " tz
        custom_tz="${tz:-$DEFAULT_TZ}"
    fi

    if [[ -z "$custom_build" ]]; then
        print_message "$YELLOW" "Available HLDS build versions: ${AVAILABLE_BUILDS[*]}"
        read -rp "Enter the HLDS build version (default: $DEFAULT_BUILD): " build
        custom_build="${build:-$DEFAULT_BUILD}"
    fi

    validate_build_version "$custom_build"

    if [[ -z "$custom_tag" ]]; then
        read -rp "Enter the tag name (default: $DEFAULT_TAG-$custom_build): " tag
        custom_tag="${tag:-$DEFAULT_TAG-$custom_build}"
    fi

    build_image "$custom_tz" "$custom_tag" "$custom_build"
}

# Check if Docker is installed and available in PATH
if ! command -v docker &> /dev/null; then
    print_message "$RED" "Docker is not installed or not in PATH."
    exit 1
fi

# Parse command-line options
custom_tz=""
custom_tag=""
custom_build=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -z|--timezone)
            custom_tz="$2"
            shift 2
            ;;
        -t|--tag)
            custom_tag="$2"
            shift 2
            ;;
        -b|--build)
            custom_build="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            print_message "$RED" "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

# If the timezone, tag and build are not specified, switch to interactive mode
if [[ -n "$custom_tz" && -n "$custom_tag" && -n "$custom_build" ]]; then
    build_image "$custom_tz" "$custom_tag" "$custom_build"
else
    interactive_mode
fi
