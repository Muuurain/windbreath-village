# 执行回执（Receipt）— `bgm_village_pastoral_loop_main_v02`

> **文件性质**：本文件是执行 Agent 交付 v02 常驻田园 BGM 后的**结果回执与实测记录**，供另一个审核 Agent 独立复核。
> 本文件**不是**音乐生成规格；规格与正向/负面提示词见上层目录的提示词文件：
> `../bgm_village_pastoral_loop_main_v02_prompt.md`。
> 两份提示词规格文档（v01 / v02）保持原始纯规格文本，本回执的实测数据**未回填**到任何 `*_prompt.md`。

| 字段 | 内容 |
| --- | --- |
| 项目 | 风息村落物语（Windbreath Village），Godot 4.7.2 |
| asset_id | `AUD_BGM_VILLAGE_PASTORAL_MAIN_02` |
| 对应规格 | `docs/audio_prompts/bgm_village_pastoral_loop_main_v02_prompt.md` |
| 回执生成时间 | 2026-11-25 22:05（Asia/Shanghai） |
| 采用素材版本 | 抽卡候选 B（候选 A 仅作对比，未采用） |
| 母带状态 | 已生成；自动检查 **1 项未达标**（见第三节）；人工听审待完成；`AudioManager.gd` **尚未切换**到 v02 |

---

## 一、交付物清单

| # | 角色 | 文件路径 | 格式 / 参数 | 大小 | 状态 |
| --- | --- | --- | --- | --- | --- |
| 1 | 母带源文件（本地隔离，不打包） | `assets/audio/source/bgm_village_pastoral_loop_main_v02.wav` | PCM s24le / 48000 Hz / 立体声 / 24-bit / 80.000 s | 23,040,102 B | 已生成 |
| 2 | 运行时音频（游戏加载） | `assets/audio/bgm/bgm_village_pastoral_loop_main_v02.ogg` | Vorbis / 44100 Hz / 立体声 / 80.000 s / 137.3 kbps VBR | 1,373,394 B | 已生成并转码 |
| 3 | Godot 导入配置 | `assets/audio/bgm/bgm_village_pastoral_loop_main_v02.ogg.import` | `loop=true`，`bpm=72`，`beat_count=24`，`bar_beats=4`，`uid://dccowkktnogxd` | — | 已写入 |

> 母带 WAV 位于 `source/` 目录，按规格与运行时隔离，不进入 APK / PCK 包体（核验见第四节）。

---

## 二、硬指标实测对照

测量对象为最终母带 WAV（`source/...v02.wav`）；OGG 为同源转码。测量口径见第六节。

| # | 规格要求（v02 prompt） | 实测值 | 判定 |
| --- | --- | --- | --- |
| 1 | 节拍 `72 BPM`、`4/4` 拍、`F Major`、≥24 小节、时长 `80.000 s`（±0.05 s） | `.import` 标注 72 BPM / 24 小节 / 4 拍；`duration=80.000000 s` | ✅ PASS |
| 2 | 母带 `48000 Hz / 24-bit PCM / 立体声` | `pcm_s24le`，48000 Hz，2 ch，24-bit | ✅ PASS |
| 3 | 运行时 `44100 Hz / Vorbis 128–160 kbps VBR / 立体声` | `vorbis`，44100 Hz，2 ch，137.3 kbps | ✅ PASS |
| 4 | 集成响度 `-18.0 ± 1.0 LUFS` | **-17.8 LUFS**（LRA 3.6 LU） | ✅ PASS |
| 5 | True Peak `<= -1.5 dBTP` | **TPK -3.0 dBFS**（次声道 -4.5）；样本峰值 0.7076 | ✅ PASS |
| 6 | 频谱质心 `480–820 Hz` | **520.4 Hz** | ✅ PASS |
| 7 | `60–180 Hz` 低频能量 `<= 28%` | **17.25%** | ✅ PASS |
| 8 | `500–2500 Hz` 原声主体频段 `>= 30%` | **40.46%** | ✅ PASS |
| 9 | `2500–6000 Hz` 自然空气感 `1.5%–5.0%` | **0.17%** | ❌ **FAIL**（见第三节） |
| 10 | 开头 100ms 与结尾 100ms RMS 响度差 `<= 4.0 dB` | head RMS 0.0682，tail RMS 0.0570，**差值 1.56 dB** | ✅ PASS |
| 11 | 头尾无超过 `20 ms` 的纯静音 | 头 0.1 ms，尾 0.0 ms | ✅ PASS |
| 12 | 纯器乐；无人声/合唱、架子鼓/铙钹、风铃铁琴、3–6 kHz 尖锐金属谐振、合成器塑料感 | `6000+` 占 0.01%，未检出高频啸叫峰值；素材为拨弦/键盘类器乐，无人声 | ✅ PASS（待人工听审复核） |

### 频段能量明细（STFT 功率谱，占全频段能量比）

| 频段 | 占比 |
| --- | --- |
| 60–180 Hz | 17.25% |
| 180–500 Hz | 42.11% |
| 500–2500 Hz | 40.46% |
| 2500–6000 Hz | 0.17% |
| 6000 Hz 以上 | 0.01% |

### 相对 v01 缺陷的修复结论

- **发闷问题（核心）**：v01 质心 259.0 Hz、`0–500 Hz` 堆积 88.97%、`1.2–2.5 kHz` 仅 0.65%；v02 质心提升至 520.4 Hz，`500–2500 Hz` 主体频段达 40.46%，低频压控在 17.25%，中高音区轮廓已显著改善。**但** 2.5 kHz 以上空气感仍不足（第 9 项未达标）。
- **循环接缝断层**：v01 结尾淡出至 -31.14 dBFS、跳回开头 -13.25 dBFS，断层 17.9 dB；v02 采用 Tail Wrap（最后约 1.2 s 余韵叠回开头）+ 过零点对齐，首尾 100ms RMS 差 1.56 dB，未做结尾大幅渐弱。

---

## 三、未达标项：`2500–6000 Hz` 空气感频段

| 项 | 内容 |
| --- | --- |
| 实测 | `2500–6000 Hz` 占比 **0.17%**，规格区间 `1.5%–5.0%` |
| 根因 | 生成模型输出本身带强低通，该频段近乎数字静音 / 噪声底；两版抽卡素材（候选 A / B）在 2.5 kHz 以上的高频特性一致，抽卡无法改善。后期 EQ 抬升只能放大噪声底、制造嘶声，无法凭空生成琴弦泛音与木质敲击的空气感。 |
| 已排除 | 6 kHz 以上仅 0.01%，无 3–6 kHz 尖锐金属谐振、无风铃铁琴高频；未对 1–2 kHz 做激进低通一刀切。 |
| 处置建议 | 更换支持宽高频段的生成模型，或改用高质量原声尼龙弦木吉他 / 立式钢琴（C4–F5）/ 软锤马林巴采样素材，重走「裁静音 → Tail Wrap 循环对齐 → EQ/响度母带 → 48k/24-bit WAV → 44.1k Vorbis」流水线，复核 `2.5–6 kHz` 落入 1.5%–5.0% 且无啸叫。 |

---

## 四、工程隔离核验（避免 23 MB 母带进包）

| 核验点 | 结果 |
| --- | --- |
| `assets/audio/source/.gdignore` | 存在（空文件），Godot 不导入该目录 |
| `.gitignore` | 含 `assets/audio/source/`，母带不纳入版本控制 |
| `export_presets.cfg` — Android 预设 | `exclude_filter` 含 `assets/audio/source/*` |
| `export_presets.cfg` — WindowsDesktop 预设 | `exclude_filter` 含 `assets/audio/source/*` |
| `*.wav.import` 残留 | 无（`source/` 内仅有两份母带 WAV 与 `.gdignore`） |
| 空 `stems/` 目录 | 已删除，不存在 |
| git 跟踪状态 | `git ls-files assets/audio/source` 为空，母带未被跟踪 |

---

## 五、未改动声明（避免误判）

- **`AudioManager.gd` 未切换 v02**：第 61 行仍加载 `res://assets/audio/bgm/bgm_village_pastoral_loop_main_v01.ogg`，第 63 行兜底 `res://assets/audio/bgm/bgm_pastoral_loop.ogg`。按规格，需经审核通过后再人工切换到 v02。
- **环境音未改动**：`amb_brook_loop.ogg`、`amb_rain_chime_loop.ogg` 本轮未做任何处理（规格中柔化水声、移除 C 大调合成高音铃声仅为可选后续建议）。
- **规格文档未被回填**：`bgm_village_pastoral_loop_main_v01_prompt.md`、`bgm_village_pastoral_loop_main_v02_prompt.md` 均已恢复为原始纯规格文本（待生成基线、验收框未勾选、无实测数值）。
- 上一轮 Godot headless 导入后测试套件 **25 项全部通过、0 失败**；本轮未重跑测试套件，结论以历史记录为准。

---

## 六、复核方法（供审核 Agent 复算）

工具：`ffmpeg` / `ffprobe`（48 kHz 构建），Python 3.13 + numpy 2.5.5（环境无 scipy / soundfile / librosa）。

1. **格式 / 时长 / 码率**
   ```
   ffprobe -show_entries format=duration,size,bit_rate \
     -show_entries stream=codec_name,sample_rate,channels,bits_per_sample <file>
   ```
2. **响度 / 真峰值**：`ffmpeg -i <wav> -af ebur128=peak=true -f null -`，读取终值 `I:` 与 `True peak / Peak:`。
3. **频谱质心与频段占比**：读 24-bit PCM 转浮点（满量程 ±1），两声道取均值；STFT 窗长 4096、汉宁窗、50% hop；功率谱 `|FFT|²`；质心 `Σf·P / ΣP`；各频段占比为对应 FFT bin 功率和 / 全频段功率和。
4. **循环接缝**：取首、尾各 100 ms 样本计算 RMS，差值 `|20·log10(head_rms / tail_rms)|`。
5. **头尾静音**：样本峰值阈值 `1e-3`，统计首尾未超阈值样本数换算为毫秒。

> 执行用的临时探针脚本位于 Agent 临时工作区（非项目交付物）；审核时按上述口径在项目文件上复算即可。

---

## 七、待人工 / 后续处理项

- [ ] 人工听审：手机外放 + 耳机连听 ≥3 遍循环；与水声环境音、木质 UI 音效叠加检查协调性。
- [ ] 对外分发前确认 AI 音乐商用授权。
- [ ] 第 9 项（2.5–6 kHz 空气感）未达标，需按第三节建议更换模型 / 采样素材后重制复核。
- [ ] 审核通过后，再将 `AudioManager.gd` 第 61 行切换为 v02 OGG 路径。

---

## 附录：生成素材来源（追溯用）

| 版本 | 素材链接 | 备注 |
| --- | --- | --- |
| v02 候选 A（未采用） | `https://aka.doubaocdn.com/s/cOnUR1SUjW` | 原始质心 346.5 Hz，2.5–6k 0.04% |
| v02 候选 B（采用） | `https://aka.doubaocdn.com/s/JVeskBSUhw` | 原始质心 363.3 Hz，2.5–6k 0.06%；经同一 EQ 链出母带 |
| v01 素材（历史） | `https://aka.doubaocdn.com/s/gR9TbFvMAV` | 仅作缺陷对照 |
