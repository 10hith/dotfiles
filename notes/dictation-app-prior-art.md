# Prior art: global-hotkey dictation apps (open source)

Research note for a cross-platform (Windows + macOS) dictation app with these requirements:

- continuous / low-latency microphone capture
- WebSocket / Realtime API transcription
- global keyboard shortcut
- tray / background operation
- insert dictated text into whatever app currently has focus
- one implementation for Windows + macOS
- reuse most of the React code in a browser version later

Flow: `global hotkey → record → transcribe → insert into focused app`.

Researched 2026-09-03. Star counts are approximate as of that date.

## The landscape at a glance

| Project | Stars | Shell / UI | Hotkey | Text insertion | Transcription | License |
|---|---|---|---|---|---|---|
| [cjpais/Handy](https://github.com/cjpais/Handy) | ~31k | Tauri 2, React + TS, Rust | `rdev` | paste into focused app; `xdotool`/`wtype` on Linux | local whisper.cpp + Parakeet (batch) | MIT |
| [OpenWhispr/openwhispr](https://github.com/OpenWhispr/openwhispr) | ~6.4k | **Electron 41, React 19, TS, Tailwind v4, shadcn** | global hotkey, auto-paste | paste at cursor | whisper.cpp, sherpa-onnx, cloud BYOK (batch) | MIT |
| [epicenter-md/epicenter · Whispering](https://github.com/epicenter-md/epicenter/tree/main/apps/whispering) | ~4.8k | Tauri + **Svelte 5** | desktop-only global shortcut | native delivery / clipboard | many providers incl. Deepgram | AGPL-3.0 |
| [Open-Less/openless](https://github.com/Open-Less/openless) | ~3.4k | Tauri 2, React + TS, Rust | CGEventTap (mac), `WH_KEYBOARD_LL` (win), `rdev` (linux) | AX API focused element → streamed keystrokes, clipboard fallback | streaming ASR (Volcengine, iFlytek), local Qwen3-ASR | MIT |
| [amicalhq/amical](https://github.com/amicalhq/amical) | ~1.5k | **Electron, TS, Turborepo, Tailwind/shadcn** | floating widget + custom hotkeys | not documented | whisper.cpp local + Ollama | MIT |
| [moinulmoin/voicetypr](https://github.com/moinulmoin/voicetypr) | ~700 | Tauri 2, React 19, Zustand, Rust | push-to-talk + toggle | Rust backend, AX permission on macOS | local Whisper + OpenAI/Groq | AGPL-3.0 |
| [tover0314-w/opentypeless](https://github.com/tover0314-w/opentypeless) | ~490 | Tauri, React + TS, `cpal` | native Fn / Right Alt | keyboard simulation, Windows `SendInput`, clipboard w/ restore | **Deepgram + AssemblyAI streaming**, Groq Whisper | MIT |
| [sypsyp97/light-whisper](https://github.com/sypsyp97/light-whisper) | ~60 | Tauri 2, React 19, Python engine | F2 default | types into active window | local Qwen3-ASR + cloud | GPL-3.0 |
| [cubhe/VoiceType](https://github.com/cubhe/VoiceType) | new | WPF/.NET 10 (win) + Swift/AppKit (mac) — two native impls | Right Ctrl / Right Alt / F8 | `SendInput` + clipboard fallback | **OpenAI Realtime API over WebSocket** | MIT |

Curated list worth skimming: [primaprashant/awesome-voice-typing](https://github.com/primaprashant/awesome-voice-typing)
(also lists Voquill, Tambourine Voice, whisper-writer).

## Findings against each requirement

### One implementation for Windows + macOS
Effectively every serious project is **Tauri 2 (Rust) or Electron**. Only `cubhe/VoiceType`
maintains separate native codebases (WPF + AppKit) — the counter-example that shows the cost.
Tauri dominates (Handy, OpenLess, VoiceTypr, OpenTypeless, Whispering, light-whisper);
Electron is the minority but is where the mature React apps live.

### Reusing React in a browser build later
- **Electron + React**: OpenWhispr (React 19 + Tailwind v4 + shadcn) and Amical
  (Turborepo monorepo with `apps/` + `packages/` split) are the closest structural matches.
  Amical's monorepo split is the pattern to copy if browser reuse is a first-class goal.
- **Whispering** solved exactly this problem and is worth reading even though it's Svelte:
  it uses build-time conditional imports (`#platform/*`) where the default condition resolves
  `*.browser.ts` and the `tauri` condition resolves `*.tauri.ts`. One codebase, two targets,
  no runtime branching. Caveat: the app is mid-migration into the Epicenter monorepo and is
  documented as not currently compiling; read the ADRs, don't fork the HEAD.

### WebSocket / Realtime streaming transcription
This is the rarest feature — most projects record to a buffer and POST the whole file.
- `cubhe/VoiceType` is the only one found that documents the OpenAI Realtime path end to end:
  `wss://api.openai.com/v1/realtime?intent=transcription`, 24 kHz PCM chunks streamed while the
  hotkey is held, transcript deltas rendered live in an overlay, automatic fallback to HTTP
  transcription if the socket fails. Tiny/new repo, but the reference implementation to read.
- `opentypeless` wires Deepgram and AssemblyAI with connection reuse and warm-up (keeping the
  socket hot so the first word isn't lost) — that warm-up detail matters for perceived latency.
- `openless` uses streaming ASR providers (Volcengine, iFlytek) and, notably, *streams the
  insertion too* — text appears progressively rather than in one blob at the end.

### Inserting text into the focused app
Three approaches in the wild, in increasing order of reliability:
1. **Clipboard + synthetic Cmd/Ctrl+V** — most common, works nearly everywhere, but clobbers
   the clipboard (good implementations save and restore it: opentypeless does).
2. **Synthetic keystrokes** — `SendInput` on Windows, `CGEvent` on macOS. Slower for long text,
   and can hit UAC/elevation boundaries on Windows (VoiceType falls back to clipboard there).
3. **Accessibility API direct insertion** — find the focused element via AX APIs and set its
   value. OpenLess does this with keystroke/clipboard fallback; it's the only one documenting
   the full ladder, so `openless`'s platform modules are the best code to read here.

Both macOS paths require the app to be a trusted Accessibility client; Electron's
`globalShortcut` also needs this on macOS for some accelerators.

### Global hotkey
- Tauri: `tauri-plugin-global-shortcut`, or `rdev` (Handy) for hold-to-talk semantics.
- Electron: `globalShortcut` handles registration, but it gives *press* events, not
  press-and-hold, so push-to-talk needs a native listener.
- Low-level per-OS (OpenLess): `CGEventTap` on macOS, `WH_KEYBOARD_LL` on Windows. Required if
  you want modifier-only hotkeys (Right Alt, Fn) or true push-to-talk.

## Suggested reading order

1. **[Handy](https://github.com/cjpais/Handy)** — the reference architecture for the whole flow,
   and the most battle-tested (31k stars). Read even if you go Electron.
2. **[OpenLess](https://github.com/Open-Less/openless)** — the hard parts: per-OS hotkey capture,
   AX-based insertion with fallbacks, streamed insertion.
3. **[OpenWhispr](https://github.com/OpenWhispr/openwhispr)** — if Electron + React 19 is the
   chosen stack, this is the closest working thing to the target.
4. **[cubhe/VoiceType](https://github.com/cubhe/VoiceType)** — the Realtime-API WebSocket path,
   including the HTTP fallback.
5. **[opentypeless](https://github.com/tover0314-w/opentypeless)** — streaming provider
   abstraction over Deepgram/AssemblyAI, connection warm-up, clipboard restore.
6. **[Whispering](https://github.com/epicenter-md/epicenter/tree/main/apps/whispering)** — the
   browser/desktop code-sharing pattern (`#platform/*` conditional imports).

## Gap

Nothing found combines all of: Electron/React + realtime WebSocket streaming + first-class
browser reuse. The React/Electron apps (OpenWhispr, Amical) are batch-transcription and
local-model oriented; the streaming ones are Tauri or native. Expect to combine
OpenWhispr's shell with VoiceType's/opentypeless's streaming layer and Whispering's
platform-split module pattern.

Licensing note: MIT for Handy, OpenLess, OpenWhispr, Amical, opentypeless, VoiceType.
AGPL-3.0 for Whispering/Epicenter and VoiceTypr; GPL-3.0 for light-whisper — relevant if any
of this is going to be copied rather than merely read.
