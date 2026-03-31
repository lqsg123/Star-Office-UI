#!/usr/bin/env python3
"""Update Star Office UI state (for testing or agent-driven sync).

For automatic state sync from OpenClaw: add a rule in your agent SOUL.md or AGENTS.md:
  Before starting a task: run `python3 set_state.py writing "doing XYZ" --summary "具体内容"`.
  After finishing: run `python3 set_state.py idle "ready"`.
The office UI reads state from the same state.json this script writes.
"""

import json
import os
import sys
from datetime import datetime

STATE_FILE = os.environ.get(
    "STAR_OFFICE_STATE_FILE",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "state.json"),
)

VALID_STATES = [
    "idle",
    "writing",
    "receiving",
    "replying",
    "researching",
    "executing",
    "syncing",
    "error",
    "working",
    "waiting_subagent"
]

def load_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {
        "state": "idle",
        "detail": "待命中...",
        "progress": 0,
        "updated_at": datetime.now().isoformat()
    }

def save_state(state):
    with open(STATE_FILE, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python set_state.py <state> [detail] [--summary '任务总结']")
        print(f"状态选项: {', '.join(VALID_STATES)}")
        print("\n例子:")
        print("  python set_state.py idle")
        print("  python set_state.py writing '在写热点日报模板' --summary '已完成前3个板块，正处理第4个'")
        sys.exit(1)

    state_name = sys.argv[1]
    detail = ""
    summary = ""

    # Parse args
    i = 2
    while i < len(sys.argv):
        if sys.argv[i] == "--summary" and i + 1 < len(sys.argv):
            summary = sys.argv[i + 1]
            i += 2
        else:
            detail = sys.argv[i]
            i += 1

    if state_name not in VALID_STATES:
        print(f"无效状态: {state_name}")
        print(f"有效选项: {', '.join(VALID_STATES)}")
        sys.exit(1)

    state = load_state()
    state["state"] = state_name
    state["detail"] = detail
    if summary:
        state["summary"] = summary
    state["updated_at"] = datetime.now().isoformat()

    save_state(state)
    print(f"状态已更新: {state_name} - {detail}")
    if summary:
        print(f"总结: {summary}")
