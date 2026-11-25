# 执行回执（Receipt）— `amb_village_rain_breeze_loop_v02`

> **文件性质**：本文件是执行 Agent 交付林间细雨环境音轨（v02 返工版）后的**结果回执与实测记录**，供另一个审核 Agent 独立复核。
> 本文件**不是**音频生成规格；规格与正向/负面提示词见上层目录：
> `../amb_village_rain_breeze_loop_v02_prompt.md`。
> 规格提示词文档保持原始纯规格文本，本回执的实测数据**未回填**到任何 `*_prompt.md`。

| 字段 | 内容 |
| --- | --- |
| 项目 | 风息村落物语（Windbreath Village），Godot 4.7.2 |
| asset_id | `AUD_AMB_VILLAGE_RAIN_BREEZE_02` |
| 对应规格 | `docs/audio_prompts/amb_village_rain_breeze_loop_v02_prompt.md` |
| 回执生成时间 | 2026-11-25 23:40（Asia/Shanghai） |
| 采用素材版本 | 抽卡候选 A（候选 B 未采用，见附录） |
| 母带状态 | 已生成；第 12 节**自动检查全部达标**；人工听审待完成；`AudioManager.gd` **尚未切换**到本轨 |
| 返工背景 | v01 经全长 60 秒高精度 FFT 复检检出全片贯穿的 50 Hz 整倍数声码器电流哨音群（2050.0 Hz +28.1 dB / 684.9×，1450/1550/1750/1900 Hz +22–24 dB，伴 329.6 Hz 杂峰），且 0–180 Hz 7.61% 偏高、末尾采样阶跃 0.00414 |

---

## 一、交付物清单

| # | 角色 | 文件路径 | 格式 / 参数 | 大小 | 状态 |
| --- | --- | --- | --- | --- | --- |
| 1 | 母带源文件（本地隔离，不打包） | `assets/audio/source/amb_village_rain_breeze_loop_v02.wav` | PCM s24le / 48000 Hz / 立体声 / 24-bit / 60.000 s | 17,280,102 B | 已生成 |
| 2 | 运行时音频（游戏加载） | `assets/audio/bgm/amb_village_rain_breeze_loop_v02.ogg` | Vorbis / 44100 Hz / 立体声 / 60.000 s / 137.3 kbps VBR | 1,029,900 B | 已生成并转码 |
| 3 | Godot 导入配置 | `assets/audio/bgm/amb_village_rain_breeze_loop_v02.ogg.import` | `loop=true`；`bpm=0`、`beat_count=0`；`uid://gnfsdw2c6tgx` | — | 已写入 |

> 母带 WAV 位于 `source/` 目录，按规格与运行时隔离，不进入 APK / PCK 包体（核验见第五节）。

---

## 二、硬指标实测对照（第 12 节自动检查）

测量对象为最终落盘母带 WAV；OGG 为同源转码。测量口径见第七节。

| # | 规格要求 | 实测值 | 判定 |
| --- | --- | --- | --- |
| 1 | 主命名符合 `[a-z0-9_]`：`amb_village_rain_breeze_loop_v02` | 命名一致 | ✅ PASS |
| 2 | WAV `48000 Hz / 24-bit Stereo`；OGG `44100 Hz Stereo`；时长 `60.000 s` | WAV 48000/24-bit/2ch；OGG 44100/2ch；均 `60.000000 s` | ✅ PASS |
| 3 | 集成响度 `-29.0 ± 1.0 LUFS` | **-29.2 LUFS**（LRA 1.1 LU） | ✅ PASS |
| 4 | True Peak `<= -6.0 dBTP` | **TPK -6.5 dBFS** | ✅ PASS |
| 5 | `0–180 Hz <= 5.0%` | **1.10%** | ✅ PASS |
| 6 | `500–3500 Hz >= 48.0%` | **81.59%** | ✅ PASS |
| 7 | `>3500 Hz <= 3.5%` | **1.76%**（4000 Hz 以上 1.02%） | ✅ PASS |
| 8 | 频谱质心 `750–1200 Hz` | **1101.4 Hz** | ✅ PASS |
| 9 | 立体声相关系数 `0.20–0.65` | **0.395** | ✅ PASS |
| 10 | 头尾 `500 ms` RMS 差 `<= 1.0 dB` | head/tail 0.0198/0.0187，**差值 0.49 dB** | ✅ PASS |
| 11 | 采样跳变 `seam_jump <= 0.002` | **0.00120** | ✅ PASS |
| 12 | 无超过 `20 ms` 头尾纯静音 | 头 0.3 ms，尾 0.0 ms | ✅ PASS |
| 13 | `.wav` 母带置于受 `.gdignore` 保护的 `source/` 且不进包 | 已隔离（见第五节） | ✅ PASS |

### 频段能量明细（STFT 功率谱，占全频段能量比）

| 频段 | 占比 |
| --- | --- |
| 0–160 Hz | 0.57% |
| 0–180 Hz | 1.10% |
| 160–350 Hz | 8.29% |
| 350–650 Hz | 16.28% |
| 650–2600 Hz | 70.47% |
| 2600–4000 Hz | 3.37% |
| 500–3500 Hz | 81.59% |
| 3500 Hz 以上 | 1.76% |
| 4000 Hz 以上 | 1.02% |
| 频谱质心 | 1101.4 Hz |

### 相对 v01 缺陷的修复结论

- v01 宏观频段、响度与宏观衔接尚可，但全长 FFT 检出整排 50 Hz 倍频神经声码器哨音与 329.6 Hz 固定音高杂峰，安静耳机下呈“电流盲音/耳鸣啸叫”；0–180 Hz 7.61% 偏浑，末尾存在 0.00414 采样阶跃。
- v02：换用无 50 Hz 格点伪影的干净天然竹叶木檐细雨底材；210 Hz 平滑高通收紧低端，500 Hz 附近 -2 dB 让位 BGM，3.1 kHz 搁架 + 3.5 kHz 24 dB/oct 低通压柔亮刺；首尾 5 ms 过零微淡 + 最外 16 样本强制归零斜坡，`seam_jump` 由 v01 的 0.00414 降至 0.00120。

---

## 三、反“电流/盲音”FFT 复检（通用硬门禁）

全长 60 秒 Hann FFT 逐点扫描 `100–6000 Hz`；以各频点局部 ±120 Hz 邻域中位数为底噪，`SNR(dB) = 10·log10(P / P_median)`。**全谱无任何窄带峰值高于本地中位数 +12.0 dB**。

### 全长 FFT 最高窄带峰

| 项目 | 值 |
| --- | --- |
| 最高窄带峰 SNR | **+3.2 dB** @ 2496.1 Hz |
| 阈值 | `<= +12.0 dB` |
| 判定 | ✅ PASS（全谱任意频点 SNR `<= +12.0 dB`，无电子嗡鸣、啸叫、风铃或音高杂峰） |

### 50 Hz 倍频 / 固定音高杂峰复检表

| 复检频点 (Hz) | SNR (dB) | 备注 |
| --- | --- | --- |
| 329.6 | 1.3 | v01 固定音高杂峰已清零 |
| 1350.0 | 0.7 | 无 50 Hz 格点哨音 |
| 1450.0 | 0.8 | v01 +24.0 dB 尖峰已清零 |
| 1550.0 | -0.1 | v01 +23.7 dB 尖峰已清零 |
| 1650.0 | 1.1 | 无 50 Hz 格点哨音 |
| 1750.0 | -1.3 | v01 +22.1 dB 尖峰已清零 |
| 1850.0 | -0.2 | 无 50 Hz 格点哨音 |
| 1900.0 | 1.3 | v01 +23.2 dB 尖峰已清零 |
| 2050.0 | 0.6 | v01 +28.1 dB / 684.9× 主峰已清零 |
| 2350.0 | -1.0 | 无 50 Hz 格点哨音 |
| 2500.0 | 3.2 | 全谱最高，仍远低于 +12 dB |
| 2950.0 | 0.8 | v01 尖峰已清零 |

> 本轨未触发高 Q 陷波：候选素材全长 FFT 即无 >+12 dB 定频线，无需陷波消除，故不存在陷波相位金属振铃风险。

---

## 四、后期处理链（可追溯）

1. 素材：60 s 生成录音（16-bit / 40000 Hz / 立体声）。
2. 预处理：裁首尾静音（头 70.5 ms / 尾 93.0 ms），`2.0 s` 等功率交叉淡化 Tail Wrap 回绕；对最终平铺音频施加慢速线性包络匹配首尾 500 ms RMS；首尾各 `5 ms` 过零点余弦微平滑，并在最外 16 样本强制线性归零斜坡（抑制重采样边界残留）；铺至精确 `60.000 s`，输出 f32le raw。
3. 母带滤波链（ffmpeg）：`highpass=f=210`（平滑高通清净低端）→ `equalizer=500 Hz g=-2`（让位 BGM 核心频段）→ `highshelf=3100 Hz g=-10`（柔化亮刺）→ `lowpass=f=3500:p=2`（24 dB/oct 压柔 3.5 kHz 以上）→ `extrastereo=m=1.15`（立体声去相关展宽）→ `loudnorm=I=-29.0:TP=-6.5:linear=true`（线性归一，关闭动态压缩以保住首尾电平平衡）；重采样 48000 Hz，24-bit PCM。
4. 转码：libvorbis VBR `-q:a 5`，44100 Hz，立体声，实测 137.3 kbps（区间 128–160 kbps）。

---

## 五、工程隔离核验

| 核验点 | 结果 |
| --- | --- |
| `assets/audio/source/.gdignore` | 存在（空文件），Godot 不导入该目录 |
| `.gitignore` | 含 `assets/audio/source/`，母带不纳入版本控制 |
| `export_presets.cfg` — Android / WindowsDesktop 预设 | 两者 `exclude_filter` 均含 `assets/audio/source/*` |
| `*.wav.import` 残留 | 无（`source/` 内仅母带 WAV 与 `.gdignore`） |
| git 跟踪状态 | `git ls-files assets/audio/source` 为空，母带未被跟踪 |

---

## 六、未改动声明（避免误判）

- **`AudioManager.gd` 未切换本轨**：环境音播放器仍加载旧轨路径，环境音增益未变。按规格，需人工听审与审核通过后再切换为本轨路径。
- **旧环境音文件未删除**：v01 溪流/细雨母带与旧轨 OGG 均保留在 `source/`、`bgm/` 目录；本轨尚未被引用。
- **规格文档未回填**：`amb_village_rain_breeze_loop_v02_prompt.md` 保持原始纯规格文本（待生成基线、验收框未勾选、无实测数值）。
- **未改动任何 GDScript / 工程代码**；本轮仅新增 v02 母带、OGG 与 `.import`。

---

## 七、复核方法（供审核 Agent 复算）

工具：`ffmpeg` / `ffprobe`（48 kHz 构建），Python 3.13 + numpy 2.5.5（环境无 scipy / soundfile / librosa）。

1. **格式 / 时长 / 码率**：
   ```
   ffprobe -show_entries format=duration,size,bit_rate \
     -show_entries stream=codec_name,sample_rate,channels,bits_per_sample <file>
   ```
2. **响度 / 真峰值**：`ffmpeg -i <wav> -af ebur128=peak=true -f null -`，读取终值 `I:`、`LRA:` 与 `True peak / Peak:`。
3. **频段占比 / 质心**：24-bit PCM 转浮点（满量程 ±1），两声道取均值；STFT 窗长 4096、汉宁窗、50% hop；功率谱 `|FFT|²`；各频段占比为对应 FFT bin 功率和 / 全频段功率和；质心 `Σf·P / ΣP`。
4. **立体声相关系数**：左右声道去均值后归一化互相关 `Σ(Lc·Rc)/√(ΣLc²·ΣRc²)`。
5. **循环接缝**：首、尾各 500 ms 样本 RMS，差值 `|20·log10(head_rms / tail_rms)|`；`seam_jump = |mono[-1] - mono[0]|`（满量程归一化）。
6. **头尾静音**：样本峰值阈值 `1e-3`，统计首尾未超阈值样本数换算为毫秒。
7. **窄带峰 / 50 Hz 复检**：全长 STFT（WIN=4096 Hann，HOP=2048）平均功率谱；100–6000 Hz；局部 ±120 Hz 中位数底噪；SNR `10·log10(P/P_median)`。

---

## 八、待人工 / 后续处理项

- [ ] 耳机下安静单独试听 2 分钟：彻底无“滋滋/嗡嗡/高频盲音哨声”，唯有洁净温柔的竹叶木檐微雨颗粒。
- [ ] 同时开启 `bgm_village_pastoral_loop_main_v02` + `amb_village_brook_wind_loop_v02` + 本轨三轨共鸣和谐通透、互不浑浊压抑。
- [ ] 手机扬声器与入耳耳机各听 60 秒衔接点，连播 3 分钟无疲惫感、无接缝。
- [ ] 对外分发前确认外部生成素材 / 采样的商业手游授权。
- [ ] 审核通过后，再将 `AudioManager.gd` 细雨播放器切换为本轨 OGG 路径。

---

## 附录：生成素材来源（追溯用）

| 版本 | 素材链接 | 备注 |
| --- | --- | --- |
| 候选 A（采用） | `https://aka.doubaocdn.com/s/vB1PVo8wif` | 首尾平稳（原始 seam 0.34 dB）、相关 0.557；无 50 Hz 格点哨音（原始 FFT worst 4.1 dB）；原始高频偏亮（4000+ 18.70%），由母带搁架与低通压柔 |
| 候选 B（未采用） | `https://aka.doubaocdn.com/s/lNpgk2f48f` | 0–160 Hz 低频堆积 46.83%、近单声道（相关 0.810）、首尾能量塌陷（seam 9.47 dB）、峰值极低，不达标 |
