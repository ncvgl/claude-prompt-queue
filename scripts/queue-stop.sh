#!/bin/bash
# Stop hook: reads next prompt from session queue and injects it
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

QUEUE_DIR="${CLAUDE_PLUGIN_DATA:-/tmp}/queue"
QUEUE_FILE="${QUEUE_DIR}/${SESSION_ID}.txt"

if [ -f "$QUEUE_FILE" ]; then
  NEXT_PROMPT=$(head -1 "$QUEUE_FILE")

  if [ -n "$NEXT_PROMPT" ]; then
    # Remove the first line
    tail -n +2 "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    # Clean up empty file
    [ ! -s "$QUEUE_FILE" ] && rm "$QUEUE_FILE"

    jq -n --arg prompt "$NEXT_PROMPT" '{
      "decision": "block",
      "reason": $prompt
    }'
    exit 0
  fi
fi

exit 0
