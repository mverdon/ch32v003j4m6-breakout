#!/bin/bash

# Get file names
PROJECT_FILE=$(ls *.kicad_pro)
PROJECT=$(basename ${PROJECT_FILE} .kicad_pro)
PCB_FILE=$(ls ${PROJECT}.kicad_pcb)
SCH_FILE=$(ls ${PROJECT}.kicad_sch)
REVISION=$(cat $SCH_FILE | grep rev | sed 's/[(rev")]//g' | tr -d '[[:space:]]')
# Check if the revision is empty, exit early if it is
if [ -z "$REVISION" ]; then
    echo "Revision is empty, exiting"
    exit 1
fi
# Create output folder
mkdir -p outputs/validation
# Run ERC
kicad-cli sch erc \
    --severity-all \
    --exit-code-violations \
    --format json \
    -o "outputs/validation/${PROJECT}_rev${REVISION}_erc.json" \
    ${SCH_FILE}
# Run DRC
kicad-cli pcb drc \
    --schematic-parity \
    --severity-all \
    --exit-code-violations \
    --format json \
    -o "outputs/validation/${PROJECT}_rev${REVISION}_drc.json" \
    ${PCB_FILE}
