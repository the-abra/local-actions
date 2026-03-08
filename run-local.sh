#!/bin/bash

# run-local.sh
# Usage: ./run-local.sh <workflow-file> <docker-image> [job-name]

set -e

WORKFLOW_FILE="$1"
IMAGE="$2"
JOB_NAME="$3"

if [ -z "$WORKFLOW_FILE" ] || [ -z "$IMAGE" ]; then
    echo "Usage: $0 <workflow-file> <docker-image> [job-name]"
    exit 1
fi

if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "Error: Workflow file '$WORKFLOW_FILE' not found."
    exit 1
fi

# Function to check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: yq is required."
    exit 1
fi

# Function to check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: docker is required."
    exit 1
fi

# Detect Job Name if not provided
if [ -z "$JOB_NAME" ]; then
    JOB_NAME=$(yq -r '.jobs | keys | .[0]' "$WORKFLOW_FILE")
    echo "No job specified. Using first job found: $JOB_NAME"
fi

echo "Preparing to run job '$JOB_NAME' from '$WORKFLOW_FILE' in '$IMAGE'..."

# container name
CONTAINER_NAME="local-runner-$(date +%s)"

# Start Docker container
echo "Starting container..."
docker run -d --rm -v "$(pwd):/work" -w /work --name "$CONTAINER_NAME" "$IMAGE" sleep infinity > /dev/null

cleanup() {
    echo "Stopping container..."
    docker stop "$CONTAINER_NAME" > /dev/null
}
trap cleanup EXIT

# Get number of steps
STEP_COUNT=$(yq -r --arg JOB_NAME "$JOB_NAME" '.jobs[$JOB_NAME].steps | length' "$WORKFLOW_FILE")

echo "Found $STEP_COUNT steps."

for (( i=0; i<$STEP_COUNT; i++ )); do
    echo "---------------------------------------------------"
    echo "Processing step $((i+1))..."
    
    # Extract step details using jq
    STEP_NAME=$(yq -r --arg JOB_NAME "$JOB_NAME" --argjson idx "$i" '.jobs[$JOB_NAME].steps[$idx].name // "Step \($idx + 1)"' "$WORKFLOW_FILE")
    STEP_RUN=$(yq -r --arg JOB_NAME "$JOB_NAME" --argjson idx "$i" '.jobs[$JOB_NAME].steps[$idx].run' "$WORKFLOW_FILE")
    STEP_USES=$(yq -r --arg JOB_NAME "$JOB_NAME" --argjson idx "$i" '.jobs[$JOB_NAME].steps[$idx].uses' "$WORKFLOW_FILE")
    
    # Check for secrets in the entire step object
    # Using jq contains() or matching secret pattern on the JSON dump
    # We will dump the step to a string and grep it for simplicity
    STEP_DUMP=$(yq -r --arg JOB_NAME "$JOB_NAME" --argjson idx "$i" '.jobs[$JOB_NAME].steps[$idx]' "$WORKFLOW_FILE")
    
    # Check for secrets patterns: secrets.*, github.token
    if echo "$STEP_DUMP" | grep -iqE "secrets\.|github\.token"; then
        echo "⚠️  SKIPPING '$STEP_NAME': Contains secrets."
        continue
    fi

    echo "▶️  Running '$STEP_NAME'"

    if [ "$STEP_USES" != "null" ]; then
        echo "ℹ️  Action usage '$STEP_USES' detected. (Not fully supported, skipping execution logic for actions)"
        continue
    fi

    if [ "$STEP_RUN" != "null" ]; then
        # Execute run command
        echo "Executing command:"
        echo "$STEP_RUN"
        
        # Create a temporary script file on host
        TMP_SCRIPT=".local-runner-step-$i.sh"
        echo "#!/bin/sh" > "$TMP_SCRIPT"
        echo "set -e" >> "$TMP_SCRIPT"
        echo "$STEP_RUN" >> "$TMP_SCRIPT"
        chmod +x "$TMP_SCRIPT"
        
        # Execute inside container
        if docker exec "$CONTAINER_NAME" /work/"$TMP_SCRIPT"; then
            echo "✅ Success"
        else
            echo "❌ Failed"
            rm -f "$TMP_SCRIPT"
            exit 1
        fi
        
        rm -f "$TMP_SCRIPT"
    else
        echo "ℹ️  No 'run' or 'uses' found. Skipping."
    fi

done

echo "---------------------------------------------------"
echo "Job '$JOB_NAME' completed."
