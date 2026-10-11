---
title: Processing, Python Mode
description: Install Python Mode in Processing 4, know the two things Jython needs, open a starter.
sidebar_position: 3
---

# Processing, Python Mode

Install [Processing 4](./processing-java.md#install-processing-4) first. Then:

1. Click the mode dropdown at the top right of the Processing window. It says Java.
2. Choose Manage Modes.
3. Select Python Mode for Processing 4 and press Install. It is a few tens of megabytes.
4. Pick Python from the same dropdown.

On Processing 3.5.4 install "Python Mode for Processing 3" instead.

## What Python Mode is

Jython, which is Python 2.7. No f-strings, and every example starts with
`from __future__ import division, print_function`. It can call any Java class, which is how the
helpers reach `javax.sound.midi`.

## Two things that bite

Processing 4 decides a sketch's mode from a `sketch.properties` file in the sketch folder, not from the
`.pyde` extension. Every Python sketch in the repo ships one. If your own Python sketch opens in Java
mode and crashes the editor, add this two-line file next to it:

```properties title="sketch.properties"
mode=Python
mode.id=jycessing.mode.PythonMode
```

If your own sketch imports `javax.sound.midi` directly, put this before the import, or Java 17 throws
`InaccessibleObjectException`. The helpers already do it.

```python
from org.python.core import Options
Options.respectJavaAccessibility = True
```

## The helpers

Each starter folder carries `midicore.py` and the device's module. Copy them next to your own `.pyde`.
Pass `this` to the constructor, `PipSqueak(this)`, so the helper can update itself once a frame. Names
are snake_case: `stick.just_pressed()`. The Python zip on the [Helpers](/helpers/) page has all of
them.

## Open a starter

Your [device page](/devices/) names the folder under `starters/python/`. Plug the device in, then Run.
