#!/usr/bin/env python3
# make_dart_transcript.py
# Reads input.txt and writes a Dart-safe transcript list to output.txt
# Produces: transcript: [ TranscriptLine(time: Duration(seconds: X), text: """..."""), ... ],

import re
from pathlib import Path

INPUT = Path("input.txt")
OUTPUT = Path("output.txt")

def parse_time_to_seconds(t):
    # t can be "mm:ss" or "hh:mm:ss" or "m:ss"
    parts = [int(p) for p in t.split(":")]
    if len(parts) == 2:
        minutes, seconds = parts
        return minutes * 60 + seconds
    elif len(parts) == 3:
        hours, minutes, seconds = parts
        return hours * 3600 + minutes * 60 + seconds
    else:
        return 0

def sanitize_text(s):
    # Remove zero-width / control unicode that can break editors
    s = re.sub(r"[\u200b\u200c\u200d\u202a-\u202e\u2060]", "", s)
    # Normalize newlines
    s = s.replace('\r\n', '\n').replace('\r', '\n')
    s = s.strip()
    # If the content contains triple double-quotes, replace those with triple single-quotes
    # so they don't end the Dart triple-double-quoted string.
    s = s.replace('"""', "'''")
    return s

def find_timestamps(text):
    # Match [03:20], 03:20, [1:02:30], 1:02:30 etc.
    # We'll prefer bracketed timestamps but accept bare timestamps too.
    pattern = re.compile(r'\[(\d{1,2}:\d{2}(?::\d{2})?)\]|\b(\d{1,2}:\d{2}(?::\d{2})?)\b')
    return [m for m in pattern.finditer(text)]

def split_by_timestamps(text):
    matches = find_timestamps(text)
    if not matches:
        # no timestamps: return single TranscriptLine at 0 seconds
        return [(0, sanitize_text(text))] if text.strip() else []
    items = []
    for i, m in enumerate(matches):
        time_str = m.group(1) or m.group(2)
        start = m.end()
        end = matches[i+1].start() if i+1 < len(matches) else len(text)
        segment = text[start:end].strip()
        if segment:
            items.append((parse_time_to_seconds(time_str), sanitize_text(segment)))
    # Sometimes there's content before first timestamp - keep as time 0 if present
    first = matches[0]
    if first.start() > 0:
        leading = text[:first.start()].strip()
        if leading:
            items.insert(0, (0, sanitize_text(leading)))
    return items

def make_dart_transcript_block(items):
    # items: list of (seconds, text)
    lines = []
    lines.append("transcript: [")
    for seconds, text in items:
        # Indent and write transcript line
        # Use triple-double quotes for Dart string literal ("""...""")
        # We already replaced any internal """ with ''' in sanitize_text.
        dart_text = '"""\n' + text + '\n"""'
        entry = f"  TranscriptLine(time: Duration(seconds: {seconds}), text: {dart_text}),"
        lines.append(entry)
    lines.append("],")
    return "\n".join(lines)

def main():
    if not INPUT.exists():
        print(f"Error: {INPUT} not found. Create input.txt and paste your raw transcript in it.")
        return
    raw = INPUT.read_text(encoding="utf-8")
    # Normalize and sanitize initial text (we'll sanitize segments individually later)
    raw = raw.replace('\r\n', '\n').replace('\r', '\n')
    items = split_by_timestamps(raw)
    if not items:
        print("Warning: no transcript content found.")
    block = make_dart_transcript_block(items)
    OUTPUT.write_text(block, encoding="utf-8")
    print(f"✔ Wrote Dart transcript block with {len(items)} entries to {OUTPUT}")

if __name__ == "__main__":
    main()
