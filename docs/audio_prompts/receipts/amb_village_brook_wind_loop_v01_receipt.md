# 执行回执（Receipt）— `amb_village_brook_wind_loop_v01`

> **文件性质**：本文件是执行 Agent 交付溪流微风环境音轨后的**结果回执与实测记录**，供另一个审核 Agent 独立复核。
> 本文件**不是**音频生成规格；规格与正向/负面提示词见上层目录：
> `../amb_village_brook_wind_loop_v01_prompt.md`。
> 规格提示词文档保持原始纯规格文本，本回执的实测数据**未回填**到任何 `*_prompt.md`。

| 字段 | 内容 |
| --- | --- |
| 项目 | 风息村落物语（Windbreath Village），Godot 4.7.2 |
| asset_id | `AUD_AMB_VILLAGE_BROOK_WIND_01` |
| 对应规格 | `docs/audio_prompts/amb_village_brook_wind_loop_v01_prompt.md` |
| 回执生成时间 | 2026-11-25 23:10（Asia/Shanghai） |
| 采用素材版本 | 抽卡候选 B（候选 A 仅作对比，未采用） |
| 母带状态 | 已生成；第 12 节**自动检查全部达标**；人工听审待完成；`AudioManager.gd` **尚未切换**到本轨 |

---

## 一、交付物清单

| # | 角色 | 文件路径 | 格式 / 参数 | 大小 | 状态 |
| --- | --- | --- | --- | --- | --- |
| 1 | 母带源文件（本地隔离，不打包） | `assets/audio/source/amb_village_brook_wind_loop_v01.wav` | PCM s24le / 48000 Hz / 立体声 / 24-bit / 60.000 s | 17,280,102 B | 已生成 |
| 2 | 运行时音频（游戏加载） | `assets/audio/bgm/amb_village_brook_wind_loop_v01.ogg` | Vorbis / 44100 Hz / 立体声 / 60.000 s / 141.7 kbps VBR | 1,063,013 B | 已生成并转码 |
| 3 | Godot 导入配置 | `assets/audio/bgm/amb_village_brook_wind_loop_v01.ogg.import` | `loop=true`；`bpm=0`、`beat_count=0`（环境音非节拍）；`uid://b7klpse8ajcum` | — | 已写入 |

> 母带 WAV 位于 `source/` 目录，按规格与运行时隔离，不进入 APK / PCK 包体（核验见第四节）。

---

## 二、硬指标实测对照（第 12 节自动检查）

测量对象为最终落盘母带 WAV；OGG 为同源转码。测量口径见第六节。

| # | 规格要求 | 实测值 | 判定 |
| --- | --- | --- | --- |
| 1 | 主命名符合 `[a-z0-9_]`：`amb_village_brook_wind_loop_v01` | 命名一致 | ✅ PASS |
| 2 | WAV `48000 Hz / 24-bit Stereo`；OGG `44100 Hz Stereo`；时长 `60.000 s`（±0.2 s） | WAV 48000/24-bit/2ch；OGG 44100/2ch；均 `60.000000 s` | ✅ PASS |
| 3 | 集成响度 `-28.0 ± 1.5 LUFS` | **-29.5 LUFS**（LRA 5.0 LU） | ✅ PASS（处于区间下限） |
| 4 | True Peak `<= -6.0 dBTP` | **TPK -6.5 dBFS**（次声道 -6.5） | ✅ PASS |
| 5 | `0–160 Hz <= 8%` | **6.90%** | ✅ PASS |
| 6 | `>4000 Hz <= 3.0%` | **0.00%** | ✅ PASS |
| 7 | 立体声相关系数 `0.25–0.72` | **0.560** | ✅ PASS |
| 8 | 头尾 `500 ms` RMS 差 `<= 1.5 dB` | head/tail 0.0200/0.0233，**差值 1.36 dB** | ✅ PASS |
| 9 | 无超过 `20 ms` 头尾纯静音 | 头 0.2 ms，尾 0.0 ms | ✅ PASS |
| 10 | `.wav` 母带置于受 `.gdignore` 保护的 `source/` 且不进包 | 已隔离（见第四节） | ✅ PASS |

### 频段能量明细（STFT 功率谱，占全频段能量比）

| 频段 | 占比 |
| --- | --- |
| 0–160 Hz | 6.90% |
| 160–350 Hz | 66.20% |
| 350–650 Hz | 18.31% |
| 650–2600 Hz | 8.56% |
| 2600–4000 Hz | 0.01% |
| 4000 Hz 以上 | 0.00% |
| 频谱质心 | 339.6 Hz |

### 相对旧版缺陷的修复结论

- 旧 `amb_brook_loop.ogg`：单声道程序粉噪（120–4000 Hz 平坦度 0.580）叠加 `sin*cos` 调幅与 720–1450 Hz 正弦脉冲，响度 ~-20 LUFS、31.7% 为 <120 Hz 轰鸣，具收音机电流盲音质感。
- 本轨：纯无固定音高自然溪流 + 远风拟音，无钟铃/哨音/合成脉冲；高通 160 Hz 切除低频轰鸣，3.5 kHz 以上滚降，4000+ 占比 0.00%；立体声相关系数 0.560，为真立体声底床而非单声道噪声壁。

---

## 三、后期处理链（可追溯）

1. 素材：60 s 生成录音（16-bit / 40000 Hz / 立体声）。
2. 预处理：裁首尾静音（头 69.9 ms / 尾 89.7 ms），`2.0 s` 等功率交叉淡化 Tail Wrap 回绕；对最终平铺音频施加慢速线性包络匹配首尾 500 ms RMS，铺至精确 `60.000 s`，输出 f32le raw。
3. 母带滤波链（ffmpeg）：`highpass=f=170` → `equalizer=550 Hz g=-2 dB`（让位 BGM 核心频段）→ `equalizer=1000 Hz g=+2 dB`（补 650–2600 Hz 水花颗粒）→ `highshelf=3500 Hz g=-12 dB`（高频滚降）→ `extrastereo=m=1.3`（立体声去相关展宽）→ `loudnorm=I=-28.0:TP=-6.5:linear=true`（线性归一，关闭动态压缩以保住首尾电平平衡）；重采样 48000 Hz，24-bit PCM。
4. 转码：libvorbis VBR `-q:a 6`，44100 Hz，立体声，实测 141.7 kbps（区间 128–160 kbps）。

> 说明：候选 B 素材原始低频（0–160 占 83.12%）与中高频颗粒偏薄，低频堆积由高通切除，650–2600 Hz 颗粒由 1 kHz 搁架轻抬补回；候选 A 尾段能量塌陷、近单声道，未采用。

---

## 四、工程隔离核验

| 核验点 | 结果 |
| --- | --- |
| `assets/audio/source/.gdignore` | 存在（空文件），Godot 不导入该目录 |
| `.gitignore` | 含 `assets/audio/source/`，母带不纳入版本控制 |
| `export_presets.cfg` — Android / WindowsDesktop 预设 | 两者 `exclude_filter` 均含 `assets/audio/source/*` |
| `*.wav.import` 残留 | 无（`source/` 内仅母带 WAV 与 `.gdignore`） |
| 空 `stems/` 目录 | 不存在 |
| git 跟踪状态 | `git ls-files assets/audio/source` 为空，母带未被跟踪 |

---

## 五、未改动声明（避免误判）

- **`AudioManager.gd` 未切换本轨**：第 71–72 行 `_brook_player` 仍加载旧 `res://assets/audio/bgm/amb_brook_loop.ogg`，第 92 行增益 `amb_volume * 0.45` 未变。按规格，需人工听审与审核通过后再切换为本轨路径。
- **旧环境音文件未删除**：`amb_brook_loop.ogg`、`amb_rain_chime_loop.ogg` 保留在 `bgm/` 目录；本轨尚未被引用。
- **规格文档未回填**：`amb_village_brook_wind_loop_v01_prompt.md` 保持原始纯规格文本（待生成基线、验收框未勾选、无实测数值）。
- **自动化测试**：Godot headless 测试套件本轮复跑，**全部 PASS、0 失败**（exit code 0）；未改动任何 GDScript。

---

## 六、复核方法（供审核 Agent 复算）

工具：`ffmpeg` / `ffprobe`（48 kHz 构建），Python 3.13 + numpy 2.5.5（环境无 scipy / soundfile / librosa）。

1. **格式 / 时长 / 码率**：
   ```
   ffprobe -show_entries format=duration,size,bit_rate \
     -show_entries stream=codec_name,sample_rate,channels,bits_per_sample <file>
   ```
2. **响度 / 真峰值**：`ffmpeg -i <wav> -af ebur128=peak=true -f null -`，读取终值 `I:` 与 `True peak / Peak:`。
3. **频段占比 / 质心**：24-bit PCM 转浮点（满量程 ±1），两声道取均值；STFT 窗长 4096、汉宁窗、50% hop；功率谱 `|FFT|²`；各频段占比为对应 FFT bin 功率和 / 全频段功率和；质心 `Σf·P / ΣP`。
4. **立体声相关系数**：左右声道去均值后归一化互相关 `Σ(Lc·Rc)/√(ΣLc²·ΣRc²)`。
5. **循环接缝**：首、尾各 500 ms 样本 RMS，差值 `|20·log10(head_rms / tail_rms)|`。
6. **头尾静音**：样本峰值阈值 `1e-3`，统计首尾未超阈值样本数换算为毫秒。

---

## 七、待人工 / 后续处理项

- [ ] 人工听审：闭眼试听 ≥2 分钟，确认完全不像收音机雪花声/漏电嘶声/吹麦噪音，能辨认鹅卵石水花微粒与轻风拂竹叶质感。
- [ ] 与 `bgm_village_pastoral_loop_main_v02` 同时播放（默认 bgm=0.65 / amb=0.60）：木吉他与钢琴居中清澈、不被环境音盖住或糊掉，二者融为一体。
- [ ] 手机扬声器与入耳耳机各听 60 秒衔接点，连播 3 分钟无疲惫感、无接缝。
- [ ] 注意 `160–350 Hz` 占比 66.20%、质心 339.6 Hz 偏低，听审时确认整体不闷、无低频浑浊；`0–160 Hz` 6.90% 接近 8% 上限，确认无残余轰鸣。
- [ ] 响度 -29.5 LUFS 处于区间下限、LRA 5.0 LU 处于上限，听审确认背景层级不压过 BGM 且动态不局促。
- [ ] 对外分发前确认外部生成素材 / 采样的商业手游授权。
- [ ] 审核通过后，再将 `AudioManager.gd` 第 71–72 行切换为本轨 OGG 路径。

---

## 附录：生成素材来源（追溯用）

| 版本 | 素材链接 | 备注 |
| --- | --- | --- |
| 候选 A（未采用） | `https://aka.doubaocdn.com/s/sWk66k6UqG` | 近单声道（相关 0.899），水花颗粒弱，尾段能量塌陷（接缝 18.8 dB） |
| 候选 B（采用） | `https://aka.doubaocdn.com/s/UEKiweVmbg` | 首尾平稳、声场略宽（相关 0.800）；低频/中高频偏薄，经高通与中频搁架后期矫正 |
