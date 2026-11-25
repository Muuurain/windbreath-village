"""Offline cozy pastoral audio synthesizer for Windbreath Village.
Generates seamless looping BGM, brook & rain-chime ambient tracks, and
warm tactile wooden/pentatonic SFX using NumPy + FFmpeg -> OGG Vorbis.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import wave
from pathlib import Path
import numpy as np

SR = 44100


def find_ffmpeg() -> str:
    candidates = [
        shutil.which("ffmpeg") or "",
        r"D:\ffmpeg\ffmpeg-2025-02-26-git-99e2af4e78-full_build\ffmpeg-2025-02-26-git-99e2af4e78-full_build\bin\ffmpeg.exe",
        r"C:\Program Files\ffmpeg\ffmpeg-2025-02-26-git-99e2af4e78-full_build\ffmpeg-2025-02-26-git-99e2af4e78-full_build\bin\ffmpeg.exe",
        r"D:\FormatFactory\ffmpeg.exe",
    ]
    for p in candidates:
        if p and os.path.isfile(p):
            return p
    raise FileNotFoundError("ffmpeg.exe not found in standard paths or PATH")


FFMPEG = find_ffmpeg()
ROOT = Path(__file__).resolve().parents[1]
BGM_DIR = ROOT / "assets" / "audio" / "bgm"
SFX_DIR = ROOT / "assets" / "audio" / "sfx"


def mix(base: np.ndarray, overlay: np.ndarray, start_idx: int = 0, gain: float = 1.0) -> np.ndarray:
    if start_idx >= len(base):
        return base
    end_idx = min(len(base), start_idx + len(overlay))
    count = end_idx - start_idx
    if count > 0:
        base[start_idx:end_idx] += overlay[:count] * gain
    return base


def write_ogg(samples: np.ndarray, out_path: Path, is_loop: bool = False) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    peak = float(np.max(np.abs(samples))) if len(samples) else 1.0
    if peak > 0.92:
        samples = samples * (0.90 / peak)
    pcm = np.clip(samples * 32767.0, -32768, 32767).astype(np.int16)

    tmp_wav = out_path.with_suffix(".tmp.wav")
    with wave.open(str(tmp_wav), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(pcm.tobytes())

    bitrate = "96k" if is_loop else "80k"
    subprocess.run(
        [FFMPEG, "-y", "-loglevel", "error", "-i", str(tmp_wav), "-c:a", "libvorbis", "-b:a", bitrate, str(out_path)],
        check=True,
    )
    if tmp_wav.exists():
        tmp_wav.unlink()


def kalimba_note(freq: float, dur: float = 1.4, amp: float = 0.28) -> np.ndarray:
    t = np.linspace(0.0, dur, int(SR * dur), endpoint=False)
    attack = 1.0 - np.exp(-t * 160.0)
    decay = np.exp(-t * 3.4)
    tone = (
        np.sin(2.0 * np.pi * freq * t) * 0.72
        + np.sin(2.0 * np.pi * freq * 2.0 * t) * 0.20 * np.exp(-t * 6.5)
        + np.sin(2.0 * np.pi * freq * 3.0 * t) * 0.08 * np.exp(-t * 10.0)
    )
    return tone * attack * decay * amp


def soft_pad_chord(freqs: list[float], dur: float, amp: float = 0.08) -> np.ndarray:
    t = np.linspace(0.0, dur, int(SR * dur), endpoint=False)
    env = np.sin(np.pi * (t / dur)) ** 1.1
    sig = np.zeros_like(t)
    for f in freqs:
        sig += np.sin(2.0 * np.pi * f * t) * 0.7 + np.sin(2.0 * np.pi * (f * 2.0) * t) * 0.15
    return (sig / max(1, len(freqs))) * env * amp


def pink_noise(n: int, rng: np.random.Generator) -> np.ndarray:
    # Voss-McCartney style spectral shaping via FFT 1/f^0.65 gentle filter
    white = rng.standard_normal(n)
    spec = np.fft.rfft(white)
    freqs = np.fft.rfftfreq(n, 1.0 / SR)
    freqs[0] = 1.0
    shaped = spec / (freqs ** 0.58)
    # Band limit to cozy range (120Hz..3800Hz)
    shaped[freqs < 95.0] *= 0.2
    shaped[freqs > 4200.0] *= np.exp(-(freqs[freqs > 4200.0] - 4200.0) / 1400.0)
    out = np.fft.irfft(shaped, n=n)
    out /= max(1e-6, float(np.std(out)))
    return out


def make_loop_seamless(sig: np.ndarray, fade_sec: float = 0.45) -> np.ndarray:
    n_fade = min(int(SR * fade_sec), len(sig) // 4)
    if n_fade <= 1:
        return sig
    w = np.linspace(0.0, 1.0, n_fade)
    head = sig[:n_fade].copy()
    tail = sig[-n_fade:].copy()
    sig[:n_fade] = head * w + tail * (1.0 - w)
    return sig[:-n_fade]


def build_bgm_pastoral() -> None:
    dur = 16.0
    buf = np.zeros(int(SR * (dur + 0.5)), dtype=np.float64)
    # Warm Fmaj7 -> G6 -> Em7 -> Am7 pentatonic pastoral loop
    chords = [
        ([174.61, 220.00, 261.63, 329.63], 0.0, 4.0),
        ([196.00, 246.94, 293.66, 329.63], 4.0, 4.0),
        ([164.81, 196.00, 246.94, 293.66], 8.0, 4.0),
        ([220.00, 261.63, 329.63, 392.00], 12.0, 4.0),
    ]
    for cf, st, cd in chords:
        mix(buf, soft_pad_chord(cf, cd, 0.11), int(st * SR))

    melody = [
        (0.0, 523.25), (0.5, 659.25), (1.0, 783.99), (2.0, 659.25), (2.75, 587.33),
        (4.0, 587.33), (4.75, 659.25), (5.5, 783.99), (6.5, 880.00), (7.25, 783.99),
        (8.0, 659.25), (8.75, 587.33), (9.5, 523.25), (10.5, 587.33), (11.25, 659.25),
        (12.0, 523.25), (12.75, 440.00), (13.5, 523.25), (14.5, 659.25), (15.25, 587.33),
    ]
    for st, freq in melody:
        mix(buf, kalimba_note(freq, 1.5, 0.22), int(st * SR))

    loop = make_loop_seamless(buf[: int(SR * dur)], 0.5)
    write_ogg(loop, BGM_DIR / "bgm_pastoral_loop.ogg", is_loop=True)


def build_amb_brook() -> None:
    rng = np.random.default_rng(42)
    dur = 12.5
    n = int(SR * dur)
    t = np.linspace(0.0, dur, n, endpoint=False)
    noise = pink_noise(n, rng) * 0.14
    # Gentle water swell modulation
    mod = 0.72 + 0.28 * np.sin(2.0 * np.pi * t / 4.0) * np.cos(2.0 * np.pi * t / 2.4)
    sig = noise * mod
    # Occasional soft water droplet resonance
    for idx in range(28):
        pos = int((idx * 0.42 + rng.uniform(0.05, 0.25)) * SR)
        f = rng.uniform(720.0, 1450.0)
        dt = np.linspace(0.0, 0.08, int(SR * 0.08), endpoint=False)
        drop = np.sin(2.0 * np.pi * (f + dt * 900.0) * dt) * np.exp(-dt * 42.0) * 0.045
        mix(sig, drop, pos)
    loop = make_loop_seamless(sig, 0.5)
    write_ogg(loop, BGM_DIR / "amb_brook_loop.ogg", is_loop=True)


def build_amb_rain_chime() -> None:
    rng = np.random.default_rng(99)
    dur = 12.5
    n = int(SR * dur)
    rain = pink_noise(n, rng) * 0.11
    chime_freqs = [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50]
    for step in [1.1, 3.2, 5.4, 7.6, 9.8, 11.1]:
        freq = chime_freqs[int(step * 3) % len(chime_freqs)]
        mix(rain, kalimba_note(freq, 1.8, 0.09), int(step * SR))
    loop = make_loop_seamless(rain, 0.5)
    write_ogg(loop, BGM_DIR / "amb_rain_chime_loop.ogg", is_loop=True)


def build_sfx_all() -> None:
    rng = np.random.default_rng(7)

    # 1. Soft UI click
    t = np.linspace(0.0, 0.09, int(SR * 0.09), endpoint=False)
    click = np.sin(2.0 * np.pi * (540.0 * np.exp(-t * 14.0)) * t) * np.exp(-t * 48.0) * 0.42
    write_ogg(click, SFX_DIR / "sfx_ui_click.ogg")

    # 2. Tile select
    t = np.linspace(0.0, 0.12, int(SR * 0.12), endpoint=False)
    sel = (np.sin(2.0 * np.pi * 440.0 * t) * 0.7 + np.sin(2.0 * np.pi * 660.0 * t) * 0.3) * np.exp(-t * 34.0) * 0.45
    write_ogg(sel, SFX_DIR / "sfx_tile_select.ogg")

    # 3. Tile rotate (gentle wooden tick)
    t = np.linspace(0.0, 0.11, int(SR * 0.11), endpoint=False)
    rot = np.sin(2.0 * np.pi * (380.0 + t * 1400.0) * t) * np.exp(-t * 36.0) * 0.35
    rot += pink_noise(len(t), rng) * np.exp(-t * 45.0) * 0.06
    write_ogg(rot, SFX_DIR / "sfx_tile_rotate.ogg")

    # 4. Tile place (soft earthy thump + warm harmonic)
    t = np.linspace(0.0, 0.28, int(SR * 0.28), endpoint=False)
    thump = np.sin(2.0 * np.pi * (170.0 * np.exp(-t * 12.0)) * t) * np.exp(-t * 22.0) * 0.52
    chime = kalimba_note(523.25, 0.28, 0.22)
    write_ogg(thump + chime, SFX_DIR / "sfx_tile_place.ogg")

    # 5. Edge match (crisp twin chime)
    buf = np.zeros(int(SR * 0.45), dtype=np.float64)
    mix(buf, kalimba_note(659.25, 0.36, 0.30), 0)
    mix(buf, kalimba_note(783.99, 0.38, 0.30), int(0.06 * SR))
    write_ogg(buf, SFX_DIR / "sfx_edge_match.ogg")

    # 6. Synergy trigger (warm pentatonic arpeggio)
    buf = np.zeros(int(SR * 0.75), dtype=np.float64)
    for i, f in enumerate([523.25, 659.25, 783.99, 1046.50]):
        mix(buf, kalimba_note(f, 0.55, 0.28), int(i * 0.075 * SR))
    write_ogg(buf, SFX_DIR / "sfx_synergy_chime.ogg")

    # 7. Resource bubble pop
    t = np.linspace(0.0, 0.14, int(SR * 0.14), endpoint=False)
    pop = np.sin(2.0 * np.pi * (480.0 + t * 2400.0) * t) * np.exp(-t * 32.0) * 0.36
    write_ogg(pop, SFX_DIR / "sfx_resource_pop.ogg")

    # 8. Craft wonder landmark
    buf = np.zeros(int(SR * 1.15), dtype=np.float64)
    for i, f in enumerate([440.00, 523.25, 659.25, 783.99, 1046.50]):
        mix(buf, kalimba_note(f, 0.85, 0.27), int(i * 0.09 * SR))
    write_ogg(buf, SFX_DIR / "sfx_craft_wonder.ogg")

    # 9. Resident join
    buf = np.zeros(int(SR * 0.72), dtype=np.float64)
    for i, f in enumerate([587.33, 783.99, 880.00]):
        mix(buf, kalimba_note(f, 0.50, 0.30), int(i * 0.10 * SR))
    write_ogg(buf, SFX_DIR / "sfx_resident_join.ogg")

    # 10. Chapter clear fanfare (gentle serene resolution)
    buf = np.zeros(int(SR * 1.65), dtype=np.float64)
    mix(buf, soft_pad_chord([261.63, 329.63, 392.00, 523.25], 1.5, 0.18), 0)
    for i, f in enumerate([523.25, 659.25, 783.99, 1046.50, 1318.51]):
        mix(buf, kalimba_note(f, 1.0, 0.26), int(i * 0.12 * SR))
    write_ogg(buf, SFX_DIR / "sfx_chapter_clear.ogg")


if __name__ == "__main__":
    build_bgm_pastoral()
    build_amb_brook()
    build_amb_rain_chime()
    build_sfx_all()
    print("Generated 3 BGM/ambient loops and 10 SFX cleanly.")
