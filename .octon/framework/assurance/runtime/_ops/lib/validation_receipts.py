import pathlib
import re


def field_from_markdown(path, field):
    path = pathlib.Path(path)
    if not path.is_file():
        return ""
    pattern = re.compile(rf"^[\s-]*{re.escape(field)}\s*:\s*(.+?)\s*$", re.IGNORECASE)
    for line in path.read_text(errors="replace").splitlines():
        match = pattern.match(line)
        if match:
            return match.group(1).strip().strip("`").strip('"')
    return ""


def validation_receipt_records_pass(path):
    path = pathlib.Path(path)
    if not path.is_file():
        return False
    if field_from_markdown(path, "verdict") == "pass":
        return True

    text = path.read_text(errors="replace")
    if re.search(r"All listed commands exited successfully\.?", text, re.IGNORECASE):
        return True

    table_rows = [
        line
        for line in text.splitlines()
        if re.match(r"^\|\s*`[^`]+`\s*\|\s*[^|]+\s*\|", line)
    ]
    if not table_rows:
        return False

    saw_pass = False
    for row in table_rows:
        cells = [cell.strip().lower() for cell in row.strip().strip("|").split("|")]
        if any(cell in {"fail", "failed", "error", "blocked"} for cell in cells):
            return False
        if any(cell == "pass" for cell in cells):
            saw_pass = True
    return saw_pass
