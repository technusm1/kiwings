#  KiWings

## Introduction
KiWings is a Kiwix alternative for macOS. Kiwix is an open-source tool that allows you to read offline copies of fantastic content like Wikipedia (its a 80GB download), TED Talks etc. The product does what it is advertised to do, but it could indeed use a lot of improvements. For example: the Kiwix app (on macOS at least), is unable to view TED videos (no audio 😕). More information about Kiwix can be found on their [website](https://www.kiwix.org/). The benefit of using this tool is that it is lightweight and you can view all your content in the web-browser.

Under the hood, it is a front-end for `kiwix-serve` that is designed for macOS 11.3 and later. `kiwix-serve` is a tool designed by Kiwix team, which can work as a standalone content server.

**🔥CAUTION: THIS TOOL IS NOT TESTED FOR GENERAL USE. Bugs and shortcomings are unfortunately commonplace in software, especially this tool, which is very much a work in progress. On my part, I'm releasing the tool as a sandboxed app (meaning macOS will restrict its capabilities to do any damage), but this tool is RELEASED AS IS, WITH NO WARRANTY - IMPLIED OR OTHERWISE.**

## Features
- Sandboxed. Less chances of damaging your computer. More peace of mind.
- Menu bar app that's available when you need it.
- Automatically detects different installed browsers on your machine, and allows you to conveniently access your content library from any of them (see screenshots).
- Open-source: It is and always will be.

## Screenshots
Default startup                            |  Kiwix Running
:-----------------------------------------:|:------------------------------------------:
![](./screenshots/Screenshot-Stopped.png)  |  ![](./screenshots/Screenshot-Running.png)


## Installation & Requirements
- Please make sure you have macOS 11.3 or greater installed on your machine.
- Download the latest release from [here](https://github.com/mkathuri/kiwings/releases/download/1.0-beta1/Kiwings-1.0.dmg) (currently in beta).
- Open the DMG file in Finder.
- Drag and Drop the KiWings app into your Applications folder.

## Build Instructions
There are 3 simple steps:
- Checkout the project via git or download the source archive.
- Open the project in Xcode (tested on 12 and 13).
- Build it. It needs internet to fetch the underlying dependencies.

Easy, right?

## Future plans
I would love to host this app on the macOS App Store (and avail all the nice features like automatic updates), once I have some money to enroll into Apple's Developer Program. 99 USD/yr ain't exactly cheap.

## Giving feedback
You've found an issue with this app, great. But before you raise an issue, please make sure to search the Issues properly to see if there isn't any issue already filed. The other thing to know here is that I designed this tool in accordance with my own use-cases, and I'm really short on time these days. So, it may not be possible for me to attend to your concerns in a timely manner. That said, your feedback is extremely valuable and appreciated.

## Credits
- Kiwix team's `kiwix-tools`. Source code is available here: https://github.com/kiwix/kiwix-tools
- Sindre Sorhus's `LaunchAtLogin` package: https://github.com/sindresorhus/LaunchAtLogin
