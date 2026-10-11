// Deck.pde - parses the Obsidian markdown deck into slides, blocks and styled spans.
//
// Rules (README, "The markdown"):
//   '---' alone on a line          new slide
//   '#', '##', '###' lines         titles, levels 1..3 (decreasing size)
//   <p class="fragment">..</p>     click-to-reveal paragraph, in document order
//   <li class="fragment">..</li>   click-to-reveal bullet
//   | a | b |                      pipe table (the |---| separator row is skipped)
//   *only italic text*             image stand-in: small and faded
//   ![alt](img/file.jpg)           a photo, relative to the markdown's folder; alt in italics if the file is missing
//   <!-- visual: NAME -->          pins the slide's background (Visuals.pde names); other comments are dropped
//   anything else                  static body text; blank lines split paragraphs
// Inline: <strong>/<b>, <em>/<i>, <code> and markdown **bold**, *italic*, `code`. Other tags are stripped.

static final int B_TITLE = 0, B_PARA = 1, B_FRAGMENT = 2, B_IMAGE = 3, B_TABLE = 4, B_PHOTO = 5;

class Span {
  String text; boolean bold, italic, code;
  Span(String text, boolean bold, boolean italic, boolean code) { this.text = text; this.bold = bold; this.italic = italic; this.code = code; }
}

class Block {
  int type, level = 0, fragmentIndex = -1;
  boolean bullet = false;
  ArrayList<Span> spans = new ArrayList<Span>();
  ArrayList<String[]> rows = new ArrayList<String[]>();   // tables only; rows.get(0) is the header
  String src = null;                                       // photos only, as written in the markdown
  Block(int type) { this.type = type; }
  String plain() { StringBuilder sb = new StringBuilder(); for (Span s : spans) sb.append(s.text); return sb.toString(); }
}

class Slide {
  ArrayList<Block> blocks = new ArrayList<Block>();
  int fragments = 0;
  String visual = null;            // from <!-- visual: NAME -->, else null for the seeded pick
  Block photo() { for (Block b : blocks) if (b.type == B_PHOTO) return b; return null; }
  String title() { for (Block b : blocks) if (b.type == B_TITLE) return b.plain(); return "(untitled)"; }
}

class Deck {
  ArrayList<Slide> slides = new ArrayList<Slide>();
  int fragments = 0;
  String source = "";

  Deck(String[] lines) {
    Slide cur = new Slide();
    ArrayList<String> para = new ArrayList<String>();
    ArrayList<String> table = new ArrayList<String>();
    for (int i = 0; i <= lines.length; i++) {
      String raw = i < lines.length ? lines[i] : "---";       // sentinel, flushes the last slide
      String line = raw.trim();
      if (line.contains("<!--")) {                              // read the visual pin, drop the comment
        java.util.regex.Matcher vm = java.util.regex.Pattern.compile("<!--\\s*visual:\\s*([A-Za-z0-9 _'-]+?)\\s*-->").matcher(line);
        if (vm.find()) cur.visual = vm.group(1).trim();
        line = line.replaceAll("<!--.*?-->", "").trim();
        if (line.length() == 0) continue;
      }
      if (!line.startsWith("|") && table.size() > 0) { cur.blocks.add(parseTable(table)); table.clear(); }
      if (line.equals("---")) {
        flushPara(cur, para);
        if (cur.blocks.size() > 0) slides.add(cur);
        cur = new Slide();
        continue;
      }
      if (line.length() == 0) { flushPara(cur, para); continue; }
      if (line.startsWith("#")) {
        flushPara(cur, para);
        int level = 0; while (level < line.length() && line.charAt(level) == '#') level++;
        Block b = new Block(B_TITLE); b.level = constrain(level, 1, 3);
        b.spans = parseInline(line.substring(level).trim());
        cur.blocks.add(b);
        continue;
      }
      if (line.startsWith("|")) { flushPara(cur, para); table.add(line); continue; }
      String lower = line.toLowerCase();
      if (lower.startsWith("<p class=\"fragment\"") || lower.startsWith("<li class=\"fragment\"")) {
        flushPara(cur, para);
        Block b = new Block(B_FRAGMENT);
        b.bullet = lower.startsWith("<li");
        b.spans = parseInline(line);
        b.fragmentIndex = cur.fragments++;
        cur.blocks.add(b);
        continue;
      }
      para.add(line);
    }
    for (Slide s : slides) fragments += s.fragments;
  }

  void flushPara(Slide cur, ArrayList<String> para) {
    if (para.size() == 0) return;
    String text = join(para.toArray(new String[0]), " ");
    para.clear();
    Block b;
    java.util.regex.Matcher im = java.util.regex.Pattern.compile("^!\\[(.*?)\\]\\((\\S+?)(?:\\s+\"[^\"]*\")?\\)$").matcher(text);
    if (im.matches()) {
      b = new Block(B_PHOTO); b.src = im.group(2); b.spans = parseInline(im.group(1));
      cur.blocks.add(b); return;
    }
    if (parseInline(text).size() == 0) return;          // a tag on its own, like <img>, leaves nothing to show
    if (text.length() > 2 && text.startsWith("*") && !text.startsWith("**") && text.endsWith("*") && text.indexOf('*', 1) == text.length() - 1) {
      b = new Block(B_IMAGE);
      b.spans = parseInline(text.substring(1, text.length() - 1));
    } else {
      b = new Block(B_PARA);
      b.spans = parseInline(text);
    }
    cur.blocks.add(b);
  }

  Block parseTable(ArrayList<String> lines) {
    Block b = new Block(B_TABLE);
    for (String line : lines) {
      String body = line.substring(1);
      if (body.endsWith("|")) body = body.substring(0, body.length() - 1);
      String[] cells = body.split("\\|", -1);
      boolean separator = true;
      for (int i = 0; i < cells.length; i++) {
        cells[i] = cells[i].trim();
        if (!cells[i].matches(":?-+:?")) separator = false;
      }
      if (separator && cells.length > 0) continue;
      b.rows.add(cells);
    }
    return b;
  }

  /** HTML tags and markdown markers to styled spans. */
  ArrayList<Span> parseInline(String s) {
    ArrayList<Span> out = new ArrayList<Span>();
    StringBuilder buf = new StringBuilder();
    boolean bold = false, italic = false, code = false;
    int i = 0, n = s.length();
    while (i < n) {
      char c = s.charAt(i);
      if (c == '<') {
        int end = s.indexOf('>', i);
        if (end < 0) { buf.append(c); i++; continue; }
        String tag = s.substring(i + 1, end).trim().toLowerCase();
        boolean closing = tag.startsWith("/");
        if (closing) tag = tag.substring(1).trim();
        int sp = tag.indexOf(' '); if (sp >= 0) tag = tag.substring(0, sp);
        boolean changes = tag.equals("strong") || tag.equals("b") || tag.equals("em") || tag.equals("i") || tag.equals("code");
        if (changes) {
          flush(out, buf, bold, italic, code);
          if (tag.equals("strong") || tag.equals("b")) bold = !closing;
          else if (tag.equals("em") || tag.equals("i")) italic = !closing;
          else code = !closing;
        } else if (tag.equals("br")) buf.append(' ');
        i = end + 1;                                   // every other tag is stripped
        continue;
      }
      if (c == '&') {
        int end = s.indexOf(';', i);
        if (end > i && end - i <= 8) {
          String ent = s.substring(i + 1, end);
          String rep = entity(ent);
          if (rep != null) { buf.append(rep); i = end + 1; continue; }
        }
      }
      if (!code && c == '`') {                         // markdown code
        flush(out, buf, bold, italic, code); code = true;
        int end = s.indexOf('`', i + 1);
        if (end < 0) end = n;
        buf.append(s, i + 1, end);
        flush(out, buf, bold, italic, code); code = false;
        i = min(n, end + 1);
        continue;
      }
      if (code) { buf.append(c); i++; continue; }
      if (c == '*' && i + 1 < n && s.charAt(i + 1) == '*') { flush(out, buf, bold, italic, code); bold = !bold; i += 2; continue; }
      if (c == '*') { flush(out, buf, bold, italic, code); italic = !italic; i++; continue; }
      buf.append(c); i++;
    }
    flush(out, buf, bold, italic, code);
    return out;
  }

  void flush(ArrayList<Span> out, StringBuilder buf, boolean bold, boolean italic, boolean code) {
    if (buf.length() == 0) return;
    out.add(new Span(buf.toString(), bold, italic, code));
    buf.setLength(0);
  }

  String entity(String e) {
    if (e.equals("amp")) return "&";
    if (e.equals("lt")) return "<";
    if (e.equals("gt")) return ">";
    if (e.equals("quot")) return "\"";
    if (e.equals("apos") || e.equals("#39")) return "'";
    if (e.equals("nbsp")) return " ";
    if (e.equals("rarr")) return "→";
    if (e.equals("middot")) return "·";
    if (e.equals("times")) return "×";
    if (e.startsWith("#x")) { try { return String.valueOf((char) Integer.parseInt(e.substring(2), 16)); } catch (Exception ex) { return null; } }
    if (e.startsWith("#")) { try { return String.valueOf((char) Integer.parseInt(e.substring(1))); } catch (Exception ex) { return null; } }
    return null;
  }
}
