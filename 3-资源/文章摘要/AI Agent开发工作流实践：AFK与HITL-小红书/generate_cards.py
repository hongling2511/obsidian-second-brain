from pathlib import Path
import re
import textwrap

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).parent
W, H = 1080, 1440

FONT_PATH = "/Library/Fonts/Arial Unicode.ttf"
if not Path(FONT_PATH).exists():
    FONT_PATH = "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"


def font(size):
    return ImageFont.truetype(FONT_PATH, size)


F_TITLE = font(72)
F_SUBTITLE = font(40)
F_BODY = font(36)
F_SMALL = font(28)
F_LABEL = font(26)
F_CODE = font(31)

BG = "#0E1117"
PANEL = "#161B22"
PANEL_2 = "#1F2937"
TEXT = "#F5F7FA"
MUTED = "#AAB4C3"
LINE = "#303A4A"
CYAN = "#34D3E4"
GREEN = "#7DDC86"
YELLOW = "#F4C76B"
PINK = "#FF7AA2"
RED = "#FF6B6B"


def draw_bg(draw):
    draw.rectangle((0, 0, W, H), fill=BG)
    for i in range(0, W, 96):
        draw.line((i, 0, i - 320, H), fill="#141A24", width=2)
    draw.ellipse((-220, -180, 420, 420), fill="#132B36")
    draw.ellipse((760, 1050, 1300, 1580), fill="#27213B")


def wrap_text(text, max_chars):
    lines = []
    for raw in text.split("\n"):
        if not raw:
            lines.append("")
            continue
        lines.extend(textwrap.wrap(raw, width=max_chars, break_long_words=False))
    return lines


def wrap_text_px(draw, text, fnt, max_width):
    lines = []
    for raw in text.split("\n"):
        if not raw:
            lines.append("")
            continue
        current = ""
        tokens = re.findall(r"[A-Za-z0-9_./+-]+|\s+|.", raw)
        for token in tokens:
            if token in "，。、：；！？）】」』" and current:
                current += token
                continue
            candidate = current + token
            bbox = draw.textbbox((0, 0), candidate, font=fnt)
            if bbox[2] - bbox[0] <= max_width or not current:
                current = candidate
            else:
                lines.append(current.rstrip())
                if draw.textbbox((0, 0), token, font=fnt)[2] <= max_width:
                    current = token.lstrip()
                else:
                    current = ""
                    for ch in token:
                        candidate = current + ch
                        bbox = draw.textbbox((0, 0), candidate, font=fnt)
                        if bbox[2] - bbox[0] <= max_width or not current:
                            current = candidate
                        else:
                            lines.append(current)
                            current = ch
        if current:
            lines.append(current.rstrip())
    return lines


def text_block(draw, xy, text, fnt, fill=TEXT, max_chars=22, line_gap=14, max_width=None):
    x, y = xy
    if max_width is None:
        max_width = min(900, int(max_chars * fnt.size * 0.88))
    for line in wrap_text_px(draw, text, fnt, max_width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += fnt.size + line_gap
    return y


def pill(draw, xy, text, fill, fg=BG):
    x, y = xy
    pad_x, pad_y = 18, 9
    bbox = draw.textbbox((0, 0), text, font=F_LABEL)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    rect = (x, y, x + tw + pad_x * 2, y + th + pad_y * 2)
    draw.rounded_rectangle(rect, radius=22, fill=fill)
    draw.text((x + pad_x, y + pad_y - 2), text, font=F_LABEL, fill=fg)
    return rect[2] + 12


def card_frame(title, kicker, page):
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    draw_bg(draw)
    draw.rounded_rectangle((54, 54, W - 54, H - 54), radius=44, outline=LINE, width=2, fill=None)
    pill(draw, (88, 88), kicker, CYAN)
    draw.text((88, 1270), "AI Agent 开发工作流", font=F_SMALL, fill=MUTED)
    draw.text((W - 150, 1270), f"{page:02d}/09", font=F_SMALL, fill=MUTED)
    y = text_block(draw, (88, 170), title, F_TITLE, TEXT, max_chars=11, line_gap=12)
    return img, draw, y


def bullet(draw, x, y, text, color=CYAN, max_chars=24):
    draw.rounded_rectangle((x, y + 9, x + 14, y + 23), radius=7, fill=color)
    return text_block(draw, (x + 34, y), text, F_BODY, TEXT, max_chars=max_chars, line_gap=10)


def panel(draw, box, title, body, color=CYAN):
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=28, fill=PANEL, outline=LINE, width=2)
    draw.rectangle((x1, y1, x1 + 10, y2), fill=color)
    draw.text((x1 + 34, y1 + 30), title, font=F_SUBTITLE, fill=color)
    text_block(draw, (x1 + 34, y1 + 90), body, F_BODY, TEXT, line_gap=10, max_width=x2 - x1 - 78)


def save(img, idx):
    img.save(OUT_DIR / f"{idx:02d}.png", quality=95)


def main():
    img, draw, y = card_frame("别让 AI 直接写代码", "封面", 1)
    text_block(draw, (88, y + 48), "更稳的 Agent 开发方式，是把工作拆成两类：", F_SUBTITLE, MUTED, max_chars=16)
    panel(draw, (88, 610, 506, 900), "HITL", "人负责判断：需求、边界、品味、QA。", PINK)
    panel(draw, (574, 610, 992, 900), "AFK", "Agent 执行：实现、测试、修 bug。", GREEN)
    text_block(draw, (88, 1010), "人负责让事情做对，Agent 负责把事情做完。", F_SUBTITLE, TEXT, max_chars=16)
    save(img, 1)

    img, draw, y = card_frame("先分清：什么能交给 Agent", "核心判断", 2)
    panel(draw, (88, 360, 992, 640), "AFK 任务", "目标清楚，有验收标准，失败能被测试、类型检查或 QA 复现。", GREEN)
    panel(draw, (88, 700, 992, 980), "HITL 任务", "需要产品判断、架构取舍、领域语言、UI 品味或风险判断。", PINK)
    text_block(draw, (88, 1080), "把 HITL 伪装成 AFK，是 AI 项目返工的开始。", F_SUBTITLE, YELLOW, max_chars=16)
    save(img, 2)

    img, draw, y = card_frame("完整流程长这样", "流程", 3)
    steps = ["想法 / brief", "Grill Me 澄清需求", "写 PRD，确定目的地", "拆成垂直切片 issue", "Agent AFK 实现", "TDD + 测试 + 自动 review", "人工 QA，再生成新 issue"]
    yy = 350
    for i, step in enumerate(steps, 1):
        draw.rounded_rectangle((112, yy, 968, yy + 88), radius=24, fill=PANEL)
        draw.ellipse((138, yy + 24, 178, yy + 64), fill=CYAN if i < 5 else GREEN)
        draw.text((151, yy + 22), str(i), font=F_LABEL, fill=BG)
        draw.text((208, yy + 23), step, font=F_BODY, fill=TEXT)
        yy += 118
    save(img, 3)

    img, draw, y = card_frame("先用 Grill Me 问清楚", "需求澄清", 4)
    y = text_block(draw, (88, 350), "不要一上来让 AI 写计划。先让它连续追问，直到你们真的对齐。", F_SUBTITLE, TEXT, max_chars=17)
    y += 36
    for item in [
        "这个需求为什么存在？",
        "哪些边界情况必须拍板？",
        "哪些词需要统一定义？",
        "哪些内容这次明确不做？",
        "如果失败，用户会在哪里感知到？",
    ]:
        y = bullet(draw, 112, y + 20, item, PINK)
    text_block(draw, (88, 1130), "AI 在这里不是替你决定，而是逼你把决策树走完。", F_SUBTITLE, YELLOW, max_chars=17)
    save(img, 4)

    img, draw, y = card_frame("PRD 只是目的地，不是真理", "PRD", 5)
    y = text_block(draw, (88, 350), "够用的 PRD 包含：问题、方案、用户故事、实现决策、测试决策、Out of scope。", F_SUBTITLE, TEXT, max_chars=18)
    y += 38
    panel(draw, (88, y, 992, y + 260), "不要过度打磨", "前面已经通过 Grill Me 对齐，PRD 的价值是压缩共同理解，不是写一份完美文档。", CYAN)
    panel(draw, (88, y + 330, 992, y + 590), "警惕 doc rot", "旧 PRD 如果长期留在仓库里，可能误导后续 Agent。完成后关闭或归档。", YELLOW)
    save(img, 5)

    img, draw, y = card_frame("拆任务时，别按层拆", "垂直切片", 6)
    panel(draw, (88, 335, 992, 585), "不推荐", "第一步改数据库，第二步改 API，第三步改前端。反馈太晚。", RED)
    panel(draw, (88, 660, 992, 950), "推荐", "每个 issue 贯穿数据库、服务、UI 和测试。做完就能验证一条真实路径。", GREEN)
    text_block(draw, (88, 1060), "垂直切片像 tracer bullet，能尽早发现方向有没有打偏。", F_SUBTITLE, TEXT, max_chars=17)
    save(img, 6)

    img, draw, y = card_frame("AFK Loop 怎么跑", "执行", 7)
    flow = "读取 issue → 选未阻塞任务 → 探索代码 → 确认接口 → 写失败测试 → 实现 → 跑测试和类型检查 → 提交 → 关闭 issue"
    text_block(draw, (88, 345), flow, F_CODE, TEXT, max_chars=18, line_gap=18)
    panel(draw, (88, 760, 992, 1010), "关键约束", "Agent 只做 AFK issue。每个 issue 必须有验收标准和反馈方式。", CYAN)
    text_block(draw, (88, 1110), "并行不是越多越好，依赖关系清楚时才值得并行。", F_SUBTITLE, YELLOW, max_chars=17)
    save(img, 7)

    img, draw, y = card_frame("TDD + QA 提高质量", "反馈闭环", 8)
    panel(draw, (88, 335, 992, 585), "TDD", "先写失败测试，再写实现。这样 Agent 不容易先写一堆代码，再补表面测试。", GREEN)
    panel(draw, (88, 650, 992, 900), "人工 QA", "AI 可以写 QA plan，但体验顺不顺、术语别不别扭，必须人来判断。", PINK)
    text_block(draw, (88, 1030), "测试让 Agent 不盲写，QA 把人的品味压回系统。", F_SUBTITLE, TEXT, max_chars=17)
    save(img, 8)

    img, draw, y = card_frame("可以直接照抄的实践清单", "落地", 9)
    y = 340
    for item in [
        "写 brief 时同时说明 what 和 why",
        "用 Grill Me 问到关键决策都清楚",
        "把 PRD 拆成 3 到 5 个垂直切片",
        "每个 issue 标注 AFK 或 HITL",
        "AFK issue 必须有测试和验收标准",
        "让 AI 生成 QA plan，人手动验收",
        "QA 问题重新写成 issue，继续循环",
    ]:
        y = bullet(draw, 112, y + 18, item, CYAN, max_chars=22)
    text_block(draw, (88, 1140), "HITL 负责让事情做对，AFK 负责把事情做完。", F_SUBTITLE, YELLOW, max_chars=16)
    save(img, 9)


if __name__ == "__main__":
    main()
