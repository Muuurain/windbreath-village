# 音频生成提示词：amb_village_rain_breeze_loop_v02

> 文档性质：本文件由 `audio-prompt-spec` 规范基于 `v01` 独立深度 FFT 审核结论（[amb_village_rain_breeze_loop_v01_receipt.md](./receipts/amb_village_rain_breeze_loop_v01_receipt.md)）升级编写，仅作为音乐/音频生成 Agent 的返工修改输入规范。**`v02` 音频尚未生成**，文中目标音频路径均为计划输出路径。

## 1. 资产元信息

### 基本信息

| 字段 | 内容 |
| --- | --- |
| 项目名称 | 风息村落物语 (Windbreath Village) |
| asset_id | AUD_AMB_VILLAGE_RAIN_BREEZE_02 |
| 主文件名 | `amb_village_rain_breeze_loop_v02` |
| 资产类型 | `amb` |
| 用途 | 彻底清除 `v01` 在高精度频谱中被查出的 `50 Hz` 整倍数神经网络声码器周期性“电流盲音/哨音”群（`2050.0 Hz` 高出中位底噪 `+28.1 dB / 684.9×` 功率，`1450/1550/1750/1900 Hz` 均高出 `+22–24 dB`），收紧低频至 `<= 5%` 并平滑末尾采样接缝，产出洁净无电子嗡鸣的林间木檐细雨陪伴轨 |
| 优先级 | `P1`（与 `P0` 溪流微风 `v02` 配套验收接入） |
| 提示词版本 | `v02`（修订自 `amb_village_rain_breeze_loop_v01`） |
| 目标生成模型及版本 | 待确认（强烈建议优先切换无 `50 Hz` STFT 帧伪影的干净天然雨声源/模型；若沿用同源雨滴纹理素材，必须经过全覆盖高 Q 陷波消除与复测归零） |
| 当前状态 | 仅完成 `v02` 修订提示词文件，音频待生成 |

### 路径规则与交付路径

| 路径类别 | 路径值 | 状态 |
| --- | --- | --- |
| 1. 提示词 Markdown 完整保存路径 | `D:\Code\project\windbreath_village\docs\audio_prompts\amb_village_rain_breeze_loop_v02_prompt.md` | 已写入 |
| 2. 原始高质量音频完整输出路径 | `D:\Code\project\windbreath_village\assets\audio\source\amb_village_rain_breeze_loop_v02.wav` | 计划输出（未生成） |
| 3. 游戏运行时音频输出路径 | `D:\Code\project\windbreath_village\assets\audio\bgm\amb_village_rain_breeze_loop_v02.ogg` | 计划输出（未生成） |
| 4. 可选分轨 / 短版本 / 参考音频 / 后期工程路径 | `无` | 无 |
| 5. 项目内相对路径 / 引擎资源导入路径 | `assets/audio/bgm/amb_village_rain_breeze_loop_v02.ogg`（`res://assets/audio/bgm/amb_village_rain_breeze_loop_v02.ogg`；通过复核后再由主工程切换至 `src/autoload/AudioManager.gd`） | 计划导入路径 |

## 2. 音乐音频需求介绍

- **使用场景**：在设置面板主动勾选开启「林间细雨 / 细雨白噪音」选项时，与 `bgm_village_pastoral_loop_main_v02.ogg` 和 `amb_village_brook_wind_loop_v02.ogg` 三轨同步融合播放，或用于夜间「赏景」助眠听雨。
- **叙事背景**：柔细绵密的乡间小雨落在竹叶与传统木廊瓦片上，气氛温润恬静。
- **玩家正在做什么**：三轨环境音开启状态下长期休闲造景、聆听音乐与雨滴伴音放空休憩。
- **针对 `v01` 独立复测问题的核心修改理由**：
  1. `v01` 虽然在宏观频段（`500–3500 Hz` 占 `53.83%`，质心 `948.2 Hz`）、`-29.1 LUFS` 响度与 `0.01 dB` 宏观衔接上表现良好，**但全长 60 秒高精度 FFT 排查检出了全片贯穿的 `50 Hz` 整数倍窄带电子哨音群**（源于 `40000 Hz` 神经音频声码器帧步 artifact）：包括 `2050.0 Hz`（`-56.77 dBFS`，高出本地中位数 **`+28.1 dB`** / `684.9×` 功率，全片每 2 秒均稳定存在）、`1450.0 Hz`（`+24.0 dB`）、`1550.0 Hz`（`+23.7 dB`，相对邻点高 `122.3×`）、`1900.0 Hz`（`+23.2 dB`）、`1750.0 Hz`（`+22.1 dB`）及 `2950 Hz` 等；由于本轨本身极其轻柔（RMS ~ `-33.7 dBFS`），这类 `-56 dBFS` 级电子定频哨音会在安静耳机里直接听出轻微的“电流盲音/耳鸣啸叫”；
  2. `v01` 的 `0–180 Hz` 低频占比达 `7.61%`（距 `8%` 仅余 `0.39%`），需进一步收紧至 `<= 5.0%`，避免三轨齐开时低频发浑；
  3. 尾端单点采样有 `0.00414` 轻台阶，须用末尾 `5 ms` 过零平滑收尾。
- **与 BGM 及溪流轨三轨共存要求**：保持 **`-29.0 ± 1.0 LUFS`** 柔和低调层级，立体声宽场铺开，无固定音高、无电子哨音、无金属铃铛，三轨并播时不压音乐、不嘶刺、不撞调。

## 3. 生成风格

- **音乐类型与子类型**：Artifact-Free Natural Eaves & Bamboo Drizzle Foley（完全无电子伪影的纯天然木檐竹叶细雨拟音）
- **情绪关键词**：丝绵细润（Silky Soft Drizzle）、干净纯粹（Pure & Artifact-Free）、廊下避雨（Cozy Porch Rain）、零电流嗡鸣（Zero Electronic Hum）、静谧助眠（Restful）
- **时代或文化背景**：现代干净纯自然雨声录音质感（严禁带数字音频声码器周期网格嗡鸣、禁止暴雨雷声及铁皮撞击声）。
- **配器 / 声音元素构成**：柔和散落的竹叶细雨滴答与老木檐轻雨微滴（Soft Light Rain on Bamboo Leaves & Wooden Roof Eaves）——清晰可辨自然雨滴落叶颗粒纹理，绝非单调连续粉噪墙，**完全不含风铃、合成钟琴、风啸声或固定频率共振呜鸣**。
- **节奏与和声特征**：天然非节拍雨滴微粒散落感；**完全无固定音高**（严禁 `329.6 Hz` 固定音高嗡鸣或任何 `50 Hz` 倍频电子蜂鸣）。
- **混音质感与制作方向**：`210 Hz` 平滑高通清净低端（将 `0–180 Hz` 降至 `<= 5.0%`），柔和让渡 `480–550 Hz` 为主配乐留出净空，温和滚降 `3.2 kHz` 以上消除亮刺，彻底确保无任何 `>12 dB` 尖锐窄带峰。

## 4. 可量化音乐参数

| 参数 | 规格 | 说明 |
| --- | --- | --- |
| BPM / 拍号 / 调性 | `不适用（非节拍无固定音高纯自然细雨）` |  |
| 目标时长及允许误差 | `60.000 秒`（`±0.1 s` 误差内严格对齐 `60.000 s`） |  |
| 响度与峰值规格 | 集成响度 **`-29.0 ± 1.0 LUFS`**；True Peak `<= -6.0 dBTP`；`LRA <= 2.5 LU` | 维持柔美轻柔背景层 |
| **频谱健康升级靶标** | 频谱质心 `750–1200 Hz`；**`0–180 Hz <= 5.0%`**（比 `v01` 的 `7.61%` 更干净）；`500–3500 Hz >= 48.0%`；`>3500 Hz <= 3.5%` | 更充分确保三轨叠加底盘不糊 |
| **反 `50 Hz` 电流盲音核心硬门禁（针对 `v01`）** | 全长 60 秒高精度 FFT 检查（`100–6000 Hz`）：**全频段任何窄带峰值相对局部频段中位数的 SNR 必须 `<= +12.0 dB`**（重点逐点验证 `1350, 1450, 1550, 1650, 1750, 1850, 1900, 2050, 2350, 2500, 2950 Hz` 与相邻偏置频点无突刺！） | 必须将 `v01` 的 `+28.1 dB (684.9x)` `2050 Hz` 哨音等整排 `50 Hz` 伪影彻底清零 |
| 立体声与无缝接缝 | 立体声相关系数 **`0.20–0.65`**；头尾 `500 ms` RMS 差 `<= 1.0 dB`；采样跳变 `seam_jump <= 0.002`（`5 ms` 首尾过零平滑）；头尾静音 `< 20 ms` |  |

## 5. 结构与情绪曲线

- `0–20 秒`：干净柔顺、粒粒温润的木檐竹叶细雨平稳展开，无任何连续嗡鸣或风铃声。
- `20–40 秒`：雨丝自然微疏变化（全局 `1s` RMS 平滑稳定，无陡然大雨骤起），背景宁静。
- `40–60 秒`：维持柔和均匀微雨直至第 60.000 秒，以额外生成的 `2.0 秒` 雨声等功率回绕接入第 0 秒并施加 `5 ms` 过零平滑收尾。

## 6. 人声与歌词

- **人声策略**：纯自然环境音（无任何人声）
- **强制约束**：本音轨必须为纯粹的自然细雨拟音，**不得出现人声、念白、合唱或含歌词的声音**。

## 7. 循环与交互音乐要求

- **播放模式**：无缝循环（`loop`）
- **循环设计要求**：`2.0 秒` 等功率交叉淡化回绕至精准 `60.000 s` + 首尾 `5 ms` 过零微平滑，`seam_jump <= 0.002`、头尾 `500 ms` RMS 差 `<= 1.0 dB`。不拆 `intro` / `outro`。
- **自适应与交互要求**：在 `AudioManager` 内随时响应开关与音量滑块，无缝融于 `bgm_village_pastoral_loop_main_v02` 与 `amb_village_brook_wind_loop_v02`。

## 8. 完整生成提示词

### 中文完整正向提示词（给音频生成 Agent 的具体返工要求）

```text
请严格按 v02 规范修复或重制林间细雨环境音 `amb_village_rain_breeze_loop_v02`。v01 在雨滴颗粒（500–3500 Hz 53.83%）、立体声像与响度上已达标，但经全长 60 秒高精度 FFT 复检发现内部嵌有整排 50 Hz 倍频神经网络声码器电流哨音（2050.0 Hz 高出本地中位数 +28.1 dB / 684.9× 功率，1450/1550/1750/1900 Hz 高出 +22–24 dB，并伴随 329.6 Hz 固定音高杂峰），且 0–180 Hz 达 7.61% 偏高、末尾存在 0.00414 采样阶跃。
请执行以下返工：
1. 彻底清除电流盲音伪影：优先换用无 50 Hz 声码器网格伪影的纯净天然竹叶木檐细雨源（严禁暴雨、雷声、铁皮雨、金属风铃或带音高钟声）；若对干净雨滴纹理源（含同系列高颗粒感雨滴母材）做精细后期修复，务必对 100–6000 Hz 全谱自动检测出的所有 >+12 dB 固定窄带啸叫频点（含全部 50 Hz 整倍数如 1350–2950 Hz 及 329.6 Hz 杂峰）实施精准高 Q 陷波消除，直至全长 60 秒高分辨率 FFT 中没有任何窄带峰值高于本地频段中位数 12 dB 以上！
2. 其余指标：使用 210 Hz 干净高通将 0–180 Hz 压控至 <= 5.0%，保持 500–3500 Hz >= 48%、>3500 Hz <= 3.5%，质心 750–1200 Hz，集成响度 -29.0 ± 1.0 LUFS，True Peak <= -6.0 dBTP，立体声相关 0.20–0.65，60.000 s 等功率交叉回绕并加 5 ms 过零微淡（seam_jump <= 0.002，500ms 差 <= 1.0 dB）。
3. 交付 `amb_village_rain_breeze_loop_v02.wav`（隔离至 source/）与 `amb_village_rain_breeze_loop_v02.ogg`（bgm/），并在回执中附上完整的“全长 60 秒 FFT 最高窄带峰与 50 Hz 倍频 SNR 复检表”。严禁出现人声、念白、合唱或含歌词的声音。
```

### 英文版 generation_prompt（适用于英文优先或真实田野拟音模型）

```text
A pristine, completely artifact-free 60-second seamless-looping stereo field recording of gentle light drizzle on bamboo leaves, garden grass, and rustic wooden porch eaves, completely free of electronic hums, carrier tones, or 50Hz-grid neural vocoder whistles. Soft organic droplets on foliage and timber—NOT heavy rain, NOT thunder, NOT sharp tin roof impacts, and NOT continuous radio white/pink noise hiss. Clean frequency balance high-passed cleanly above 210 Hz (<=5% energy below 180 Hz), rich soft droplet body in 500–3500 Hz (>=48%), and gently muted highs above 3.2 kHz (<=3.5% above 3.5 kHz); strictly ZERO pitched tones, zero metallic chimes, zero bells, zero insects/birds, and strictly no vocals, no spoken word, no choir, no lyrics. Steady sleep-friendly background level (-29 LUFS integrated) with an undetectable equal-power crossfaded 60-second loop and 5ms zero-cross boundary taper.
```

## 9. 负面提示词与禁止事项

- **排除声音与元素**：人声、念白、合唱、暴雨、雷电、狂风呼啸、铁皮金属雨声、合成钟琴/风铃、**`50 Hz` 整数倍神经网络声码器啸叫网格（如 `1450/1550/1750/1900/2050/2950 Hz` 等电流盲音）**、固定频率嗡鸣（如 `329.6 Hz`）、收音机粉白噪底感。
- **排除混音与技术缺陷**：任意 `100–6000 Hz` 窄带峰值 SNR > `+12 dB`、`0–180 Hz > 5%`、`>3500 Hz > 3.5%`、末尾采样跳变 `> 0.002`、母带未与打包目录隔离。
- **冲突检查声明**：正向纯净微雨滴与负面剔除 `50 Hz` 电流啸叫网格及低频杂讯完全统一，无任何内部冲突。

## 10. 技术交付规格

| 规格项 | 源文件（Master） | 运行时文件（Runtime） |
| --- | --- | --- |
| 文件格式 | `WAV（无压缩 PCM）` | `OGG Vorbis`（`AudioStreamOggVorbis`） |
| 采样率 | `48000 Hz` | `44100 Hz` |
| 位深 / 比特率 | `24-bit PCM` | `128–160 kbps VBR` |
| 声道 | `Stereo（相关性 0.20–0.65）` | `Stereo` |
| 响度与峰值 | **`-29.0 LUFS（±1.0 LU）/ True Peak <= -6.0 dBTP`** | 同左 |
| 频段与纯度 | `0–180 <= 5.0%`；`500–3500 >= 48%`；`>3500 <= 3.5%`；**全谱窄带峰 SNR `<= +12.0 dB`** | 同左 |
| 循环精度 | 精确 `60.000 s`（等功率交叉回绕 + 5 ms 过零微淡），头尾 `500 ms` RMS 差 `<= 1.0 dB`，`seam_jump <= 0.002` | `.ogg.import` 设为 `loop=true`, `bpm=0`, `beat_count=0` |

### 后期处理要求（音频生成 Agent 必须严格落实）

1. 若选用干净新素材或基于同类纹理素材处理，务必执行全长 60 秒 `Hann` FFT 扫描（`100–6000 Hz`）检查窄带峰；发现任何超出局部中位数 `+12 dB` 的定频线（包括 `50 Hz` 格点）必须彻底换成干净源或高 Q 精准陷波清除并确认**不造成相位金属振铃**。
2. 抬升温和 `210 Hz` 高通将 `0–180 Hz` 压至 `<= 5.0%`（留出充足三轨融合余量），`500 Hz` 附近略微 `-2 dB` 让位 BGM，`3.2 kHz` 滚降压柔高频。
3. 执行 `2.0s` 等功率交叉淡化回绕并在开头/末尾各加 `5 ms` 过零点余弦微平滑。

## 11. 交付物与变体

| 序号 | 交付物角色 | 目标文件名 | 目标路径 | 状态 |
| --- | --- | --- | --- | --- |
| 1 | `v02` 修订提示词文件 | `amb_village_rain_breeze_loop_v02_prompt.md` | `D:\Code\project\windbreath_village\docs\audio_prompts\amb_village_rain_breeze_loop_v02_prompt.md` | 已写入 |
| 2 | 林间细雨母带（`v02`） | `amb_village_rain_breeze_loop_v02.wav` | `D:\Code\project\windbreath_village\assets\audio\source\amb_village_rain_breeze_loop_v02.wav` | 待生成 |
| 3 | 林间细雨运行时（`v02`） | `amb_village_rain_breeze_loop_v02.ogg` | `D:\Code\project\windbreath_village\assets\audio\bgm\amb_village_rain_breeze_loop_v02.ogg` | 待生成与转码 |

## 12. 验收标准

### 自动检查

- [ ] 命名严格符合 `amb_village_rain_breeze_loop_v02`，WAV (`48k/24-bit`) 与 OGG (`44.1k` Vorbis) 时长均为 `60.000 s`
- [ ] 集成响度 `-29.0 ± 1.0 LUFS`，True Peak `<= -6.0 dBTP`
- [ ] `0–180 Hz <= 5.0%`，`500–3500 Hz >= 48.0%`，`>3500 Hz <= 3.5%`，质心 `750–1200 Hz`
- [ ] **反 `50 Hz` 电流盲音彻底通过**：全长 60 秒 FFT (`100–6000 Hz`) 所有窄带峰值相对局部频段中位数均 **`<= +12.0 dB`**（`2050/1550/1450/1900/1750/2950 Hz` 等处再无突出尖峰）
- [ ] 头尾 `500 ms` RMS 差 `<= 1.0 dB`，`seam_jump <= 0.002`，立体声相关 `0.20–0.65`，无 `>20 ms` 头尾静音
- [ ] 母带位于受 `.gdignore` 保护的 `assets/audio/source/` 且不进导出包与 Git

### 人工听审

- [ ] 耳机下安静单独试听 2 分钟：**彻底无任何“滋滋/嗡嗡/高频盲音哨声”**，唯有洁净温柔的竹叶木檐微雨颗粒
- [ ] 同时开启 `bgm_village_pastoral_loop_main_v02` + `amb_village_brook_wind_loop_v02` + 本轨三轨共鸣和谐通透、互不浑浊压抑

## 13. 假设与待确认事项

- **为何不直接采纳 `v01` 上线**：`v01` 经我侧全长 60 秒 FFT 复检已证实含 `+28.1 dB` 的 `2050.0 Hz` 及一连串 `50 Hz` 整倍数声码器电流哨音；且目前游戏内尚无其它待改代码逻辑阻塞，一旦两套 `v02` 环境音达到上述硬指标验收通过，将统一接入 `AudioManager.gd`、清理未用的旧环境音与 `v01` 残留、跑通测试并发布新版至 GitHub。
