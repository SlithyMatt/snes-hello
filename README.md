# "Hello, World!" for the Super Nintendo Entertainment System
If you're looking for the Nintendo Seal of Quality, you're gonna have a bad time.

<!-- ![Screencap from Snes9x Emulator](hello_snes9x.png) -->

To build, you need to install [cc65](https://github.com/cc65/cc65), with the
executables on your path.

Then run **build.sh** from bash, or just run the build directly on the command line:

```
cl65 -C smc.cfg -o hello.smc -l hello.list hello.asm
```

You can then load hello.smc into the SNES/SuperFamiCom emulator of your choice. It has been
tested on Linux and Windows using Snes9x. If you have an issue with any other emulator or
host environment, please post an issue to this repo. Thanks!

See the video on YouTube:
[![Hello, SNES!](http://img.youtube.com/vi/96w000yWEeI/0.jpg)](https://youtu.be/96w000yWEeI)
