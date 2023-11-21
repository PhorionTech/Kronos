![Phorion_Logo_Blue](https://github.com/PhorionTech/tcc-kronos/assets/27683329/68ee065d-d6b5-4f38-90ea-1a5514f87e02)

## Phorion Kronos

Phorion Kronos is a macOS security tool designed to enhance Apple's Transparency Consent and Control (TCC) security and privacy mechanism. By monitoring Apple log data, Kronos aims to increase transparency into TCC prompt requests, as well as TCC resource usage. Kronos also provides users with the ability to revoke TCC permissions after a given time period.

### Vision

This tool is designed to enhance, not replace the TCC mechanism. We hope to continue developing the tool and it's feature set, if you have ideas make sure to open up a PR or an issue! 

## Install

1. Drag the app bundle (`Kronos.app`) to `/Applications`.
2. Open it for first time setup, click the prompt and you should see a window like this.

<img width="910" alt="image" src="https://github.com/PhorionTech/kronos-internal/assets/15949637/bdd330d7-96af-476d-8a30-878d5aad28d5">

3. Click `Install`. It should prompt you to open System Preferences. Click `Allow` in the relevent section (see screenshot).

<img width="827" alt="Screenshot 2023-11-21 at 20 04 43" src="https://github.com/PhorionTech/kronos-internal/assets/15949637/500f3c95-82f0-4841-9ea3-3815ce76193a">

4. Click `Grant`. It should open System Preferences to the Full Disk Access window. Toggle the setting for `TCCKronosExtension` to be enabled.

<img width="461" alt="image" src="https://github.com/PhorionTech/kronos-internal/assets/15949637/a4e12d71-793b-4f95-a6b2-e79b781c7251">

5. (Optional, but recommended)  Click `Configure` to automatically launch Kronos at startup.

6. All the red lights should now be green! 🟢 If so, everything is setup correctly.
