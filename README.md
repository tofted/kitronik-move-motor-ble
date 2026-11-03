# Kitronik :MOVE Motor V3.1 + My Controller (Bluetooth) - modified extensions

| Folder | What it is |
|---|---|
| `pxt-kitronik-ws2811-ble/` | Fork of `pxt-kitronik-ws2811` v0.0.2 with the Bluetooth-disabling config removed |
| `pxt-kitronik-move-motor-ble/` | Fork of `pxt-kitronik-move-motor` v0.4.20, depends on the fork above, adds `driveMotors(left, right)` |
| `example/` | Joystick-drive program (`main.ts`), project `pxt.json`, and a pre-compiled `.hex` |
| `docs/TECHNICAL-NOTES.md` | Investigation: why the conflict happens, interrupt masking vs Bluetooth, alternatives |
| `scripts/prepare-for-github.ps1` | Fills in your GitHub username |

## Status - read this first

| Claim | State |
|---|---|
| Original WS2811 + My Controller fails with `conflict on yotta setting microbit-dal.bluetooth.enabled between extensions bluetooth and Kitronik_WS2811` | **Reproduced** with the MakeCode compiler |
| Forks + My Controller + example **compile** for micro:bit V2 with Bluetooth enabled (`MICROBIT_DAL_BLUETOOTH_ENABLED: 1`, codal-microbit-v2) | **Done** (MakeCode target v9.0.12, built with the `makecode` CLI and MakeCode's cloud compiler) |
| `driveMotors()` produces the same frame layout as the original `motorOn`/`motorOff` | **Checked in a desktop simulation only** |
| Motors turn, Bluetooth stays connected, no resets/disconnects while driving | **NOT tested on a real buggy.** Needs your hardware test. |
| ZIP LEDs, ultrasonic, line sensors still work | **Not tested** (code unchanged from upstream) |

## Quickest test (no GitHub needed)

Copy `example/move-buggy-my-controller.hex` onto the micro:bit's `MICROBIT` drive. It is the example compiled from these exact forks. Then connect from the "my micro:bit" app and move the **left joystick**.

> First test with the wheels off the floor. If it drives backwards or steers the wrong way, flip `FORWARD_SIGN` / `STEER_SIGN` in the example (this needs the MakeCode route below). The joystick value range is configurable in the app and is not documented in the My Controller repository; the example assumes +-100 (`JOY_MAX`).

## Using the extensions in MakeCode (GitHub route)

MakeCode can only import extensions from GitHub, so the two folders need to become two repositories.

1. In PowerShell: `.\scripts\prepare-for-github.ps1 -User <your-github-name>`
2. On github.com create two **empty public** repos named exactly `pxt-kitronik-ws2811-ble` and `pxt-kitronik-move-motor-ble`.
3. Push each folder (WS2811 first) and tag the version MakeCode will pin to:
   ```bash
   cd pxt-kitronik-ws2811-ble
   git init -b master && git add . && git commit -m "Bluetooth-compatible WS2811 fork"
   git remote add origin https://github.com/<you>/pxt-kitronik-ws2811-ble.git
   git push -u origin master && git tag v0.0.3 && git push origin v0.0.3

   cd ../pxt-kitronik-move-motor-ble
   git init -b master && git add . && git commit -m "Bluetooth-compatible MOVE Motor fork"
   git remote add origin https://github.com/<you>/pxt-kitronik-move-motor-ble.git
   git push -u origin master && git tag v0.4.21 && git push origin v0.4.21
   ```
   (Or upload through the GitHub web UI and use *Releases > Create new release* with tags `v0.0.3` / `v0.4.21`.)
4. Open https://makecode.microbit.org and start a **New Project**. A project that already contains the original Kitronik MOVE Motor or WS2811 extension will conflict (same namespaces) - use a fresh project.
5. **Extensions**: paste `https://github.com/aorczyk/my-controller` and import. Then paste `https://github.com/<you>/pxt-kitronik-move-motor-ble` and import. The WS2811 fork is pulled in automatically.
6. Switch to **JavaScript**, replace the code with `example/main.ts`, download the `.hex` to the micro:bit.
7. If the app cannot connect, check MakeCode's *Project Settings* for the Bluetooth pairing mode (My Controller's README does not specify one).

## The example

`example/main.ts` uses the real My Controller API: `myController.useBluetooth()`, `myController.onCommandReceived()`, `myController.leftJoystickChanged(myController.JoystickDirection.X / .Y)`, `myController.commandValueAsNumber()`. Joystick Y/X are mixed into left/right motor speeds and sent with `Kitronik_Move_Motor.driveMotors()`. Motors stop on micro:bit button A and on Bluetooth disconnect. `MAX_SPEED` defaults to 60.

## Fallback idea (not built or compiled)

`Kitronik_WS2811.sendBuffer` is only a thin wrapper that MakeCode maps to the built-in `light.sendWS2812Buffer(buf, pin)`. If the GitHub dependency ever gives trouble, the MOVE fork could call `light.sendWS2812Buffer` directly and drop the WS2811 dependency.
