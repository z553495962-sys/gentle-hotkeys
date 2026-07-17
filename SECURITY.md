# Security Policy

Gentle Hotkeys can call OpenRouter first and fall back to a local Ollama server.

## Reporting

Please do not open public issues for sensitive vulnerabilities. Contact the maintainer privately first.

## Data Handling

- Selected text is copied to the local clipboard.
- If an OpenRouter key is configured, selected text is sent to `https://openrouter.ai/api/v1/chat/completions` first.
- If OpenRouter is unavailable, invalid, out of quota, or no key is configured, the tool falls back to `http://localhost:11434/api/chat`.
- The `.openrouter_key` file is ignored by git and should not be committed.
- Logs do not intentionally store selected text, but local application logs should still be treated as private.
