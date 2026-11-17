# WEEX DEPOL S7 2026-27 — Moodle 全部内容梳理（截至 2026-11-16 22:50）

课程：`26_I_G_S07_PRO_TC_35 WEEX : Déchets et Pollution`（Pédagogie2, course id 2946）。负责人/发帖人：Jean-Pierre Cloarec（"Pour l'équipe DEPOL"）。
读取方式：Moodle 页面与论坛全文抓取；PDF 在内置浏览器中逐页截图阅读；docx/pptx/xlsx 在页面内解压读取。`DEPOL_cadrage_phase1` 全译见 `claude/WEEX_DEPOL_phase1_cadrage_zh_B4.md`，`map.xlsx`/`infos_polluants` 数据见同一文件第二部分。

## 1. Moodle 结构（学生可见 8 个栏目 + 若干隐藏栏目）
| # | 栏目 | 内容 |
|---|---|---|
| 0 | Généralités | Annonces 论坛（5 帖）；日期公告 16/11 8h00–20/11 17h45；`Composition_équipesDEPOL_S7_2026-27.xlsx`；页面"Sources et information sur la pollution atmosphérique" |
| 1 | Informations pour les QCM | QCM1 说明页；涂卡练习（offlinequiz 教程 5 节）；`DEPOL_présentation_générale_S7_2026-27_final.pdf`（7 页，QCM1 必背）；`..._votre_table_pour_le_QCM.pdf`（座位图） |
| 2 | Lundi : données initiales | 全周时间安排；文件夹：cadrage phase 1（1 PDF）、Ressources disciplinaires（8 文件）、Données géographiques（3 文件）；`template_lundi_L1_1_Xi.pptx` |
| 3 | Audit de votre code (CodeCert) | 3 个 PDF（Brochure / Procédure / Référentiel）；作业"Audit : dépôt des fichiers"（仅团队联络人可见） |
| 4 | Phase 1 : lundi | L1_0 联络人（Choix de groupe，截止 16/11 9:30）；Massimo Marro（LMFA）讲座**已取消** |
| 5 | Phase 1 : mardi → mercredi 8h30 | 周三 8:30 交付；9h–12h(15) 口试；之后继续 phase 2 计算 |
| 8 | Ressources : jetons / forum d'achat | 代币价目 + 购买论坛 |
| 15 | Pour votre culture générale | 6 个外链 |
| 6,7,9–14 | 隐藏 | 无权限访问——预计为 phase 2 任务、额外"Ressources"（可用代币购买）等，后续逐步开放 |

## 2. WEEX DEPOL 是什么（présentation générale）
- 案例研究：大气污染的机理与对人体健康的影响。
- 现实动机：欧洲环境空气污染致死率约 133 人/10 万人/年（Lelieveld 2019），对比欧盟道路事故 4.6 人/10 万人/年。
- 方法定位：**输运与沉降用确定性方法计算**，**健康影响用统计方法**（USEtox 表征因子）处理；数据来自 CITEPA（Secten）、Géorisques、USEtox 等公开库，情境虚构但数量级可信。
- "Jeu sérieux"：6 人一组，扮演为虚构雇主服务的独立咨询团队：(1) 环保 NGO **WFE**；(2) 能源/化工/建筑跨国企业 **Effergie**。要做的：说服委托方值得信任与给预算；在批评你方法的群体前答辩；简明说明方法的优劣。
- 与普通 TD 不同：没有明确计算指令，需自己从初始 briefing 和数据出发写需求书（cahier des charges）、设定可量化目标、选方法；调动量纲分析、不确定度、编码规范等。
- 地点：NGO 组在 Skylab 一楼 salle co-design + 底层 salle Formation；Effergie 组在 Skylab 一楼 salle de créativité（大厅）。

## 3. 全周时间线
| 时间 | 事项 | 来源 |
|---|---|---|
| 19/10 → 04/11 7:00 | 自选组队（choicegroup），否则由教务分配 | 论坛 |
| 周一 16/11 8:00（8:05 开考） | **QCM1** 个人纸质，约 10 min、~10 题，坐本组桌 | QCM 页 |
| 周一 9:30 | **L1_0** 指定联络人（只有联络人能提交） | cadrage / Moodle |
| 周一 16–17 | 顾问 Grégory Vial（数值模拟+Matlab+输运） | cadrage |
| 周一 **17:00** | **L1_1** 方框图 v1（.pptx/.odp）——论坛 10:35 更正为 17:00 | 论坛 |
| 周二 8:00 | 原定 Marro 讲座取消，直接在 Skylab 开工 | Moodle |
| 周二 14–16 | 顾问 Maffioli（输运）、Dubreuil | cadrage |
| 周三 **8:30** | **L1_2** 单文件 Matlab（`L1_2_Xi.m` / `L1_2_Xi_IA.m`） | cadrage |
| 周三 9:00–12:15 | **L1_3** 黑板口试 ~17 min，无资料无设备，随机点人 | cadrage |
| 周三 9:00 → 周五 17:45 | **Phase 2**：更多排放源、更多污染物与机制；改进 phase 1 方法（周三 9–18:15，周四 8–12:15，周五 8–9、9–12:15、13:30–17:45） | Moodle / présentation |
| 周三 14–16 | 顾问 Dubreuil | cadrage |
| 周四 9–11 | 顾问 Maffioli | cadrage |
| 周五 **9:00 前** | Phase 2 交付：Matlab 代码、数值结果、带论证的 slides（cadrage 写作 Matlab + slides + Excel） | présentation / cadrage |
| 周五上午 | 同阵营各组比较方法，选出最佳 2 组；教师团队评定科学质量；调查委员会评估可信度 | présentation |
| 周五上午末 | **期末个人 QCM**（纸质，无资料、**无计算器**） | présentation |
| 周五下午 | WFE 最优组 vs Effergie 最优组科学辩论（面向议会调查委员会专家），获胜组有奖 | présentation |

## 4. 交付物细则
- **L1_0**：Moodle 上选联络人。
- **L1_1 方框图 v1**（模板 5 页）：p1 说明（保存前删除方括号内说明和本页）；p2 团队名 + 勾选是否用 AI；p3 外部/AI 示例（删除）；p4 若用 AI：粘贴 AI 最佳版本 + 写明 AI 名称与 prompt(s)；p5 本组方框图 v1（模板示例为永久冻土碳反馈，每块带"数值 + 来源"）。规则：文件名 `L1_1_Xi.pptx` / `L1_1_Xi_IA.pptx`；**不收 PDF、不收云链接**；只放能计算、能量化的要素；不要 Canva 类美图、不要整张图片，必须是可编辑的独立方块；不用 AI 时须引用来源；不追求美观。
- **L1_2 Matlab**：单文件，在教师电脑上直接 Run，只基于 `map.xlsx`，**不附风场数据**（cadrage）。
- **L1_3 口试**：讲清介质划分、介质间转移现象、数值方法、每个选择的依据、量纲自洽与数量级、优势与局限。
- **Phase 2（周五 9:00）**：代码 + 数值结果 + slides（+ Excel）；单文件可运行要求同样适用。

## 5. 评价
- **QCM1（周一）**：考 présentation générale；计入"产生个人与集体绩效"能力。涂卡规则：黑/深蓝圆珠笔；填满格子＝取消；学号（6 位）涂对 + 姓名写全 + 写学号，每错一项扣 2 分；问题页上不得留任何记号（圈答案也扣分）；答题卡不折不污。
- **期末个人 QCM（周五上午末）**：检查全队是否共享了科学要点。示例考点：找出方框图中的错误；解读 USEtox 表、比较污染物/介质的特征系数；识别某类污染物的沉降机制；评价 Matlab 脚本片段（边界条件、计算逻辑）；判断近似是否合理。计入 C2N1 与 C4。
- **能力**：C2N1 "表征与建模"（识别并分级物理现象、写成方程、提出并论证强假设）；"产生个人与集体绩效"；"Oser（敢于）"。评分 A/C/F 细则见 cadrage 全译。
- **CodeCert 审计**（N+1 可要求）：结果影响团队评价。

## 6. 角色与支持
- Effergie：N+1 Céline Besançon；RH Caroline Fee-Gaben、Véronique Billat。WFE：N+1 Sébastien Cécillon；RH Clarisse Morel。
- 顾问：Frédéric Dubreuil、Andrea Maffioli（污染物输运）、Grégory Vial（数值模拟）。
- 审计：CodeCert（虚构审计事务所）。

## 7. 代币（jetons）
- 每组初始 **3 枚**；只需再多 1 枚就能解锁资源。注意：无人看管的代币会被"拿走"。
- 赚取：整周组织质量、出勤与投入（主动性、对话质量、科学严谨、集体在场）；周三口试的方法质量；与 RH 和科学人员交流的质量。
- 价格：简单问题 0；单人 10 min 深入 4；30 min 5；2×20 min 两位专家 6；楼上 box 4（需 N+1 同意、视库存）；从别组招人 6；换组 6（各方同意、名额有限，先找 N+1）；额外文献（新闻、科研论文、智库报告）分批上架于各"Ressources"栏目。价格可能随供需变化。
- 购买：在"Forum pour l'achat…"发帖：组名 + 资源**准确名称**（Moodle 资源请复制原名）+ 点"répondre"；名称写错不成交，按到达顺序处理。

## 8. CodeCert 审计（3 个 PDF）
- Brochure（1 页）：认证仿真代码；7 维度；评分徽章（A/92 示例）。
- Procédure（4 页）：① 审计前在 Moodle 交 ZIP（全部文件 + 运行命令；含数据文件，**风场用 1 个月数据**以减小体积；附手写的完整功能清单）；② 全员到场、CodeCert 专家审计、现场运行代码（运行失败可重交一次）、结果与任务清单的一致性、编程方法与组织；③ 场次表写的是"24/03、25/03"——**是旧学期日期**，以现场通知为准。
- Référentiel（1 页，7 点）：项目管理；数据与可追溯性；物理建模（模型选择、简化假设、适用域、耦合、文献）；离散化（方法、精度阶、稳定性、参数敏感性）；代码质量（结构、规范、错误处理、单元测试、文档）；自验证（解析测试、参考解比对）；不确定度（来源识别、量化方法）。
- Moodle 作业：`audit_Xi.zip`（如 `audit_B4.zip`），仅联络人可交，上传后不可修改。

## 9. 数据与资源文件
| 文件 | 体积 | 内容 / 用途 |
|---|---|---|
| `DEPOL_cadrage_phase1_S7_2026-27_final.pdf` | 491 KB, 12 p | phase 1 任务书（已全译） |
| `DEPOL_présentation_générale_S7_2026-27_final.pdf` | 284 KB, 7 p | 全周规则（本文第 2–7 节） |
| `template_lundi_L1_1_Xi.pptx` | 1.0 MB, 5 slides | L1_1 模板 |
| `info_donnees_vent.pdf` | 82 KB, 1 p | 风场：高度 200 m；变量 `ux`、`uy`（m/s，x=经度向东，y=纬度向北）、`x`、`y`（单元中心经纬度°）、`t`（小时，从 1 月 1 日起，步长 3 h）；数组维度 `u(x,y,t)`；Filesender 下载；**注意 `imshow/imagesc/quiver` 默认第一维竖直、原点左上，显示会翻转**。文件名写作 `donnees_vent_1mois.mat` / `donnees_vent_1an.mat`（Moodle 文字写 `vent_un_mois.mat`，实际下载名可能另有不同） |
| `map.png` | 16 MB | 大陆地图 |
| `map.xlsx` | 1.3 MB | 网格表格数据（列说明见 cadrage） |
| `MODELISATION_infos_polluants_S6_2025-26.xlsx` | 39 KB | USEtox 表征因子与各介质份额 |
| `MODELISATION_USEtox_Documentation_DEPOL.pdf` | 3.9 MB, 208 p | USEtox 2.0 Documentation (v1.1) |
| `MODELISATION_Depositiontransfer_processes.pdf` | 1.0 MB, 23 p | USEtox 2.0 文档节选"Mécanismes de dépôts de polluant dans l'environnement"，WEEX 版（蓝字为课程注释）：第 5 章 environmental fate——介质、降解、介质间分配、介质间转移（含干/湿沉降） |
| `MODELISATION__précipitations_atmosphère_pollution.pdf` | 25 MB, 34 p | Sicard 2006 博士论文节选：降水化学/大气化学（湿沉降、酸化、术语表、缩写） |
| `MODELISATION_Chapitre9_FLE_TC1.pdf` | 3.6 MB, 25 p | ECL 流体力学课第 9 章"Mixing of fluids"：质量分数、组分守恒、扩散通量、平流-扩散方程、湍流混合 |
| `MODELISATION__diffusion_turbulente.docx` | 13 KB | 只有一句话 + 维基"Eddy diffusion"链接（S6 2022-23 旧文件） |
| `SIMULATION_fd_evolution_pdes_lnotes.pdf` | 2.7 MB, 97 p | 演化型 PDE 有限差分讲义（范数、稳定性、CFL 等） |
| `SIMULATION_PolyAN.pdf` | 1.4 MB, 42 p | ECL 数值分析讲义 |
| `Composition_équipesDEPOL_S7_2026-27.xlsx` | 15 KB | 24 组（A1–D6）名单 |
| `EquipeSalleTable_DEPOLS726-27.pdf` | 345 KB | 论坛 16/11 附件：组—房间—桌号（内置浏览器未能打开，未读） |

Sources 页：Lelieveld et al., *Eur. Heart J.* 40(20):1590–1596 (2019), doi:10.1093/eurheartj/ehz135；INSEE 欧盟道路事故遇难者 1991–2023；CITEPA SECTEN 2024-06-19 版。
Culture générale：Arte《Le Dessous des cartes》；Jules Grandin（数据可视化）；openairmap.fr；earth.nullschool.net（NO₂ 等）；data.dansmoneau.fr；foreverpollution.eu（PFAS 地图）。

## 10. 不一致之处与待确认问题
1. **L1_1 截止时间**：cadrage 为 17:00，当天上午口头通知有矛盾，论坛 10:35 定为 **17:00**。
2. **周三口试结束时间**：Moodle 目录写 9h–12h15，栏目正文写 9h–12h；cadrage 写 9:00–12:15。
3. **Dubreuil 的领域**：présentation 写"物理化学与沉降机制"，cadrage 顾问表写"毒理学建模"。→ 沉降和 USEtox 问题都可以问他。
4. **能力代码**：présentation 写 C2N1 / C4N2 / C1N2；cadrage 写 C2N1 / C4I2 / C1C2。不影响做法。
5. **风场数据**：L1_2 与周五交付不附风场（代码须在没有风场文件时也能运行，或只依赖 `map.xlsx`）；但审计 ZIP 要附**1 个月**风场。两条规则不冲突，只是针对的交付物不同。
6. **风场文件名**有 3 种写法（Moodle、info PDF、实际下载），代码里文件名要与本地文件一致，并做存在性检查。
7. **审计场次**写着 3 月日期（旧版），以 N+1 通知为准。
8. 座位 PDF 的 Moodle 描述写"lundi 17/11/2025"（旧年份），PDF 内容为 16/11/2026。
9. Cadrage 提到 `map.xlsx` 有"nomenclature"工作表，实际文件中没有；正文残留了一段 AI 对话。
10. Phase 2 周五交付清单：présentation 写 code + résultats chiffrés + slides；cadrage 写 Matlab + slides + **Excel**——建议按三件都交准备。
