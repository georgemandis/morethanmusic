#!/usr/bin/env python3
"""Turn a YouTube auto-caption .vtt into paragraphs of plain text.
YouTube's rolling captions repeat each line twice (once as it scrolls in, once settled);
cues carry <c> word timing tags. Keep each settled line once, drop tags, join, then
break into paragraphs on sentence-ish pauses every ~90 words."""
import re, sys, html
src = sys.argv[1]
lines = open(src, encoding='utf8').read().split('\n')
seen = []
for ln in lines:
    if not ln.strip() or '-->' in ln or ln.startswith(('WEBVTT','Kind:','Language:')): continue
    t = re.sub(r'<[^>]+>', '', ln)           # <c>, <00:00:01.000>, etc.
    t = html.unescape(t).strip()
    if not t or t == '[Music]' or t == '[Applause]' or t == '[Laughter]': continue
    if seen and seen[-1] == t: continue      # the scrolled-in duplicate
    seen.append(t)
text = ' '.join(seen)
text = re.sub(r'\s+', ' ', text)
# YouTube ASR has no punctuation; break into ~90-word paragraphs at natural fillers
words = text.split(' ')
paras, cur = [], []
for w in words:
    cur.append(w)
    if len(cur) >= 90 and re.match(r'^(so|and|but|now|okay|alright|all|right|um|uh|the|this|that|if|when|what|i|we|you|let)$', w.lower()):
        cur.pop(); paras.append(' '.join(cur)); cur = [w]
if cur: paras.append(' '.join(cur))
out = []
for p in paras:
    p = p.strip()
    if p: out.append(p[0].upper() + p[1:] + ('' if p.endswith(('.', '?', '!')) else '.'))
sys.stdout.write('\n\n'.join(out) + '\n')
