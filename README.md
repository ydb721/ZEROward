# ZEROward

Windows PC Security Diagnostic & Installer Prototype

## Features
- Local CPU, memory, and disk diagnostics
- Read-only Windows network and firewall status
- Windows System and Application event log summaries
- ALEKOV ZTNA/XDR training functionality

## Windows Installer
The installer source is available in `installer/`.

The prototype installer packages Node.js and launches the
local application in the default web browser.

## Limitations
This release is based on the ALEKOV 22-stage project.
It does not yet include the separately developed ZEROward
dashboard, Defender module, or a native desktop window.

## Security
Local diagnostics do not guarantee that the PC is secure.
External ALEKOV services may remain disconnected.
