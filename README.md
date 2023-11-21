![Phorion_Logo_Blue](https://github.com/PhorionTech/tcc-kronos/assets/27683329/68ee065d-d6b5-4f38-90ea-1a5514f87e02)

## Phorion Kronos

Phorion Kronos is a macOS security tool designed to enhance Apple's Transparency Consent and Control (TCC) security and privacy mechanism. By monitoring Apple log data, Kronos aims to increase transparency into TCC prompt requests, as well as TCC resource usage. Kronos also provides users with the ability to revoke TCC permissions after a given time period.

### Vision

This tool is designed to enhance, not replace the TCC mechanism. We hope to continue developing the tool and it's feature set, if you have ideas make sure to open up a PR or an issue! 

## Install

1. Drag the app bundle (`Kronos.app`) to `/Applications`.
2. Open it for first time setup, click the prompt and you should see a window like this.

![image](https://github.com/PhorionTech/Kronos/assets/15949637/640d2d5e-1a52-4356-8075-d18faa83e904)


3. Click `Install`. It should prompt you to open System Preferences. Click `Allow` in the relevent section (see screenshot).

![image](https://github.com/PhorionTech/Kronos/assets/15949637/86f469d6-6cb6-48d1-9d1e-9e27efd57b47)


4. Click `Grant`. It should open System Preferences to the Full Disk Access window. Toggle the setting for `TCCKronosExtension` to be enabled.

![image](https://github.com/PhorionTech/Kronos/assets/15949637/58808fbf-fc41-45d2-9471-a14721b5df66)

5. (Optional, but recommended)  Click `Configure` to automatically launch Kronos at startup.

6. All the red lights should now be green! 🟢 If so, everything is setup correctly.
