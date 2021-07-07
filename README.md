#  KiWings

## Introduction
Its a front-end for `kiwix-serve`. That's it. The uninitiated may read on. Others can skip the rest of this section.

The name is based on and closely resembles the underlying project this UI is based upon - [Kiwix](https://www.kiwix.org/). It is an open-source tool that allows you to read offline copies of fantastic content like Wikipedia (its a 80GB download), TED Talks etc. The product does what it is advertised to do, but it could indeed use a lot of improvements. For example: the Kiwix app (on macOS at least), is unable to view TED videos (no audio 😕).

### Probing Further
The Kiwix team also releases a command-line tool called `kiwix-serve`, which can serve as a server that can serve content from a given URL and port (e.g. localhost:8080). The benefit of using this tool is that it is lightweight and you can view all your content in the web-browser. And I can finally play my TED zims, at least on chromium-based browsers like Edge and Google Chrome. Unfortunately, it doesn't work in Safari. So, it seems one needs Chromium Engine to view TED videos on Kiwix.

### Going even further
`kiwix-serve` is compatible with macOS, but the Kiwix team doesn't release any fat binaries for macOS yet due to some differences in how compilation works on macOS compared to other OSes. They are working on it though, but they've got their hands pretty full of other things. Luckily, I've managed to build fat binaries for `kiwix-serve` and other `kiwix-tools` and I've tested that things work well, at least on the latest version of macOS Big Sur 11.4 (too lazy to test backwards compatibility in a VM).

## Why this tool?
What can I say,
- I am not adapted well to the command-line
- I wanted to learn macOS/iOS app development
- I had time to kill
- I wanted to write one

> 🔥Please be advised, THIS TOOL IS NOT TESTED FOR GENERAL USE. On my part, I'm releasing the tool as a sandboxed app, but this tool is RELEASED AS IS, WITH NO WARRANTY - IMPLIED OR OTHERWISE. Being a sandboxed app, there's not much damage this app can do (it doesn't write anywhere, only has read-only permission for your ZIM files). Still, its better to exercise caution.
> 
> If you feel some things like LICENSE, CREDITS etc. are missing, rest assured, I'm taking my time adding them to the app. Remember, this is still a work in progress.

## Features
- Written in AppKit and SwiftUI.
- Sandboxed. So it has lesser chances of damaging your computer if it is compromised.
- Menu bar app that's available when you need it.
- Automatically detects installed browsers on your machine, and allows you to launch your content library from any of them.
- Open-source, so you can change what you don't like instead of filing a bug report with me.
- Exclusive, me-approved UI - tailored for my personal tastes.

## Screenshots
Default startup                            |  Kiwix Running
:-----------------------------------------:|:------------------------------------------:
![](./screenshots/Screenshot-Stopped.png)  |  ![](./screenshots/Screenshot-Running.png)


## Installation
- Download the latest release from [here](https://github.com/mkathuri/kiwings/releases/download/1.0/Kiwings-1.0.zip).
- Extract the zip file. On macOS, double-clicking a zip file extracts it by default.
- Copy the resultant application bundle into your Applications folder.

I'll see if I can release a DMG file in the future. Hopefully, existing macOS users will find things easier then. :smile:

## Build Instructions
TBA

## Wishes
I would love to host this app on the macOS App Store (and avail all the nice features like automatic updates), once I have some money to enroll into Apple's Developer Program. 99 USD/yr ain't exactly cheap.

## I've got feedback
Great. Unfortunately I've run out of time to kill. So, it may not be possible for me to attend to your concerns. Feel free to raise a GitHub issue, I'll see what I can do about it. NO GUARANTEES.
