#!/bin/bash
# UserPromptSubmit hook: intercepts "next:" prefixed messages and queues them
INPUT=$(cat)

PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# Check if prompt starts with "next:" (case-insensitive, with optional space)
if echo "$PROMPT" | grep -qi '^next:'; then
  # Extract everything after "next:"
  QUEUED_PROMPT=$(echo "$PROMPT" | sed 's/^[Nn][Ee][Xx][Tt]:[[:space:]]*//')

  if [ -z "$QUEUED_PROMPT" ]; then
    exit 0
  fi

  QUEUE_DIR="${CLAUDE_PLUGIN_DATA:-/tmp}/queue"
  mkdir -p "$QUEUE_DIR"
  QUEUE_FILE="${QUEUE_DIR}/${SESSION_ID}.txt"

  echo "$QUEUED_PROMPT" >> "$QUEUE_FILE"

  jq -n --arg msg "Queued: $QUEUED_PROMPT" '{
    "decision": "block",
    "reason": $msg
  }'
  exit 0
fi

exit 0
