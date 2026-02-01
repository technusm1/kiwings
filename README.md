> ⚠️ **Archived — Please switch to the official Kiwix app**
> 
> This repository is being archived. KiWings was originally intended as a temporary solution because the Kiwix macOS app did not offer sufficient features at the time. The official Kiwix app for macOS has since improved and now provides better features. Users are advised to switch to the official Kiwix app: http://apple.kiwix.org/
> 
> This repository is no longer maintained.

#  KiWings

| Field                                                                  | Info                                   |
|------------------------------------------------------------------------|----------------------------------------|
| Project Homepage | [github.com/technusm1/kiwings](https://github.com/technusm1/kiwings) |
| Description | Lightweight Kiwix alternative for macOS |
| Build status | ![Build status](https://github.com/mkathuri/kiwings/actions/workflows/main.yml/badge.svg) |
| Download latest version | [1.0-beta4](https://github.com/technusm1/kiwings/releases/download/1.0-beta4/Kiwings.1.0-beta4.dmg) |


## Introduction
KiWings is a lightweight Kiwix alternative for macOS. Kiwix is an open-source tool that allows you to read offline copies of fantastic content like Wikipedia (its a 80GB download), TED Talks etc. Orig[...]  

Under the hood, this tool is a front-end for `kiwix-serve` designed for macOS 11.3 and later. `kiwix-serve` is a tool designed by Kiwix team, which can work as a standalone content server, but as of w[...]  

**🔥WARNING: Bugs and shortcomings are unfortunately commonplace in software. On my part, I'm releasing the tool as a sandboxed app (meaning macOS will restrict its capabilities to do any damage), b[...]  

## Features
- Sandboxed. Less chances of damaging your computer. More peace of mind.
- Menu bar app that's available when you need it.
- Automatically detects different installed browsers on your machine, and allows you to conveniently access your content library from any of them (see screenshots).
- Open-source

## Screenshots

| Stopped                                                                  | Running                                   |
|---------------------------------------------------------------------------------|-----------------------------------------------|
| ![KiWings Stopped](https://github.com/technusm1/kiwings/raw/main/screenshots/Screenshot-Stopped.png) | ![KiWings Running](https://github.com/technusm1/kiwings/raw/main/screenshots/Screenshot-Running[...]  

## Installation & Requirements
- Please make sure you have macOS 11.3 or later installed on your machine.
- Download the latest release from [here](https://github.com/technusm1/kiwings/releases/download/1.0-beta4/Kiwings.1.0-beta4.dmg) (currently in beta, but should be usable).
- Open the DMG file in Finder.
- Drag and Drop the KiWings app into your Applications folder.

## Build Instructions
There are 3 simple steps:
- Checkout the project via git or download the source archive.
- Open the project in Xcode (tested on 12 and 13).
- Build it. It needs internet to fetch the underlying dependencies, so make sure you are connected to the internet.

Easy, right?

## Giving feedback
Before you raise an issue, please make sure to search the **Issues** section properly to see if there isn't any issue already filed for the problem you're facing. Being a bit busy these days, it may n[...]  

## Credits
- Kiwix team's `kiwix-tools`. Source code is available here: https://github.com/kiwix/kiwix-tools
- Sindre Sorhus's `LaunchAtLogin` package: https://github.com/sindresorhus/LaunchAtLogin
- CheckboxHeaderCell gist here: https://gist.github.com/Lessica/176c2314336fc861398de1e1045aa368
- Detecting button press in SwiftUI: https://stackoverflow.com/a/70191752/4385319
- Enumerating installed browsers on OSX: https://stackoverflow.com/a/931277/4385319
