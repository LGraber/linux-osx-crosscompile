# linux-osx-crosscompile
Simple project to setup compiling for OSX from Linux

Pardon the stream of thought here as while this is public, it is a WIP and so I use this readme also as notes (still useful for others to read)

From researching around it appears that [osxcross](https://github.com/tpoechtrager/osxcross) is the standard for doing this. I tried to read through everything that was there and while it seems to be working for many people, the project had a bunch of stuff that I didn't understand or in some cases need. So I decided to try and start fresh and build up ... knowing I might end up just throwing it all away in the end and using what Thomas created. Regardless ... thanks Thomas for doing all of that work. Reading through your items is certainly helpful.

My end goal is to have a Linux-based docker image which I can use as a base image to create containers to build my source code for OSX. My source code is modern C++ (c++14 -> ), I use cmake, and I try to stay up-to-date on the target SDK. I might support older releases, but generally not more than the last 2 currently released, and that can be done with the latest SDK just using the minimum version flag. I am not interested in having something that runs on Windows nor do I currently need MacPorts. My desire is based on the ease of maintaining the Linux build environment and running in a container in the cloud versus trying to keep my OSX machines on supported OS's and keep my code compiling, too. I want to use my Macs for signing and testing and that is about it in my build farm if I can help it.

My first assumption was that ... this should just work. :) :) :) Clang says it supports cross compiling so I figured ... here we go. I created an image with Ubunut:18.04 and put clang & cmake on there and tried to build a simple "Hello World"'esque program. After a couple of fixes in my cmake toolchain file, some path fixes, and such, I found that lld was not linking. I was getting an error about "can't find libc++". Well ... libc++.tbd (text based dylib definition) was definitely in the path. After a bunch of reading, I tried simply copying libc++.tbd -> libc++.dylib and seeing if that did anything. I got a new error about libSystem not being found. This tells me that (a) the path was fine, (b) the linker understands dylibs even though I am on Linux and (c) the linker did not understand tbd files. I was pretty confused and then I started searching the internet and if your Google Foo is strong you can search for "llvm tapi lld" and find that discussions are still on going to add this support (annoying). When it is added, I bet I can simplify this stuff even further. In the meantime, I need a linker that can understand tbd files. Fortunately Apple has cctools which appears to provide this. Besides some comments on the osxcross repo, I cannot find any Apple documentation on this source. Annoying again. Building this, though, has given me a set of tools (ld64 included) that I was able to use to build a simple HelloWorld-esque app on my Linux container and run on my mac. 

Update to the above paragraph ... it appears that LLVM is trying to add support to lld (their linker). This is really important because the temporary solution of using an undocumented flag to build ld64 with tapi support does not work with tapi-v3. I tried using this repo to build with an SDK from Mojave and it fails cause it can't recognize the file format. It does work with earlier SDKs.

I imagine that I will refine things as I go a bit here. Just wanted to check it in and track my progress and understanding.

Follow this thread to see when lld will get support for tapi which will make things much easier (if Apple will help maintain it)
========================================================
Actual steps needed to use this
clone the git repo locally
cd to linux-osx-crosscompile
docker image build --tag "name" .
