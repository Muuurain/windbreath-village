# 音频生成提示词：amb_village_brook_wind_loop_v01

> 文档性质：本文件由 `audio-prompt-spec` 规范生成，仅作为外部音频生成模型或拟音制作 Agent 的输入提示词与制作规格说明。**音频尚未生成**，文中目标音频路径均为计划输出路径。

## 1. 资产元信息

### 基本信息

| 字段 | 内容 |
| --- | --- |
| 项目名称 | 风息村落物语 (Windbreath Village) |
| asset_id | AUD_AMB_VILLAGE_BROOK_WIND_01 |
| 主文件名 | `amb_village_brook_wind_loop_v01` |
| 资产类型 | `amb` |
| 用途 | 替换当前由 `tools/generate_audio.py` 生成的 `amb_brook_loop.ogg`（收音机底噪电流音质感 + 频谱/响度喧宾夺主掩蔽 BGM），作为游戏全程常驻的真实自然山涧浅溪与微风竹叶立体声环境底床 |
| 优先级 | `P0` |
| 提示词版本 | `v01` |
| 目标生成模型及版本 | 待确认（提供模型无关通用中文与英文正向提示词，适配 ElevenLabs Sound Effects / Stable Audio / AudioGen / 真实自然田野采样混音管线） |
| 当前状态 | 仅完成提示词文件，音频待生成 |

### 路径规则与交付路径

| 路径类别 | 路径值 | 状态 |
| --- | --- | --- |
| 1. 提示词 Markdown 完整保存路径 | `D:\Code\project\windbreath_village\docs\audio_prompts\amb_village_brook_wind_loop_v01_prompt.md` | 已写入 |
| 2. 原始高质量音频完整输出路径 | `D:\Code\project\windbreath_village\assets\audio\source\amb_village_brook_wind_loop_v01.wav` | 计划输出（未生成） |
| 3. 游戏运行时音频输出路径 | `D:\Code\project\windbreath_village\assets\audio\bgm\amb_village_brook_wind_loop_v01.ogg` | 计划输出（未生成） |
| 4. 可选分轨 / 短版本 / 参考音频 / 后期工程路径 | `D:\Code\project\windbreath_village\assets\audio\stems\amb_village_brook_wind_loop_v01`（如分别生成浅溪声与林间微风分轨后再混音，可临时存放于此；不保留空目录） | 计划路径 / 待确认 |
| 5. 项目内相对路径 / 引擎资源导入路径 | `assets/audio/bgm/amb_village_brook_wind_loop_v01.ogg`（`res://assets/audio/bgm/amb_village_brook_wind_loop_v01.ogg`；审核通过后再由主工程接入 `src/autoload/AudioManager.gd` 替换 `amb_brook_loop.ogg`） | 计划导入路径 |

## 2. 音乐音频需求介绍

- **使用场景**：主菜单大厅、6 大主题章节箱庭与无尽禅意造景模式全流程常驻播放（默认环境音音量 `amb_volume = 0.60`），在「赏景」模式下亦长期伴随玩家视觉休憩。
- **叙事背景**：山间清泉小溪穿行于茶园、麦田与青翠竹林之间，海风温和拂过花海与竹梢，水车慢转，村民与动物在村落中休闲散步。
- **玩家正在做什么**：慢节奏单手点击拼接六边形地块，思考路线连接，同时倾听已经升级的温暖原声主配乐 `bgm_village_pastoral_loop_main_v02.ogg`。
- **需要传达的情绪**：温润恬静、真实户外溪畔呼吸感、毫无嘈杂烦躁——**必须彻底消除旧版“像收音机无信号电流嘶嘶声/盲音”的机械感与压迫感**，化作悄然退在音乐身后半步的柔和自然景深。
- **音频承担的功能**：构建微风与潺潺溪流的空间存在感，与主配乐融合为一个呼吸同步的温暖田园整体，既不空洞，又绝不抢夺木吉他与钢琴的主角听感。
- **开始、结束与切换条件**：应用启动后由 `AudioManager` 启动并保持无缝循环；进后台随系统暂停，回前台恢复；受设置面板「溪流风声」滑块控制。
- **对白与音效（及 BGM）共存要求（关键核心设计）**：
  - 本轨必须与 **`bgm_village_pastoral_loop_main_v02.ogg`（质心 ~520 Hz、集成响度 -17.8 LUFS、40% 能量集中在 500–2500 Hz）** 以及 **10 个木质/五声调 UI 音效** 长期同时叠加！
  - 旧版失败根因已实测确认：`amb_brook_loop.ogg` 为单声道程序粉噪，在 `120–4000 Hz` 的**频谱平坦度高达 `0.580`**（近乎白噪电流），集成响度高达 ~`-20 LUFS`（只比音乐低 2–3 dB），且有 `31.7%` 的 `<120 Hz` 轰鸣底噪与连续水滴啸叫（`720–1450 Hz`）。
  - 因此新版必须遵守三大融合铁律：
    1. **响度退让 10 dB**：本环境音床目标响度必须控制在 **`-28.0 ± 1.5 LUFS`**（比 BGM 低约 `10 dB`），做温柔背景衬底而非等响度噪音墙。
    2. **立体声包络让位中置**：采用柔和宽广的真实**立体声（Stereo）**拾音声场（两侧细碎溪石流淌与轻柔树叶沙沙微风），让出正中声场给 BGM 的木吉他与钢琴主奏！
    3. **频段避让与去电台噪化**：干净切除 `160 Hz` 以下低频隆隆声（消除低频浑浊冲突），大幅弱化静止连续“白噪沙沙声”并转为有明显颗粒间隙的**真实小水花咕噜滚动声**，温和柔化 `3.5 kHz` 以上高频嘶响（绝无电台嘶嘶感）。

## 3. 生成风格

- **音乐类型与子类型**：Organic Nature Field Recording / Cozy Acoustic Ambience Soundscape（写实温和的自然田野声景拟音 / 治愈系田园环境底床）
- **情绪关键词**：潺潺清润（Gentle Trickling）、微风轻拂（Soft Zephyr）、柔和隐退（Subtle Background）、零电流噪感（Static-Free）、有机呼吸感（Organic）
- **时代或文化背景**：现代高清自然田野录音（非 8-bit、非老式程序合成噪声、非宏大暴雨洪水纪录片风暴音效）
- **配器 / 声音元素构成（彻底远离合成粉噪与电台盲音）**：
  - **近-中景溪流主体（占主导，约 75% 质感）**：浅水漫过光滑鹅卵石的**温和细小水花潺潺声、低流速清泉轻柔咕噜冒泡与小溪回旋波纹声**（Smooth Gentle Babbling Brook over Small Pebbles）——要求水声颗粒温润松散、水珠间具备真实的空气隙与动态微起伏，**严禁听起来像连续不断的浴室花洒、大瀑布哗哗白噪声或收音机雪花声**；
  - **远景微风竹叶点缀（辅助，约 25% 质感）**：极轻柔的春风吹过竹林叶片与高草丛时的**稀疏柔和叶片婆娑沙响**（Soft Distant Breeze through Bamboo Leaves），**严禁贴近麦克风呼呼直吹产生的低频喷麦风噪（Wind Buffeting）或高频尖锐啸叫风声（Howling Wind / Whistling Gusts）**！
  - **禁用元素**：严禁鸟鸣尖叫、青蛙聒噪、蝉鸣刺耳声、人声、脚步声或任何乐器/风铃/水滴合成正弦哨音。
- **节奏特点**：**完全自由有机流动性（Non-rhythmic / Organic Flow）**——不能有任何周期性正弦波音量起伏（旧版 `sin*cos` 制造的波浪式电流泵感极其人工化），水花与微风随自然湍流缓慢随机呼吸。
- **旋律与和声特征**：**无固定音高（Unpitched Natural Soundscape）**，不得包含任何音阶旋律、金属共鸣或音调水滴哨声（确保无论搭配 BGM 何种和弦转换都能 100% 自然融合）。
- **混音质感与制作方向**：温暖润泽的中距离自然空气拾音质感（Warm Rolled-Off Nature Recording）。**严控频率轮廓**：
  - `160 Hz` 以下平滑高通滤波切除风吼与水流沉闷隆隆声（使 `0–160 Hz` 总能量占比 **`<= 8%`**）；
  - **`350–900 Hz` 做轻微柔顺让位凹槽（-2 dB 至 -3 dB）**，为 `BGM_v02`（质心 ~520 Hz）腾出干净清澈的吉他与钢琴呼吸位；
  - 重点保留 **`650–2600 Hz` 之间温和清晰、毫无连续底噪的立体声浅水咕噜颗粒细节**；
  - **`3.5 kHz` 以上逐步温柔低通/搁架衰减**（使 `>4000 Hz` 能量 **`<= 3.0%`**），彻底消灭手机扬声器里像高频漏电或磁带嘶声的粗糙感。
- **参考特征（仅作抽象特征说明）**：借鉴高保真治愈系慢生活独立游戏自然音景“音量偏轻、水声咕噜清晰有隙而不连续沙哑、微风像柔和树叶呼吸而非吹麦”的立体声烘托比例。

## 4. 可量化音乐参数

| 参数 | 规格 | 说明 |
| --- | --- | --- |
| BPM / BPM 范围 | `不适用（非节拍自然环境音床）` | 有机流水与微风严禁出现机械节拍感或周期性LFO起伏，避免与 72 BPM BGM 节奏打架 |
| 拍号 | `不适用` | 非音乐小节结构自然声景 |
| 调性 / 调式 | `不适用（无固定音高纯自然水风拟音）` | 杜绝任何定音水滴哨声与钟铃，确保 100% 兼容 `BGM_v02` 的 F 大调全曲 |
| 速度变化 | `自然缓慢湍流微变化，无明显周期律动` |  |
| 目标时长及允许误差 | `60.000 秒（允许误差 ±0.5 秒；后期精准对齐至 60.000 s 无缝循环）` | 较旧版 12 秒延长 5 倍，且 60s 与 80s BGM 的最小公倍数为 240s（4分钟），极少重合复现接缝 |
| **反电台噪化 & 融合理化靶标** | 集成响度 **`-28.0 ± 1.5 LUFS`**；True Peak `<= -6.0 dBTP`；**`0–160 Hz <= 8%`**；**`>4000 Hz <= 3.0%`**；非单声道噪声壁（立体声相关系数 **`0.25–0.72`**）；禁止出现周期性正弦调幅 | 用可量化指标保证“柔和、宽敞、不吵、不像电流白噪” |

## 5. 结构与情绪曲线

- `0–15 秒（稳态起音与细腻水石流淌）`：柔和清晰的山涧浅溪鹅卵石流水声平稳展开，水花咕噜颗粒温柔分布在左右微宽立体声像内；远离正中低频与高频嘶鸣，第 0 秒起音能量须与第 60 秒循环回绕完全一致。
- `15–35 秒（微风轻拂竹叶呼吸段）`：极轻柔的林间微风缓缓推起 1–2 次自然起伏（音量微幅变化不超过 `2.5 dB`），伴随稀疏柔和的竹叶婆娑沙沙声，随风自然消退；水声始终保持温和稳定的浅流细腻质感。
- `35–50 秒（平静清澈浅流段）`：风声略微减淡，留下干净温柔的小溪局部气泡与细流微光感，整体声音非常透气，完全不会产生持续一成不变的疲惫噪点。
- `50–60 秒（微风微拂与平滑衔接回第 0 秒）`：轻微风意与稳定潺潺流水在最后 3–4 秒持续平稳流通，通过 `1.5–2.5 秒` 无缝交叉回绕混接回到第 0 秒状态，全程无静音中断、无陡然跌落。

## 6. 人声与歌词

- **人声策略**：纯自然环境音（无任何人声）
- **强制约束**：本音轨必须为纯粹的自然溪流与微风拟音，**不得出现人声、念白、合唱或含歌词的声音**（也不得包含任何隐约谈话声、脚步声或动物尖叫）。

## 7. 循环与交互音乐要求

- **播放模式**：无缝循环（`loop`）
- **循环设计要求**：60.000 秒结尾不得淡出至静音，必须从第 60 秒之后继续生成的 2–3 秒自然水声中截取并做 `2.0 秒` 等功率交叉淡化回绕（Equal-Power Crossfade Loop Wrap）接入开头 2 秒，使得头尾 `500 ms` RMS 响度差严格 **`<= 1.5 dB`**、采样无缝衔接无咔哒响、且听不出循环周期节点。不拆 `intro` / `outro`。
- **自适应与交互要求**：单一静态立体声环境底床，交由 `AudioManager` 独立总线持续与 `bgm_village_pastoral_loop_main_v02.ogg` 及 SFX 混音；因自带约 `10 dB` 响度退让与中置凹槽避让，无需运行期动态闪避即可完美融入 BGM。

## 8. 完整生成提示词

### 中文完整正向提示词（可直接提交）

```text
一段 60 秒无缝循环的治愈系真实自然户外微风与浅溪环境音效（Field Recording），专门用于垫在慢节奏田园木吉他音乐下方作温柔声景底床。声音主体是清浅透明、低流速的山间小溪流过光滑鹅卵石时温柔的潺潺水花、细腻轻柔的咕噜水泡与偶发小水涡声，水声颗粒温润灵动、彼此之间有自然的间隙和立体声左右轻柔流动，绝非连续刺耳的大水量白噪音、暴雨瀑布声或像收音机雪花电流般的持续嘶嘶声。夹杂约四分之一比例极轻柔温暖的远方微风穿过竹林与草叶的柔和婆娑沙响，绝不出现风吹麦克风的低频呼呼扑麦风噪或任何尖锐风啸声。整体质感温暖洁净、偏柔和中频水感、160 Hz 以下无沉闷轰隆、3.5 kHz 以上高频温和收敛，没有任何鸟叫、青蛙、合成水滴哨音、风铃或乐器声。严格为纯粹自然水风拟音，不得出现人声、念白、合唱或含歌词的声音。全程维持轻柔稳定的低调背景音量（-28 LUFS 目标级温柔退居音乐之后），通过平滑等功率交叉淡化实现 60 秒彻底无感无缝循环。
```

### 英文版 generation_prompt（适用于英文优先或未指定模型）

```text
A 60-second seamless-looping, warm, organic stereo field recording of a very gentle shallow pebble stream and a soft distant breeze rustling bamboo leaves, designed to sit subtly underneath peaceful acoustic guitar background music. Clear, delicate, slow-flowing mountain brook water trickling and softly gurgling over small smooth river stones—intimate and detailed droplet/ripple texture with natural airy breathing room, NOT a heavy rushing river, waterfall, roaring torrent, or continuous static white/pink noise hiss. Blended sparingly with a whisper-soft, warm breeze gently rustling distant green foliage—strictly NO microphone wind rumble, NO low-end buffeting, and NO high-pitched whistling wind gusts. Warm, smooth acoustic tone cleanly high-passed above 160 Hz with gently rolled-off highs above 3.5 kHz so it never sounds harsh, fizzy, static-like, or radio-hiss on phone speakers. Purely natural non-pitched foley ambience: no birds, no frogs, no insects, no synthetic sine pings, no bells, no music, and strictly no vocals, no spoken word, no choir, no lyrics. Calm, non-rhythmic steady energy throughout suitable for an undetectable crossfaded seamless 60-second loop at a subtle background level (-28 LUFS integrated).
```

## 9. 负面提示词与禁止事项

- **排除声音与元素**：人声、念白、合唱、任何乐器、金属风铃/合成水滴哨音（`synthetic chirp drops`）、收音机沙沙电流噪声/粉红白噪声生成器纹理（`radio static / white noise hiss / electric hum`）、大雨暴雨洪水瀑布轰鸣（`waterfall / heavy river roar`）、猛烈风声与喷麦风压轰鸣（`wind buffeting / microphone pop / whistling wind`）、刺耳蝉鸣/高频虫叫/吵闹鸟叫。
- **排除混音与技术缺陷**：高音嘶刺感（`>4 kHz > 3%` 能量堆积）、`0–160 Hz` 低频轰鸣与浑浊堆积、周期性波浪正弦 LFO 体积泵浦感、单声道紧贴正中挤压主配乐空间、响度过高（高于 `-25 LUFS` 导致盖过音乐）、循环切点顿挫/音量跳变/咔哒声、头尾无意义静音。
- **冲突检查声明**：本节排除的“连续白噪声、高频漏电嘶响、风吹扑麦声与响度过高”均与第 2、3、4、8 节“细腻低流速鹅卵石水花 + 远景轻柔叶声 + `-28 LUFS` 立体声退让配混”高度一致，无任何内部冲突。

## 10. 技术交付规格

| 规格项 | 源文件（Master） | 运行时文件（Runtime） |
| --- | --- | --- |
| 文件格式 | `WAV（无压缩 PCM）` | `OGG Vorbis`（匹配 Godot 4.7.2 `AudioStreamOggVorbis`） |
| 采样率 | `48000 Hz` | `44100 Hz` |
| 位深 / 比特率 | `24-bit PCM` | `128–160 kbps VBR` |
| 声道 | `Stereo（真立体声 2D 环境底床，相关性 0.25–0.72）` | `Stereo` |
| 响度与峰值规范 | **`-28.0 LUFS（±1.5 LU）/ True Peak <= -6.0 dBTP`**（专门低于 BGM 约 10 dB 以达成完美融合不喧闹） | 同左 |
| 频谱安全限值 | `0–160 Hz <= 8%`；`>4000 Hz <= 3.0%`；避免静止连续噪声壁 | 同左 |
| 首尾静默与循环精度 | 首尾零静音；60.000 s 等功率交叉回绕，头尾 `500 ms` RMS 差 **`<= 1.5 dB`** | 在 `.ogg.import` 启用 `loop=true` |

### 后期处理要求（模型单次生成无法直接保证，须人工 / 脚本处理）

1. **禁止使用纯粉/白噪声脚本再造假流水**：必须基于真实物理声场模型或高清真实自然环境模型生成原素材；若原素材含周期性隆隆底噪或水声过于汹涌，须先重抽或筛选轻柔段落。
2. **精准避让 BGM 频谱雕刻（Carving EQ）**：
   - 施加 `160 Hz` 平缓高通滤除风吼与沉闷低频共振；
   - 在 `450–650 Hz` 对环境声轻轻衰减 `-2 dB`（精准让位于 `BGM_v02` 的核心吉他钢琴频段）；
   - 从 `3.5 kHz` 向上平顺柔和低通/搁架衰减，确保无任何刺耳高频“电流嘶嘶感”。
3. **2.0 秒等功率交叉淡化无缝循环（Equal-Power Loop Wrap）**：取总长约 `62 秒` 连续自然段，将末尾多出的 `2.0 秒` 以等功率淡入/淡出交叉叠入音频前 `2.0 秒`，修剪成精准 `60.000 s` 无缝循环。
4. **响度定标与运行时转码**：精确测算并归一化至 `-28.0 LUFS`（LRA 保持柔和 `2–5 LU` 之间），输出 `48000 Hz / 24-bit WAV` 母带存本地 `assets/audio/source/`（已设 `.gdignore`），并转码 `44100 Hz Stereo OGG Vorbis` 放至 `assets/audio/bgm/`。

## 11. 交付物与变体

| 序号 | 交付物角色 | 目标文件名 | 目标路径 | 状态 |
| --- | --- | --- | --- | --- |
| 1 | 提示词规格文档 | `amb_village_brook_wind_loop_v01_prompt.md` | `D:\Code\project\windbreath_village\docs\audio_prompts\amb_village_brook_wind_loop_v01_prompt.md` | 已写入 |
| 2 | 溪流微风环境音母带（源文件） | `amb_village_brook_wind_loop_v01.wav` | `D:\Code\project\windbreath_village\assets\audio\source\amb_village_brook_wind_loop_v01.wav` | 待生成 |
| 3 | 溪流微风环境音（游戏运行时） | `amb_village_brook_wind_loop_v01.ogg` | `D:\Code\project\windbreath_village\assets\audio\bgm\amb_village_brook_wind_loop_v01.ogg` | 待生成与转码 |

## 12. 验收标准

### 自动检查

- [ ] 源文件与运行时文件主命名严格符合 `[a-z0-9_]` 规则：`amb_village_brook_wind_loop_v01`
- [ ] 格式：WAV 为 `48000 Hz / 24-bit Stereo`，OGG 为 `44100 Hz Stereo` Vorbis，时长精确 `60.000 s`（±0.2 s）
- [ ] 集成响度严格位于 **`-28.0 ± 1.5 LUFS`**，True Peak `<= -6.0 dBTP`，无 `>20 ms` 头尾静音
- [ ] 频谱检查：`0–160 Hz <= 8%`，`>4000 Hz <= 3.0%`；且立体声相关系数在 `0.25–0.72`（真立体声而非单声道压中）
- [ ] 循环衔接检查：头尾 `500 ms` RMS 电平差 `<= 1.5 dB` 且接缝点无咔哒脉冲
- [ ] 23 MB 级 `.wav` 母带置于受 `.gdignore` 保护的 `assets/audio/source/` 目录内且不进入 APK/PCK

### 人工听审（关键对比测试）

- [ ] 单独闭眼试听 2 分钟：**完全不像收音机雪花声/漏电嘶声/吹麦噪音**，能清晰辨认出温柔的鹅卵石水花微粒与轻风拂竹叶质感
- [ ] 在 Godot 中与 `bgm_village_pastoral_loop_main_v02.ogg` 同时播放（默认 `bgm=0.65 / amb=0.60`）：音乐中的木吉他与钢琴依然清澈居中、毫不被环境音盖住或糊掉，二者如置身同一片田园户外一样融为一体
- [ ] 手机小扬声器与入耳耳机试听 60 秒衔接点时完全听不出循环接缝，连播 3 分钟无任何疲惫感

## 13. 假设与待确认事项

- **与旧版缺陷的实测对照根因**：经分析 [tools/generate_audio.py](file:///D:/Code/project/windbreath_village/tools/generate_audio.py) 与现有 `amb_brook_loop.ogg`，旧版音轨由脚本直接生成单声道 `1/f^0.58` 粉红噪声（120–4000 Hz 频谱平坦度高达 `0.580`）叠加 `sin*cos` 正弦波调幅及 `720–1450 Hz` 正弦脉冲，集成响度高达 ~`-20 LUFS` 且 31.7% 为 `<120 Hz` 轰鸣——这正是你听到“像收音机信号不好时的电流盲音、很吵且和 BGM 一点不融合”的直接技术原因。
- **游戏总线音量衔接说明**：目前 `src/autoload/AudioManager.gd` 第 92 行对环境音使用了 `linear_to_db(amb_v * 0.45)`；按本规范将环境音母带直接定标至 `-28.0 LUFS`（配合 `0.45` 总线衰减后实际稳态约 `-35 dB` 处于柔美铺底区），即使玩家将“溪流风声”滑块拉到最高也不会压过 BGM。待音频审核通过后需一并切换 `AudioManager.gd` 加载路径。
- **目标模型限制与后续依赖**：部分文本到音频模型难以一次输出连续 60 秒真无缝自然流水；可能需要生成多段或截取最温柔干净的水风段落，严格依第 10 节由音频脚本/DAW 完成高通/切嘶/交叉回绕与 `-28 LUFS` 定标。
- **商用授权提醒**：请确认外部生成工具或采样来源具备商业手游分发（APK/Win64）使用授权。
