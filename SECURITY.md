# Security Policy

Gentle Hotkeys is designed to call a local Ollama server by default.

## Reporting

Please do not open public issues for sensitive vulnerabilities. Contact the maintainer privately first.

## Data Handling

- Selected text is copied to the local clipboard and sent to `http://localhost:11434/api/chat` by default.
- No external API is called unless the user changes `config.json`.
- Logs do not intentionally store selected text, but local application logs should still be treated as private.
