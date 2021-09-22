#  KiWings

## Introduction
KiWings is a front-end for `kiwix-serve` that is designed for macOS 11.3 and later.

The name is based on and closely resembles the underlying project this UI is based upon - [Kiwix](https://www.kiwix.org/). It is an open-source tool that allows you to read offline copies of fantastic content like Wikipedia (its a 80GB download), TED Talks etc. The product does what it is advertised to do, but it could indeed use a lot of improvements. For example: the Kiwix app (on macOS at least), is unable to view TED videos (no audio 😕).

The Kiwix team also releases a command-line tool called `kiwix-serve`, which can serve as a server that can serve content from a given URL and port (e.g. localhost:8080). The benefit of using this tool is that it is lightweight and you can view all your content in the web-browser. `kiwix-serve` is compatible with macOS, but the Kiwix team doesn't release any standalone binaries for macOS yet due to some differences in how compilation works on macOS compared to other OSes. Lucky for me, due to the foundations already being in place, I've managed to build standalone binaries for `kiwix-serve` and other `kiwix-tools` and I've tested that things work well so far, at least on the latest versions of macOS Big Sur 11 (and 12 beta)

**🔥CAUTION: THIS TOOL IS NOT TESTED FOR GENERAL USE. Bugs and shortcomings are unfortunately commonplace in software, especially this tool, which is very much a work in progress. On my part, I'm releasing the tool as a sandboxed app (meaning macOS will restrict its capabilities to do any damage), but this tool is RELEASED AS IS, WITH NO WARRANTY - IMPLIED OR OTHERWISE.**

## Features
- Sandboxed. So it has lesser chances of damaging your computer. More peace of mind.
- Menu bar app that's available when you need it.
- Automatically detects different installed browsers on your machine, and allows you to conveniently access your content library from any of them.
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
- Checkout the project via git or download the source archive
- Open the project in Xcode (tested on 12 and 13)
- Build it.

Easy, right?

## Future plans
I would love to host this app on the macOS App Store (and avail all the nice features like automatic updates), once I have some money to enroll into Apple's Developer Program. 99 USD/yr ain't exactly cheap.

## Giving feedback
You've found an issue with this app, great. Two things you should know here: I designed this tool in accordance with my own use-cases, and I'm really short on time these days. So, it may not be possible for me to attend to your concerns in a timely. Feel free to raise a GitHub issue or send me any feedback if you'd like, I'll see what I can do about it.
I'm also currently designing some sensible logging and feedback collection into the app so that bug reports can be submitted properly. Hopefully, they'll be present by v1.0-beta2.
