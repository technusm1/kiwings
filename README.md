#  KiWings

## Introduction
Its a front-end for `kiwix-serve`. That's it. The uninitiated may read on. Others can skip the rest of this section.

The name is based on and closely resembles the underlying project this UI is based upon - Kiwix. It is an open-source tool that allows you to read offline copies of fantastic content like Wikipedia (its a 80GB download), TED etc. The product does what it is advertised as, but it could indeed use a lot of improvements. For example: the Kiwix app (on macOS at least), is unable to view TED videos. Bummer.

### Probing Further
The Kiwix team also releases a command-line tool called `kiwix-serve`, which can serve as a server that can serve content from a given URL (e.g. localhost). The benefit of using this tool is that it is lightweight and opens in the web-browser. And I can finally play my TED zims, at least on chromium-based browsers like Edge and Google Chrome. Unfortunately, it doesn't work in Safari browser, whereas I haven't tested things on Firefox. All this makes you wonder - was not playing TED videos a browser compatibility issue after all?

### Going even further
`kiwix-serve` is compatible with macOS, but the Kiwix team doesn't release fat binaries for macOS due to some differences in how compilation works on macOS compared to other OSes. They are working on it though. But they've got their hands pretty full of other things. Luckily, I've managed to build fat binaries for `kiwix-serve` and other `kiwix-tools` and I've tested that things work well, at least on the latest version of macOS Big Sur 11.4 (too lazy to test backwards compatibility in a VM).

## Why this tool?
What can I say,
- I hate the command-line
- I wanted to learn macOS/iOS app development
- I had time to kill
- I wanted to write one

Please be advised, THIS TOOL IS NOT TESTED FOR GENERAL USE. On my part, I'm releasing the tool as a sandboxed app, but this tool is RELEASED AS IS, WITH NO WARRANTY. So, exercise caution, and don't be an idiot.

## Features
- Written in AppKit and SwiftUI.
- Menu bar app that's available when you need it.
- Automatically detects installed browsers on your machine, and allows you to launch your content library from any of them.
- Open-source, so you can change what you don't like instead of filing a bug report with me.
- Exclusive, me-approved UI - tailored for my personal tastes.

## Screenshots


## I've got feedback
Great. Unfortunately I've run out of time to kill. So, it may not be possible for me to attend to your concerns. Feel free to raise a GitHub issue, I'll see what I can do about it. NO GUARANTEES.
