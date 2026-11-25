# 音频生成提示词：amb_village_brook_wind_loop_v02

> 文档性质：本文件由 `audio-prompt-spec` 规范基于 `v01` 独立审核复测结论（[amb_village_brook_wind_loop_v01_receipt.md](./receipts/amb_village_brook_wind_loop_v01_receipt.md)）升级编写，仅作为音乐/音频生成 Agent 的返工修改输入规范。**`v02` 音频尚未生成**，文中目标音频路径均为计划输出路径。

## 1. 资产元信息

### 基本信息

| 字段 | 内容 |
| --- | --- |
| 项目名称 | 风息村落物语 (Windbreath Village) |
| asset_id | AUD_AMB_VILLAGE_BROOK_WIND_02 |
| 主文件名 | `amb_village_brook_wind_loop_v02` |
| 资产类型 | `amb` |
| 用途 | 修正 `v01` 实测低中频闷浊风嗡（`160–350 Hz` 占 `66.20%`、质心仅 `339.6 Hz`、`258–295 Hz` 存在 `+35 dB` 轰鸣峰、真正清晰的 `650–2600 Hz` 浅溪水花仅 `8.56%` 且 `0–60s` 动态飘移近 10 dB）问题，产出清润透亮、低沉零轰鸣的常驻浅溪与林间微风立体声底床 |
| 优先级 | `P0`（直接决定玩家一进游戏的默认环境听感是否融于 `BGM_v02`） |
| 提示词版本 | `v02`（修订自 `amb_village_brook_wind_loop_v01`） |
| 目标生成模型及版本 | 待确认（提供中英文正向/负面约束及明确素材筛选硬指标；若单模型仍反复产生低频风吼或 `50 Hz` 声码器啸叫，建议切换无伪影高清自然录音/声场素材） |
| 当前状态 | 仅完成 `v02` 修订提示词文件，音频待生成 |

### 路径规则与交付路径

| 路径类别 | 路径值 | 状态 |
| --- | --- | --- |
| 1. 提示词 Markdown 完整保存路径 | `D:\Code\project\windbreath_village\docs\audio_prompts\amb_village_brook_wind_loop_v02_prompt.md` | 已写入 |
| 2. 原始高质量音频完整输出路径 | `D:\Code\project\windbreath_village\assets\audio\source\amb_village_brook_wind_loop_v02.wav` | 计划输出（未生成） |
| 3. 游戏运行时音频输出路径 | `D:\Code\project\windbreath_village\assets\audio\bgm\amb_village_brook_wind_loop_v02.ogg` | 计划输出（未生成） |
| 4. 可选分轨 / 短版本 / 参考音频 / 后期工程路径 | `无`（不保留空 `stems/` 目录） | 无 |
| 5. 项目内相对路径 / 引擎资源导入路径 | `assets/audio/bgm/amb_village_brook_wind_loop_v02.ogg`（`res://assets/audio/bgm/amb_village_brook_wind_loop_v02.ogg`；通过复核后再由主工程接入 `src/autoload/AudioManager.gd` 并清理旧 `amb_brook_loop` 与淘汰 `v01`） | 计划导入路径 |

## 2. 音乐音频需求介绍

- **使用场景**：主菜单大厅、6 大章节箱庭建造场景、无尽禅意造景模式及「赏景」陪伴模式全程常驻播放，与 `bgm_village_pastoral_loop_main_v02.ogg`（质心 ~520 Hz、-17.8 LUFS）并轨发声。
- **叙事背景**：清浅透明的小溪流过村口鹅卵石滩、茶园与竹林边，微风轻拂竹梢草叶，柔和包裹整个海风田园村落。
- **玩家正在做什么**：在手机竖屏或桌面环境下慢节奏摆放六边形地块，配合背景音乐放空休息。
- **需要传达的情绪**：清透、微润、水石分明、温顺谦让——既没有旧版程序的收音机静电嘶声，也没有 `v01` 的“水下低沉闷风嗡”。
- **对 `v01` 审核不通过缺陷的针对性说明**：
  1. `v01` 采用的原始生成素材 `UEKiweVmbg` 本身有 `83.12%` 能量压在 `160 Hz` 以下；高通切除后，依然有 **`66.20%`（OGG `67.49%`）能量堵在 `160–350 Hz` 低风吼闷区**（`258.2 / 266.5 / 294.7 Hz` 存在 `+35–36 dB` 轰鸣谐振），而真正承载清泉鹅卵石潺潺细流与叶风沙沙声的 **`650–2600 Hz` 仅占 `8.56%`**，`2600–4000 Hz` 只有 `0.01%`，质心跌至 `339.6 Hz`——听起来更像隔着门缝的闷风管道嗡鸣，而非清浅小溪；
  2. `v01` 前 10 秒均值 `-27.95 dBFS`，到 `40–50s` 衰减至 `-31.39 dBFS`（1 秒级最小/最大跨越 **`-34.21` 到 `-24.44 dBFS`、近 `9.8 dB` 波动**），稳定性偏弱；
  3. 必须在 `v02` 中**先选对高比例清澈浅水颗粒底材**，并严防 AI 声码器常见 `50 Hz` 倍频窄带啸叫（任意窄带峰相对本地频段中位数不得高出 `> 12 dB`）。
- **开始、结束与切换条件**：`AudioManager` 启动无缝循环，受设置面板「溪流风声」滑块控制。
- **与 BGM 共存要求**：集成响度 **`-28.0 ± 1.0 LUFS`**，低切净空 `0–160 Hz <= 5%` 且 `160–350 Hz <= 25%`（避免低中频嗡鸣与吉他大提琴打架），让真立体声的 `650–2600 Hz` 清晰浅水粒感轻轻环绕在音乐外圈。

## 3. 生成风格

- **音乐类型与子类型**：Clean High-Clarity Natural Shallow Brook & Leaf Breeze Foley（清透高清晰度的自然鹅卵石浅溪流与竹叶轻风拟音）
- **情绪关键词**：清浅叮咚水石感（Crisp Pebble Trickle）、轻盈通透（Airy & Unmuffled）、无低频风嗡（Zero Wind Rumble）、安静谦让（Gentle Backing）、零电流噪（Artifact-Free）
- **时代或文化背景**：现代干净近-中场天然水溪户外录音质感（无风吹麦克风扑声、无深谷呼啸大风、无低闷管风共鸣）。
- **配器 / 声音元素构成**：
  - **主角声源（75%–80%）**：水深仅数厘米、水流平缓清澈的**山涧鹅卵石浅溪**（Shallow Gentle Trickling Brook over Small Pebbles & Mossy Stones）。重点听感在 `650–2600 Hz` 的细腻轻快小水花、小水泡滚动和轻水波拍石声，声音干爽清亮而毫无浑浊低频淤积；
  - **微风叶声（20%–25%）**：极轻柔的阳光微风拂过竹林与草丛叶梢产生的轻柔叶间气流声（Soft Whispering Foliage），重点只取叶间中高频柔和空气细节，**彻底禁用任何低于 `350 Hz` 的风吼、低音气流吹麦轰鸣或呼呼闷风**。
  - **禁用元素**：禁止大河急流、瀑布洪水、低音洞穴风声、暴雨、昆虫鸟鸣、乐器、金属风铃、正弦滴水哨音以及带 `50 Hz` 格点声码器谐波鸣叫的劣质合成音频。
- **节奏特点**：完全自然随机水石流动感（无规律节拍、无 LFO 起伏，且 60 秒宏观能量分布均匀稳定，10 秒段间落差 `<= 2.0 dB`）。
- **旋律与和声特征**：**无固定音高**，不得存在超过本地底噪 `+12 dB` 的任何共振哨音或固定嗡鸣频率（消除 `258/295 Hz` 轰鸣及 `50 Hz` 倍频电子嗡声）。
- **混音质感与制作方向**：清澈透明无染的自然声场——`200 Hz` 高通干净利落切掉低端风噪与浑浊，压平 `160–350 Hz` 闷区（占比 `<= 25%`），充分展现 `650–2600 Hz` 占主力的细腻清澈浅溪水花颗粒（占比 **`>= 40%`**），并将 `2600–4000 Hz` 保留 `3%–10%` 轻透水珠细节同时将 `>4000 Hz` 收敛在 `<= 3.0%` 防嘶刺。

## 4. 可量化音乐参数

| 参数 | 规格 | 说明 |
| --- | --- | --- |
| BPM / 拍号 / 调性 | `不适用（非节拍无固定音高自然声景）` | 不含节拍律动，不带任何固定音阶音高或共振蜂鸣 |
| 目标时长及允许误差 | `60.000 秒`（`±0.1 s` 误差内严格校准为 `60.000 s`） | 保持与 `bgm_v02 (80s)` 错开循环周期 |
| **响度与动态稳定靶标** | 集成响度 **`-28.0 ± 1.0 LUFS`**；True Peak `<= -6.0 dBTP`；`LRA <= 3.5 LU`；任意 `10 秒`分段均值极差 **`<= 2.0 dB`** | 消除 `v01` 前松后紧、高达 9.8 dB 飘移的隐患 |
| **`v02` 频谱重塑硬指标（解决 339 Hz 发闷）** | **频谱质心 `650–1250 Hz`**；**`0–160 Hz <= 5.0%`**；**`160–350 Hz <= 25.0%`**（硬门槛，彻底摆脱 `v01` 的 `66.20%` 低闷区）；**`650–2600 Hz >= 40.0%`**（水花颗粒主力区）；**`2600–4000 Hz 3.0%–10.0%`**；**`>4000 Hz <= 3.0%`** | 先从干净透亮的浅溪原素材做筛选，绝不能靠强拉低质底噪硬凑高频 |
| **反电子电流/共振硬门禁** | 全长 60 秒 STFT/FFT 检查（`100–6000 Hz`）：**任何窄带峰值不得超过局部频段中位数 `+12.0 dB`（特别严查 `50 Hz` 倍频格点与 `200–350 Hz` 闷吼峰）** | 根除收音机嗡鸣及 AI 模型周期声码器哨音 |
| 立体声与无缝衔接 | 立体声相关系数 **`0.25–0.72`**；头尾 `500 ms` RMS 差 **`<= 1.0 dB`**；采样点 `seam_jump <= 0.002`（做 `5 ms` 过零平滑）；头尾静音 `< 20 ms` |  |

## 5. 结构与情绪曲线

- `0–20 秒`：平稳展开清澈柔和的鹅卵石浅溪细流声与微弱远风竹叶感，能量保持于 `-28.0 ± 1.0 LUFS` 左右稳定区间，无前段突亢、无后段塌陷。
- `20–40 秒`：保持轻柔稳定的水花颗粒自然交互流淌，微微带有竹梢轻摇呼吸空气感，`10s` 平均波动在 `1.5 dB` 以内。
- `40–60 秒`：自然流畅延续前段密度，严禁末尾降响或轰鸣起伏；末尾多预留 `2.0 秒` 通过等功率交叉回绕接入开头第 0 秒，并在最末 `5 ms` 做过零点平滑处理。

## 6. 人声与歌词

- **人声策略**：纯自然环境音（无任何人声）
- **强制约束**：本音轨必须为纯粹的自然溪流与微风拟音，**不得出现人声、念白、合唱或含歌词的声音**。

## 7. 循环与交互音乐要求

- **播放模式**：无缝循环（`loop`）
- **循环设计要求**：`2.0 秒` 等功率交叉淡化回绕至精准 `60.000 s` 长度 + 末尾/首部 `5 ms` 过零微淡出淡入，头尾 `500 ms` RMS 差 `<= 1.0 dB`、采样跳转 `<= 0.002`。不拆 `intro` / `outro`。
- **自适应与交互要求**：与 `bgm_village_pastoral_loop_main_v02.ogg` 及 `amb_village_rain_breeze_loop_v02.ogg` 共同在 `AudioManager` 总线中稳定播放。

## 8. 完整生成提示词

### 中文完整正向提示词（给音频生成 Agent 的具体返工要求）

```text
请严格按 v02 规范重制常驻溪流微风环境音 `amb_village_brook_wind_loop_v02`，重点彻底解决 v01 “160–350 Hz 低闷轰鸣占 66.20%、质心仅 339.6 Hz、650–2600 Hz 清泉水花仅 8.56%、以及 10 秒分段衰减近 3.5 dB” 的缺陷：
1. 重新筛选或更换高质量透亮溪水底材：放弃以低频风吼为主的原始素材！必须生成或选用本来就清澈轻快、水石细节在 650–2600 Hz 充分丰富的“浅水鹅卵石小溪轻柔潺潺声（占 75% 听感）+ 极轻柔远风拂过竹叶沙响（占 25%）”。绝对不要大河瀑布声、风吹麦克风低频轰鸣、管道嗡声或收音机电流盲音。
2. 必须达成的硬性频谱与平稳指标：
   - 频谱质心必须处于 650–1250 Hz（彻底告别闷沉）；
   - 0–160 Hz <= 5.0%，160–350 Hz 严格压控至 <= 25.0%；
   - 650–2600 Hz 清泉颗粒占主体 >= 40.0%，2600–4000 Hz 保留 3.0%–10.0% 温和润泽水花细节，>4000 Hz <= 3.0% 防嘶刺；
   - 全长 60 秒 FFT 自检中 100–6000 Hz 不得出现高出局部频段中位数 12 dB 以上的任何窄带峰（严禁 50 Hz 倍频声码器哨音或 250 Hz 风嗡）；
   - 每 10 秒分段 RMS 极差 <= 2.0 dB，LRA <= 3.5 LU。
3. 无缝循环与输出要求：集成响度 -28.0 ± 1.0 LUFS，True Peak <= -6.0 dBTP，立体声相关系数 0.25–0.72；60.000 s 等功率交叉回绕并带 5 ms 过零衔接（头尾 500ms 差 <= 1.0 dB，采样跳变 <= 0.002）。输出 WAV 母带至 `assets/audio/source/`（保持 .gdignore 隔离不入包），转码 OGG 至 `assets/audio/bgm/amb_village_brook_wind_loop_v02.ogg` 并附带实测回执（含窄带峰/50Hz 格点自检结论）。严禁出现人声、乐器、风铃或鸟虫杂音。
```

### 英文版 generation_prompt（适用于英文优先或真实田野拟音模型）

```text
A crystal-clear, light, airy 60-second seamless-looping stereo field recording of a very shallow pebble brook with sparse distant gentle breeze through bamboo leaves, bright and detailed in the mid-high water band (650 Hz to 2600 Hz) with zero low-frequency mud or wind drone. Delicate crystal-clear trickling water droplets and soft gurgling over small smooth river pebbles, light breezy foliage whisper in the background—strictly NO heavy rushing river, NO waterfall, NO wind buffeting, NO pipe/room rumble below 350 Hz, and NO continuous radio static or white/pink noise hiss. Clean frequency balance centered at 650–1250 Hz with <5% sub-160Hz, <=25% 160–350Hz, >=40% 650–2600Hz organic water detail, gentle 3–10% sparkle in 2600–4000Hz, and smooth roll-off above 4 kHz—completely free of narrowband electronic whistles, 50Hz-grid codec buzz, birds, frogs, insects, chimes, bells, music, and strictly no vocals, no spoken word, no choir, no lyrics. Consistent even energy throughout all 60 seconds (-28 LUFS integrated, <=2 dB variation across 10s chunks) with an undetectable equal-power crossfade loop.
```

## 9. 负面提示词与禁止事项

- **排除声音与元素**：人声、念白、合唱、**`<350 Hz` 沉闷风吼与低频风嗡轰鸣**、暴雨瀑布急流声、喷麦爆破风、合成粉/白噪声壁（收音机盲音感）、合成滴水正弦哨音、`50 Hz` 倍频神经网络声码器窄带啸叫（`2050/1550/1450 Hz` 等电流呜鸣）、金属风铃、任何音乐或动物鸣叫。
- **排除混音与技术缺陷**：`160–350 Hz > 25%`（发闷堆积）、`>4000 Hz > 3%`（刺耳漏电嘶音）、任意 10 秒音量骤跌骤涨（差值 > 2 dB）、采样尾端跳变未过零、母带未从导出构建隔离。
- **冲突检查声明**：正向对 `650–2600 Hz` 浅水颗粒的强调与禁用“风吼闷嗡及 `>4 kHz` 嘶刺”互相协同，没有任何矛盾要求。

## 10. 技术交付规格

| 规格项 | 源文件（Master） | 运行时文件（Runtime） |
| --- | --- | --- |
| 文件格式 | `WAV（无压缩 PCM）` | `OGG Vorbis`（`AudioStreamOggVorbis`） |
| 采样率 | `48000 Hz` | `44100 Hz` |
| 位深 / 比特率 | `24-bit PCM` | `128–160 kbps VBR` |
| 声道 | `Stereo（相关性 0.25–0.72）` | `Stereo` |
| 响度与动态 | **`-28.0 LUFS（±1.0 LU）/ True Peak <= -6.0 dBTP / LRA <= 3.5 LU`** | 同左 |
| 频段与净度靶标 | `Centroid 650–1250 Hz`；`0–160 <= 5%`；`160–350 <= 25%`；`650–2600 >= 40%`；`2600–4000 3%–10%`；`>4000 <= 3%`；窄带单峰 SNR `<= +12 dB` | 同左 |
| 循环精度 | 精确 `60.000 s`（等功率交叉回绕 + 5 ms 过零微淡），头尾 `500 ms` RMS 差 `<= 1.0 dB`，`seam_jump <= 0.002` | `.ogg.import` 设为 `loop=true`, `bpm=0`, `beat_count=0` |

### 后期处理要求（音频生成 Agent 必须严格落实）

1. **前置底材验货（严禁强救“全闷素材”）**：在做任何 EQ 前必须检查原始候选文件自身在 `650–2600 Hz` 是否具备足够真实浅水流动纹理（若原始候选 80%+ 在 `<200 Hz` 且 `>650 Hz` 近乎干枯或有 `+20 dB` 窄带声码器蜂鸣，**必须更换干净高清晰度水声源或采样**，勿拿低质沉风强行硬拉均衡！）。
2. **洁净滤波与窄带除刺**：`200 Hz` 温和切低清理闷隆；视需要轻削 `250–350 Hz` 保持通透；**如存在零星窄带峰超 `+12 dB`，使用高 Q 陷波消除并再次 FFT 复测确认完全洁净**；`3.8–4.0 kHz` 以上顺滑保守衰减。
3. **平稳包络、Tail Wrap 与 5 ms 过零收尾**：保证 `0–60s` 每 10 秒平均能量差 `<= 2.0 dB`；执行 `2.0s` 等功率回绕并加 `5 ms` 首尾极短余弦微平滑使端到端采样接缝接近 `0.000`。

## 11. 交付物与变体

| 序号 | 交付物角色 | 目标文件名 | 目标路径 | 状态 |
| --- | --- | --- | --- | --- |
| 1 | `v02` 修订提示词文件 | `amb_village_brook_wind_loop_v02_prompt.md` | `D:\Code\project\windbreath_village\docs\audio_prompts\amb_village_brook_wind_loop_v02_prompt.md` | 已写入 |
| 2 | 常驻溪流微风母带（`v02`） | `amb_village_brook_wind_loop_v02.wav` | `D:\Code\project\windbreath_village\assets\audio\source\amb_village_brook_wind_loop_v02.wav` | 待生成 |
| 3 | 常驻溪流微风运行时（`v02`） | `amb_village_brook_wind_loop_v02.ogg` | `D:\Code\project\windbreath_village\assets\audio\bgm\amb_village_brook_wind_loop_v02.ogg` | 待生成与转码 |

## 12. 验收标准

### 自动检查

- [ ] 命名严格符合 `amb_village_brook_wind_loop_v02`，WAV (`48k/24-bit`) 与 OGG (`44.1k` Vorbis) 时长均为 `60.000 s`
- [ ] 集成响度 `-28.0 ± 1.0 LUFS`，True Peak `<= -6.0 dBTP`，`LRA <= 3.5 LU`，每 `10s` 分段 RMS 极差 `<= 2.0 dB`
- [ ] **频谱重塑彻底通过**：质心 `650–1250 Hz`；`0–160 Hz <= 5.0%`；`160–350 Hz <= 25.0%`；`650–2600 Hz >= 40.0%`；`2600–4000 Hz 3.0%–10.0%`；`>4000 Hz <= 3.0%`
- [ ] **反电流啸叫自检通过**：全长 60 秒 FFT (`100–6000 Hz`) 所有窄带峰值相对局部频段中位数均 **`<= +12.0 dB`**，无 `50 Hz` 格点电流呜鸣与 `250 Hz` 嗡鸣
- [ ] 头尾 `500 ms` RMS 差 `<= 1.0 dB`，采样跳变 `<= 0.002`，立体声相关 `0.25–0.72`，无 `>20 ms` 头尾静音
- [ ] 母带在 `.gdignore` 保护下完全隔离，不进导出包与 Git 追踪

### 人工听审

- [ ] 闭眼听感确为清浅透亮鹅卵石溪水 + 远景轻微叶风，彻底告别收音机静电感和 `v01` 低闷风吼
- [ ] 与 `bgm_village_pastoral_loop_main_v02.ogg` 并轨播放融合自然，手机外放木吉他和钢琴清澈居中

## 13. 假设与待确认事项

- **为何从 `v01` 发起重制**：独立审核实测 `v01`（`UEKiweVmbg` 衍生）`160–350 Hz` 占 `66.20%`、质心仅 `339.6 Hz`、`258/266/295 Hz` 有 `+35–36 dB` 峰值且 10s 区间有 3.4 dB 衰减漂移，不能在代码或简单调音中无损救回清爽水声，需由音频生成 Agent 按本 `v02` 规范换用清透底材重制并在提交回执里附上全长 FFT 窄带峰自检数据。
- **未修改现行代码**：等待 `v02` 审核合格后，再一并切换 `AudioManager.gd` 并清理旧版 `amb_brook_loop` 及废弃的 `v01` 测试产物。
