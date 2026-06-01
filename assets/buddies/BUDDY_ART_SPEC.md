# Buddy illustration spec

This file is the brief for whoever's drawing the real buddies — human or AI. The placeholder PNGs already in this folder satisfy the Flutter build today; replace them in-place (same filenames, same sizes) when the real art is ready.

## Buddies

Five animals. Pick one personality cue per buddy and let the drawings reflect it — the app's copy already leans into these.

| Buddy     | Vibe                  | Default light theme | Default dark theme |
|-----------|-----------------------|---------------------|--------------------|
| Fox       | Clever, lightly playful | Sunrise (terracotta) | Mulberry (warm wine) |
| Cat       | Cool, approving       | Petal (rose / cream) | Mulberry (warm wine) |
| Dog       | Earnest, warm         | Meadow (sage)       | Forest (deep green + amber) |
| Butterfly | Light, encouraging    | Sky (powder blue)   | Midnight (lifted indigo) |
| Snake     | Calm, deliberate      | Meadow (sage)       | Forest (deep green) |

The default-theme columns are *suggestions* — the user can pick any palette they like. The buddy art doesn't need to match a single color; pick whatever reads well across all 7 palettes.

## Style direction

- Match the app's clean Material 3 look: flat or lightly textured. No harsh outlines.
- Warm, encouraging expressions. Not cute-to-the-point-of-saccharine.
- Forward-facing or 3/4 view, head and shoulders. No full bodies needed for v1.
- **No text, no overlays, no logos** inside the image. The app draws labels separately.
- Transparent PNG background. Square canvas.
- Read at thumbnail size — the buddy face is shown as small as ~64 dp on the device, so silhouette matters more than fine detail.

## Sizes & filenames

All PNG, transparent background, square canvas. Filenames are exact — the app loads them by path.

### Per-buddy in-app avatars

Four poses per buddy, **480 × 480 px**, transparent background. Drop into the matching folder:

```
assets/buddies/fox/idle.png
assets/buddies/fox/cheer.png
assets/buddies/fox/sleepy.png
assets/buddies/fox/curious.png
```

…and the same for `cat/`, `dog/`, `butterfly/`, `snake/`.

Pose meanings:

| Pose      | When it's shown                                   | Suggested expression               |
|-----------|---------------------------------------------------|------------------------------------|
| `idle`    | Default greeting on the Today screen, profile picker | Calm, looking forward, gentle smile |
| `cheer`   | After the user marks a habit done                 | Eyes lit up, hands/paws raised, celebrating |
| `sleepy`  | Quiet hours / "no reminders right now" surface    | Eyes closed or half-closed, content |
| `curious` | Empty states ("no habits yet") and picker preview | Head tilted, ears/antennae up, attentive |

### Notification large icons

One per buddy, **512 × 512 px**, transparent background. These are what the Android notification shows in its body. The placeholder is a tinted circle; the final can be the same face as `idle.png` cropped tighter so the buddy fills more of the canvas (it'll be shown at ~64 dp).

```
assets/buddies/icons/fox.png
assets/buddies/icons/cat.png
assets/buddies/icons/dog.png
assets/buddies/icons/butterfly.png
assets/buddies/icons/snake.png
```

### Launcher icon foregrounds

One per buddy, **432 × 432 px**, transparent background. These become the foreground layer of the Android adaptive launcher icon (Phase 4 generates the mipmap variants from these). **Center the buddy inside the inner 264 px square** — Android masks the launcher icon with various shapes (circle, squircle, rounded square), and anything outside the safe zone may be cropped on some launchers.

```
assets/buddies/launcher/fox.png
assets/buddies/launcher/cat.png
assets/buddies/launcher/dog.png
assets/buddies/launcher/butterfly.png
assets/buddies/launcher/snake.png
```

The background of the adaptive icon is filled by code with the buddy's default palette color, so the foreground PNG must be **transparent outside the buddy silhouette** — don't include a colored disc; the launcher draws that.

### Optional: master source

If you're iterating, keep a 1024 × 1024 master per (buddy, pose) outside this folder so you can re-export sharper versions later. Don't commit those — they bloat the APK.

## Quick sanity check before delivery

1. Drop a new PNG over an existing placeholder.
2. Open the app on a device.
3. Profile → Buddy & look → tap that buddy. The picker thumbnail should show the new art.
4. The launcher icon and notifications won't reflect changes until Phase 4 / Phase 5 ship — that's expected.
