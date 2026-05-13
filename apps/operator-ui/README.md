# AIOffice Operator UI

React + TypeScript + Vite shell for the R19 product reset operator console.

## Setup

```bash
cd apps/operator-ui
npm install
```

## Run

```bash
npm run dev
```

The dev server defaults to `http://127.0.0.1:5173`.

## Backend URL

The UI expects the orchestrator API at `http://localhost:8000` by default.

To override it:

```bash
set VITE_AIO_API_BASE_URL=http://127.0.0.1:8000
npm run dev
```

On Unix-like shells:

```bash
VITE_AIO_API_BASE_URL=http://127.0.0.1:8000 npm run dev
```

## Current limitations

- No authentication or routing yet.
- No long-lived state management yet.
- Create-card and create-work-order flows are backend-only in this slice.
- No OpenAI or Codex API invocation is implemented.
- This proves local UI-to-API connectivity only, not full product runtime.
