# 音频生成提示词：amb_village_rain_breeze_loop_v01

> 文档性质：本文件由 `audio-prompt-spec` 规范生成，仅作为外部音频生成模型或拟音制作 Agent 的输入提示词与制作规格说明。**音频尚未生成**，文中目标音频路径均为计划输出路径。

## 1. 资产元信息

### 基本信息

| 字段 | 内容 |
| --- | --- |
| 项目名称 | 风息村落物语 (Windbreath Village) |
| asset_id | AUD_AMB_VILLAGE_RAIN_BREEZE_01 |
| 主文件名 | `amb_village_rain_breeze_loop_v01` |
| 资产类型 | `amb` |
| 用途 | 替换当前由 `tools/generate_audio.py` 生成的 `amb_rain_chime_loop.ogg`（存在同款 0.567 平坦度收音机噪点及会与 BGM `F 大调` 发生音高冲突的 C 大调合成钟琴），作为设置面板「细雨风铃白噪音」开启时的柔和自然林间细雨与极稀疏柔风叠加音层 |
| 优先级 | `P1`（主溪流风声修复后建议配套升级，防止开启该开关后再次变吵并破坏 BGM 和谐） |
| 提示词版本 | `v01` |
| 目标生成模型及版本 | 待确认（提供模型无关通用中文与英文正向提示词，适配真实自然细雨声景模型或高清真实雨声采样制作管线） |
| 当前状态 | 仅完成提示词文件，音频待生成 |

### 路径规则与交付路径

| 路径类别 | 路径值 | 状态 |
| --- | --- | --- |
| 1. 提示词 Markdown 完整保存路径 | `D:\Code\project\windbreath_village\docs\audio_prompts\amb_village_rain_breeze_loop_v01_prompt.md` | 已写入 |
| 2. 原始高质量音频完整输出路径 | `D:\Code\project\windbreath_village\assets\audio\source\amb_village_rain_breeze_loop_v01.wav` | 计划输出（未生成） |
| 3. 游戏运行时音频输出路径 | `D:\Code\project\windbreath_village\assets\audio\bgm\amb_village_rain_breeze_loop_v01.ogg` | 计划输出（未生成） |
| 4. 可选分轨 / 短版本 / 参考音频 / 后期工程路径 | `无` | 无 |
| 5. 项目内相对路径 / 引擎资源导入路径 | `assets/audio/bgm/amb_village_rain_breeze_loop_v01.ogg`（`res://assets/audio/bgm/amb_village_rain_breeze_loop_v01.ogg`；审核通过后再由主工程接入 `src/autoload/AudioManager.gd` 替换 `amb_rain_chime_loop.ogg`） | 计划导入路径 |

## 2. 音乐音频需求介绍

- **使用场景**：玩家在主菜单或局内设置里主动勾选开启「细雨风铃白噪音」辅助白噪音开关时，与 `bgm_village_pastoral_loop_main_v02.ogg` 及 `amb_village_brook_wind_loop_v01.ogg` 同时三轨柔和叠加。
- **叙事背景**：江南与海岛交界处温柔如丝的午后小雨，雨丝细密地落在青瓦木檐、石阶与宽大竹叶/荷叶上，伴着温润湿润空气。
- **玩家正在做什么**：在夜间（「萤火夏夜」）或工作休憩时打开「赏景」模式伴随雨声听歌放空，或安静放置地块。
- **需要传达的情绪**：宁静助眠、湿润舒缓、像坐在带遮雨木廊下喝热茶的安心感——**坚决去除旧版“收音机电流嘶嘶声”以及突兀敲响的高音合成钟琴**，做到可开一整晚也不会吵闹或走音冲突。
- **音频承担的功能**：作为可选助眠细雨氛围加层，柔和柔化画面气氛而不覆盖下层主音乐和常驻溪流声。
- **开始、结束与切换条件**：应用启动时由 `AudioManager` 加载保持循环，开关开启时从静音淡入设定增益（`amb_volume * 0.48`），关闭时静音。
- **对白与音效及 BGM 共存要求**：
  - 本音轨开启后**必须同时与 BGM 及溪流声三条轨道共存**！因此声音质感绝对不能做成高密度宽频雨声墙壁（高频沙沙雨幕和风声/水声叠在一起必然像电视/收音机雪花噪）；
  - 重点采用**软质木檐与竹叶雨滴落点感（Soft Raindrops on Leaves & Wooden Roof）**，将响度同样压低至 **`-29.0 ± 1.5 LUFS`**，切除 `180 Hz` 以下沉闷低频并柔和衰减 `3.2 kHz` 以上尖刺嘶声，且**取消容易与音乐和声撞音的高音风铃/钟琴音高脉冲**（或如界面文案改称纯细雨，保持纯无固定音高自然滴答雨滴声）。

## 3. 生成风格

- **音乐类型与子类型**：Cozy Natural Rain Foley / Soft Eaves & Foliage Drizzle Soundscape（治愈系木檐竹叶软细雨自然田野拟音）
- **情绪关键词**：细腻温润（Soft Drizzle）、安宁助眠（Calming）、木檐避雨（Sheltered Porch）、无刺耳嘶声（Anti-Hiss）、自然融合（Blendable）
- **时代或文化背景**：自然高清室内廊下避雨田园录音质感（非暴风雨雷鸣、非铁皮屋顶暴雨噼啪撞击、非程序生成粉红噪声）
- **配器 / 声音元素构成**：
  - **核心纹理**：温和细腻的小雨沙沙轻轻叩击在竹叶、草丛与老木瓦屋檐上的柔和滴落颗粒声（Soft Light Rain on Bamboo Leaves & Wooden Eaves）——能听清错落松散的点滴节奏与暖意共鸣，绝非一片模糊刺耳的白噪墙；
  - **可选点缀**：极偶尔微不可察的柔和温润湿风掠过（不带任何呼啸风声），以及**如有极轻微竹筒木风铃共振需求，仅可使用非尖刺极短木质轻叩或完全采用纯自然雨滴，禁止一切金属音阶钟琴！**
  - **禁用元素**：严禁暴雨、惊雷、铁皮棚脆响、路面汽车驶过水声、持续白色/粉色合成噪声质感、高频电子金属风铃（`chime` 合成器）。
- **节奏特点**：天然疏朗随机雨滴错落感（Non-rhythmic），零机械循环抽吸。
- **旋律与和声特征**：**不适用（无固定音高自然细雨声景）**，确保与 `BGM_v02`（F 大调）任意和弦行进叠加 100% 不冲突不跑调。
- **混音质感与制作方向**：隔着半开纸拉门或木屋长廊听到的温润微闷滤柔雨声（Warm Mellow Indoor/Porch Rain Perspective）。切掉 `180 Hz` 以下轰隆，柔和保护中温区，**从 `3.2 kHz` 向上做自然滚降防止手机发声变为刺耳高频噪点**。
- **参考特征（仅作抽象特征说明）**：借鉴自然助眠白噪音应用中“低频清亮无轰鸣、高频柔顺似丝绵的竹叶瓦片细雨”听感比例。

## 4. 可量化音乐参数

| 参数 | 规格 | 说明 |
| --- | --- | --- |
| BPM / BPM 范围 | `不适用（非节拍自然环境音床）` | 细雨自然落点严禁产生机械脉冲 |
| 拍号 | `不适用` | 非节拍声音素材 |
| 调性 / 调式 | `不适用（无固定音高纯自然雨滴声景）` | 根治旧版 `C 大调 1046.5 Hz` 钟琴撞车问题 |
| 速度变化 | `平稳舒缓小雨密度，无陡变暴雨爆发` |  |
| 目标时长及允许误差 | `60.000 秒（允许误差 ±0.5 秒；后期裁剪回绕至精确 60.000 s）` | 与常驻溪流轨保持一致长循环粒度且足够自然 |
| **三轨混音融合理化靶标** | 集成响度 **`-29.0 ± 1.5 LUFS`**；True Peak `<= -6.0 dBTP`；`0–180 Hz <= 8%`；`>3500 Hz <= 3.5%`；立体声相关系数 **`0.20–0.65`** | 保证开启本轨叠加于 BGM + 溪流之上时绝不发吵发嘶 |

## 5. 结构与情绪曲线

- `0–20 秒（恬淡木檐小雨）`：温和绵密的竹叶与木瓦檐轻雨均匀落下，水滴颗粒柔润干净、高频如绵般丝滑，绝不发出电台雪花白噪。
- `20–40 秒（微润雨滴轻疏变化）`：雨意稍微透出少量温润的荷叶滴水点缀，声音空间微宽立体，依然极度安静克制在背景中。
- `40–60 秒（回归平稳细雨并无缝回绕）`：水滴节奏平稳回归起音状态，通过 `2.0 秒` 等功率交叉淡化平滑衔接回第 0 秒，全程均匀安神。

## 6. 人声与歌词

- **人声策略**：纯自然环境音（无任何人声）
- **强制约束**：本音轨必须为纯粹的田园细雨拟音，**不得出现人声、念白、合唱或含歌词的声音**。

## 7. 循环与交互音乐要求

- **播放模式**：无缝循环（`loop`）
- **循环设计要求**：60.000 秒末尾不得出现突然静音或闪电雷声，以额外 2 秒天然雨声做 `2.0 秒` 等功率交叉淡化回绕（Tail Wrap），保证头尾 `500 ms` RMS 差 `<= 1.5 dB`。不拆 `intro` / `outro`。
- **自适应与交互要求**：作为 `AudioManager` 内可切换开关的可选第三轨与 `BGM_v02` + `amb_village_brook_wind_loop_v01` 并行叠加，必须在极低响度与无高频嘶刺前提下和谐共生。

## 8. 完整生成提示词

### 中文完整正向提示词（可直接提交）

```text
一段 60 秒无缝循环的温暖助眠系乡村木檐与竹叶细雨真实环境录音（Field Recording），专门用于叠加在轻柔木吉他背景音乐与溪流声上。声音质感犹如坐在传统木屋檐廊下听小雨轻轻落在竹叶、青草与木质屋瓦上的温柔沙沙滴答声——雨滴粒粒分明而松软温润，带着天然雨水与植物摩擦的柔和木质空气感，绝对不是暴雨、雷阵雨、铁皮雨棚噼啪脆响，也绝对不是连续发直的收音机电流嘶嘶声或粉红白噪音。全曲不含任何雷鸣、风啸、鸟叫、青蛙，也严禁出现任何合成器钟琴、金属风铃或带音高的叮咚铃声。频率温和干净，180 Hz 以下无低沉轰隆声，3.2 kHz 以上高频平顺柔和无刺耳嘶响；立体声左右温柔环绕并将音量克制地收敛在安宁柔和的极轻背景层级（-29 LUFS 目标），实现与田园背景乐无缝融入，平滑等功率交叉淡化构成完全无感的 60 秒无缝循环。不得出现人声、念白、合唱或含歌词的声音。
```

### 英文版 generation_prompt（适用于英文优先或未指定模型）

```text
A 60-second seamless-looping, warm, gentle stereo field recording of soft light drizzle and calm raindrops falling on bamboo leaves, tall grass, and wooden porch eaves—heard from a sheltered rustic courtyard. Soft, organic, cozy rain texture with subtle distinct droplet details on foliage and timber, strictly NOT heavy rain, NOT a downpour, NOT thunder, NOT sharp rain on metal tin roofs, and NOT continuous static pink or white noise radio hiss. Completely devoid of any whistling wind, thunder, birds, frogs, synthetic water pings, musical chimes, metallic wind chimes, or pitched bells. Warm, muted-high acoustic frequency profile high-passed cleanly above 180 Hz with gentle roll-off above 3.2 kHz so it blends invisibly beneath acoustic guitar BGM and a gentle stream bed without ever sounding harsh, bright, or busy on phone speakers. Purely unpitched natural rain foley: strictly no vocals, no spoken word, no choir, no lyrics. Steady soothing sleep-friendly energy at a subtle low background loudness (-29 LUFS integrated) ready for an undetectable 60-second equal-power crossfaded seamless loop.
```

## 9. 负面提示词与禁止事项

- **排除声音与元素**：人声、念白、合唱、暴雨、雷电、狂风呼啸、铁皮金属雨声、汽车驶过水声、所有合成钟琴/金属风铃/带音高音阶铃声（防止与音乐撞调）、收音机沙沙电流噪声/粉红或白噪声质感（`radio static / white noise hiss`）。
- **排除混音与技术缺陷**：`>3.5 kHz` 刺耳高频嘶叫、`0–180 Hz` 低频轰鸣、响度过大压过音乐与溪流声（超过 `-26 LUFS`）、周期性循环爆音或断档静音。
- **冲突检查声明**：本节排除“任何带音高风铃与高频嘶刺白噪”，与第 2–8 节“无固定音高软细雨滴叶与木檐柔光质感”完全一致。

## 10. 技术交付规格

| 规格项 | 源文件（Master） | 运行时文件（Runtime） |
| --- | --- | --- |
| 文件格式 | `WAV（无压缩 PCM）` | `OGG Vorbis`（匹配 Godot 4.7.2 `AudioStreamOggVorbis`） |
| 采样率 | `48000 Hz` | `44100 Hz` |
| 位深 / 比特率 | `24-bit PCM` | `128–160 kbps VBR` |
| 声道 | `Stereo（柔和宽阔立体声场，相关性 0.20–0.65）` | `Stereo` |
| 响度与峰值规范 | **`-29.0 LUFS（±1.5 LU）/ True Peak <= -6.0 dBTP`**（确保三轨齐开依然恬静柔和） | 同左 |
| 频谱安全限值 | `0–180 Hz <= 8%`；`>3500 Hz <= 3.5%` | 同左 |
| 首尾静默与循环精度 | 首尾零静音；60.000 s 等功率交叉回绕，头尾 `500 ms` RMS 差 `<= 1.5 dB` | 在 `.ogg.import` 启用 `loop=true` |

### 后期处理要求（模型单次生成无法直接保证，须人工 / 脚本处理）

1. 使用真实自然细雨素材或生成模型产物，坚决不用程序粉噪脚本重新合成。
2. `180 Hz` 以下平滑高通，并在 `3.2 kHz` 以上平缓高频衰减去除毛刺；中间频段可对 `500 Hz` 附近略微衰减 `-2 dB` 让位 BGM。
3. 截取 `62 秒` 稳定自然段通过 `2.0 秒` 等功率交叉回绕剪至精确 `60.000 s`。
4. 集成响度归一化至 `-29.0 LUFS`，保存 `48000 Hz / 24-bit WAV` 母带于 `assets/audio/source/`（已隔离导出），转码 `44100 Hz OGG Vorbis` 于 `assets/audio/bgm/`。

## 11. 交付物与变体

| 序号 | 交付物角色 | 目标文件名 | 目标路径 | 状态 |
| --- | --- | --- | --- | --- |
| 1 | 提示词规格文档 | `amb_village_rain_breeze_loop_v01_prompt.md` | `D:\Code\project\windbreath_village\docs\audio_prompts\amb_village_rain_breeze_loop_v01_prompt.md` | 已写入 |
| 2 | 细雨氛围音母带（源文件） | `amb_village_rain_breeze_loop_v01.wav` | `D:\Code\project\windbreath_village\assets\audio\source\amb_village_rain_breeze_loop_v01.wav` | 待生成 |
| 3 | 细雨氛围音（游戏运行时） | `amb_village_rain_breeze_loop_v01.ogg` | `D:\Code\project\windbreath_village\assets\audio\bgm\amb_village_rain_breeze_loop_v01.ogg` | 待生成与转码 |

## 12. 验收标准

### 自动检查

- [ ] 源文件与运行时文件主命名严格符合 `[a-z0-9_]`：`amb_village_rain_breeze_loop_v01`
- [ ] 格式与规格：WAV `48000 Hz / 24-bit Stereo`，OGG `44100 Hz Stereo`，时长 `60.000 s`（±0.2 s）
- [ ] 集成响度 `-29.0 ± 1.5 LUFS`，True Peak `<= -6.0 dBTP`，`0–180 Hz <= 8%`，`>3500 Hz <= 3.5%`
- [ ] 头尾 `500 ms` RMS 差 `<= 1.5 dB` 且无超过 `20 ms` 头尾纯静音
- [ ] `.wav` 母带置于受 `.gdignore` 保护的 `assets/audio/source/` 且不进 APK/PCK

### 人工听审

- [ ] 听感如木屋屋檐与竹叶自然飘落细雨，绝无收音机电流嘶声或高频合成叮咚钟声
- [ ] 同时开启 `bgm_village_pastoral_loop_main_v02` + `amb_village_brook_wind_loop_v01` + 本轨时层次安静融合、无响度压迫及音高不协和
- [ ] 60 秒循环衔接完全察觉不到断点

## 13. 假设与待确认事项

- **与旧版缺陷的实测对照根因**：现行 `amb_rain_chime_loop.ogg` 经测定为单声道合成 `1/f^0.58` 粉噪（平坦度 `0.567`，RMS `-19.28 dBFS`，LRA 仅 `0.2 LU`）叠加 C 大调合成高音铃，不仅具有显著收音机静态底噪质感，还会在 F 大调新 BGM 下产生不协和碰撞。因此虽目前 UI 默认未勾选该开关，亦建议同步重制。
- **UI 文案微调提示**：当前界面复选框文案为“细雨风铃白噪音”；采用本无音高纯细雨方案时，后续接入审核阶段可视情况顺带将 UI 文案微调为“林间细雨白噪音”或保持友好提示，均不影响逻辑兼容。
- **商用授权提醒**：请确认外部生成工具或自然雨声采样来源具备商业手游分发权限。
