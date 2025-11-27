# import os

# # ====== CONFIG ======
# INPUT_DIR = r"C:\flutter\Srila Prabhupad Krpa\assets\audio\festival"  
# # folder with mp3 files
# OUTPUT_FILE = r"C:\flutter\Srila Prabhupad Krpa\lib\data\festival.dart"        # dart file to save

# # Book code mapping
# BOOK_NAMES = {
#     "BG": "Bhagavad-gita",
#     "BS": "Brahma Samhita",
#     "NOI": "Nectar of Instruction",
#     "NOD": "Nectar of Devotion",
#     "CC": "Caitanya-caritamrta",
#     "IV":"Interviews",
#     "SB":"Srimad Bhagavatam",
# }

# # Location code mapping
# LOCATION_NAMES = {
#     "LA": "Los Angeles",
#     "NY": "New York",
#     "VRN": "Vrindavan",
#     "LON": "London",
#     "SF": "San Francisco",
#     "MOM": "Montreal",
#     "STO": "Stockholm",
#     "BOM": "Bombay",
#     "CHI": "Chicago",
#     "PIT": "Pittsburgh",
#     "DEL": "Delhi",
#     "DET": "Detroit",
#     "SYD": "Sydney",
#     "HYD": "Hyderabad",
#     "TOR": "Toronto",
#     "AR": "Argentina",
#     "MEL": "Melbourne",
#     "SEA": "Seattle",
#     "FIJ": "Fiji",
#     "TIR": "Tirupati",
#     "PAR": "Paris",
#     "GAI": "Gainesville",
#     "MAU": "Mauritius",
#     "AUC": "Auckland",
#     "DAL": "Dallas",
# }

# def parse_filename(filename):
#     """
#     Example filename:
#     0474 BS 5-1 LA 05-10-1972 If you know simply Govinda then you know everything.mp3
#     """
#     name, _ = os.path.splitext(filename)

#     parts = name.split(" ", 5)  # split into 6 parts max
#     if len(parts) < 6:
#         return None  # invalid file

#     lecture_id = parts[0]
#     book_code = parts[1]
#     text_number = parts[2]
#     location_code = parts[3]
#     date = parts[4]
#     title = parts[5]

#     book = BOOK_NAMES.get(book_code, book_code)  # full name if found
#     location = LOCATION_NAMES.get(location_code, location_code)

#     return {
#         "id": lecture_id,
#         "book": book,
#         "textNumber": text_number,
#         "location": location,
#         "date": date,
#         "title": title,
#         "audioPath": f"assets/audio/{book_code}/{filename}"
#     }

# # Generate a variable name like 'bhagavadGitaLectures'
# def to_variable_name(book):
#     parts = book.replace("-", " ").replace("_", " ").split()
#     return parts[0].lower() + ''.join(word.capitalize() for word in parts[1:]) + "Lectures"

# def generate_dart(lectures, output_file):
#     with open(output_file, "w", encoding="utf-8") as f:
#         f.write("import '../../models/lecture.dart';\n\n")
#         var_name = to_variable_name(lectures[0]['book']) if lectures else "lectures"
#         f.write(f"final List<Lecture> {var_name} = [\n")

#         for lec in lectures:
#             f.write(f"""  Lecture(
#     id: "{lec['id']}",
#     title: "{lec['title']}",
#     book: "{lec['book']}",
#     date: "{lec['date']}",
#     location: "{lec['location']}",
#     audioPath: "{lec['audioPath']}",
#     textNumber: "{lec['textNumber']}",
#     transcript: [],
#   ),\n""")

#         f.write("];\n")

# def main():
#     lectures = []
#     for file in os.listdir(INPUT_DIR):
#         if file.endswith(".mp3"):
#             parsed = parse_filename(file)
#             if parsed:
#                 lectures.append(parsed)

#     generate_dart(lectures, OUTPUT_FILE)
#     print(f"✅ Generated {len(lectures)} lectures in {OUTPUT_FILE}")

# if __name__ == "__main__":
#     main()


import os

# ====== CONFIG ======
INPUT_DIR = r"C:\flutter\Srila Prabhupad Krpa\assets\audio\SrimadBhagavad"  
# folder with mp3 files
OUTPUT_FILE = r"C:\flutter\Srila Prabhupad Krpa\lib\data\SrimadBhagavad.dart"        # dart file to save

# Book code mapping
BOOK_NAMES = {
    "BG": "Bhagavad-gita",
    "BS": "Brahma Samhita",
    "NOI": "Nectar of Instruction",
    "ND": "Nectar of Devotion",
    "CC": "Caitanya-caritamrta",
    "IV":"Interviews",
    "SB":"Srimad Bhagavatam",
    "VP":"Vyasa-puja",
    "RY": "Ratha-yatra",
    "IN": "Initiations",
    "DI":"Festival",
    "KB":"Krishna Book",
    "LC":"Lectures",
    "MW":"Morning Walks",
    "IP":"Isopanishad",
    "PD":"Philosophy Discussions",
    "DA":"Devotee Address",
    "AS":"Asorted",
    "BJ":"Bhajans",
    "FE":"Festival",
    "LE":"Lectures",
    "QA":"Question Answer",
    "SB":"Srimad Bhagavatam",
    "bg":"Bhagavad-gita"
}

# Location code mapping
LOCATION_NAMES = {
    "IN": "India",
    "LA": "Los Angeles",
    "NY": "New York",
    "VRN": "Vrindavan",
    "LON": "London",
    "SF": "San Francisco",
    "MOM": "Montreal",
    "STO": "Stockholm",
    "BOM": "Bombay",
    "CHI": "Chicago",
    "PIT": "Pittsburgh",
    "DEL": "Delhi",
    "DET": "Detroit",
    "SYD": "Sydney",
    "HYD": "Hyderabad",
    "TOR": "Toronto",
    "AR": "Argentina",
    "MEL": "Melbourne",
    "SEA": "Seattle",
    "FIJ": "Fiji",
    "TIR": "Tirupati",
    "PAR": "Paris",
    "GAI": "Gainesville",
    "MAU": "Mauritius",
    "AUC": "Auckland",
    "DAL": "Dallas",
    "JPN": "Japan",
    "GER": "Germany",
    "ROM": "Romania",
    "MEX": "Mexico",
    "JAI": "Jaipur",
    "KOR": "Korea",
    "BOS": "Boston",
    "NV": "New Vrindavan",
    "BUD": "Budapest",
    "MON": "Montreal",
    "HW": "Hawai",
    "CAL": "California",
    "BHU":"Bhuavaneshwar",
    "ATL":"Atlanta",
    "MAY":"Mayapur",
    "GEN":"Germany",
    "HON":"Honolulu",
    "AHM":"Ahmedabad",
    "ED":"England",
    "FR":"France",
    "US":"United States",
    "UK":"United Kingdom",
    "CA":"Canada",
    "AU":"Australia",
}

# def parse_filename(filename):
#     """
#     Handles:
#     - 0474 BS 5-1 LA 05-10-1972 If you know simply Govinda then you know everything.mp3
#     - 1822 IV 30-12-1968 LA I can declare, they are all nonsense.mp3
#     - and partial/missing fields
#     """
#     name, _ = os.path.splitext(filename)
#     parts = name.strip().split()

#     # Try to detect which part is date (format: dd-mm-yyyy or similar)
#     date_idx = -1
#     for i, part in enumerate(parts):
#         if len(part) == 10 and part[2] == '-' and part[5] == '-':
#             date_idx = i
#             break

#     if date_idx == -1 or len(parts) < 3:
#         return None  # invalid file

#     lecture_id = parts[0]
#     book_code = parts[1]
#     # Try to get text_number if present (if next part is not a date)
#     text_number = ""
#     location_code = ""
#     title_start = 2

#     if date_idx == 2:
#         # Format: id book date ...
#         date = parts[2]
#         if len(parts) > 3:
#             location_code = parts[3]
#             title_start = 4
#     elif date_idx == 3:
#         # Format: id book text_number date ...
#         text_number = parts[2]
#         date = parts[3]
#         if len(parts) > 4:
#             location_code = parts[4]
#             title_start = 5
#     elif date_idx == 4:
#         # Format: id book text_number location date ...
#         text_number = parts[2]
#         location_code = parts[3]
#         date = parts[4]
#         title_start = 5
#     else:
#         # fallback
#         date = parts[date_idx]
#         title_start = date_idx + 1

#     title = " ".join(parts[title_start:]).strip()

#     book = BOOK_NAMES.get(book_code, book_code)
#     location = LOCATION_NAMES.get(location_code, location_code) if location_code else ""

#     return {
#         "id": lecture_id,
#         "book": book,
#         "textNumber": text_number,
#         "location": location,
#         "date": date,
#         "title": title,
#        "audioPath": os.path.join(INPUT_DIR, filename).replace("\\", "/")
#     }

def parse_filename(filename):
    """
    Flexible filename parser. Detects the date token and infers optional fields.

    Supports patterns like:
    - id book date location title
    - id book textNumber date location title
    - id book date title
    - id book textNumber location date title

    Returns None if required fields (id, book, date) are missing.
    """
    name, _ = os.path.splitext(filename)
    # Normalize any date+location tokens stuck together (e.g., 17-03-1974VRN)
    tokens = name.strip().split()
    normalized_parts = []
    for token in tokens:
        # Split patterns like dd-mm-yyyyXXX or yyyy-mm-ddXXX where XXX are 2-4 letters
        if '-' in token:
            pieces = token.split('-')
            if len(pieces) == 3 and pieces[2]:
                suffix = ''.join(ch for ch in pieces[2] if ch.isalpha())
                numeric_tail = pieces[2][:-len(suffix)] if suffix else pieces[2]
                if suffix and 2 <= len(suffix) <= 4 and numeric_tail.isdigit():
                    # Rebuild date and push suffix as separate token
                    date_candidate = f"{pieces[0]}-{pieces[1]}-{numeric_tail}"
                    normalized_parts.append(date_candidate)
                    normalized_parts.append(suffix)
                    continue
        # Split patterns like MW19-08-1976 (book+date combined)
        # Find first digit index
        first_digit_idx = -1
        for idx, ch in enumerate(token):
            if ch.isdigit():
                first_digit_idx = idx
                break
        if first_digit_idx > 0:
            prefix = token[:first_digit_idx]
            rest = token[first_digit_idx:]
            # rest might be a date token
            def looks_like_date(s: str) -> bool:
                if '-' not in s:
                    return False
                segs = s.split('-')
                return (
                    len(segs) == 3 and
                    all(seg.isdigit() for seg in segs) and
                    ((len(segs[0]) in (2,4)) and len(segs[1]) == 2 and len(segs[2]) in (2,4))
                )
            if prefix.isalpha() and 1 <= len(prefix) <= 3 and looks_like_date(rest):
                normalized_parts.append(prefix)
                normalized_parts.append(rest)
                continue
        normalized_parts.append(token)
    parts = normalized_parts

    if len(parts) < 3:
        return None

    def is_date_token(token: str) -> bool:
        if len(token) not in (8, 10):
            return False
        # Expect dd-mm-yy or dd-mm-yyyy
        if '-' not in token:
            return False
        pieces = token.split('-')
        if len(pieces) != 3:
            return False
        if not (pieces[0].isdigit() and pieces[1].isdigit() and pieces[2].isdigit()):
            return False
        # Accept dd-mm-yy, dd-mm-yyyy, or yyyy-mm-dd
        if not (
            (len(pieces[0]) == 2 and len(pieces[1]) == 2 and len(pieces[2]) in (2, 4))
            or (len(pieces[0]) == 4 and len(pieces[1]) == 2 and len(pieces[2]) == 2)
        ):
            return False
        return True

    # Find first date token from index 2 onwards
    date_idx = -1
    for i in range(2, len(parts)):
        if is_date_token(parts[i]):
            date_idx = i
            break

    # If no date found, try handling filenames like:
    # 0617 KB90—Summary Description of Lord Kṛṣṇa’s Pastimes.mp3
    # 0617 KB90-Summary Description of Lord Kṛṣṇa’s Pastimes.mp3
    if date_idx == -1:
        if len(parts) >= 2:
            second = parts[1]
            # Accept both em dash and hyphen as separator between code and title
            sep = '—' if '—' in second else ('-' if '-' in second else None)
            left = second
            right = ''
            if sep:
                left, right = second.split(sep, 1)

            # Extract alpha prefix as book code (e.g., KB) and digits as text number (e.g., 90)
            alpha_prefix = ''.join(ch for ch in left if ch.isalpha())
            numeric_suffix = ''.join(ch for ch in left if ch.isdigit())

            if alpha_prefix:
                lecture_id = parts[0]
                book_code = alpha_prefix.upper()
                text_number = numeric_suffix
                location_code = ""
                # Title is right part (if any) plus remaining tokens after the second token
                title_tokens = []
                if right:
                    title_tokens.append(right)
                if len(parts) > 2:
                    title_tokens.extend(parts[2:])
                title = " ".join(t.strip() for t in title_tokens if t.strip())

                folder_name = os.path.basename(INPUT_DIR)
                return {
                    "id": lecture_id,
                    "book": BOOK_NAMES.get(book_code, book_code),
                    "textNumber": text_number,
                    "location": "",
                    "date": "",
                    "title": title,
                    "audioPath": f"audio/{folder_name}/{filename}"
                }

        return None

    lecture_id = parts[0]
    book_code = parts[1].upper()
    date_str = parts[date_idx]

    text_number = ""
    location_code = ""
    title_start = date_idx + 1

    if date_idx == 2:
        # id book date [location] title
        if len(parts) > 3:
            # If next token after date seems like a location code (all letters and <= 4)
            maybe_loc = parts[3].upper()
            if maybe_loc.isalpha() and 2 <= len(maybe_loc) <= 4:
                location_code = maybe_loc
                title_start = 4
            else:
                title_start = 3
    elif date_idx == 3:
        # id book textNumber date [location] title
        text_number = parts[2]
        if len(parts) > 4:
            maybe_loc = parts[4].upper()
            if maybe_loc.isalpha() and 2 <= len(maybe_loc) <= 4:
                location_code = maybe_loc
                title_start = 5
            else:
                title_start = 4
    elif date_idx == 4:
        # Could be: id book textNumber location date title
        text_number = parts[2]
        location_code = parts[3].upper()
        title_start = 5
    else:
        # Unexpected spacing, assume everything after date is title
        title_start = date_idx + 1

    title = " ".join(parts[title_start:]).strip()

    # Extract folder name from INPUT_DIR for dynamic audioPath
    folder_name = os.path.basename(INPUT_DIR)

    return {
        "id": lecture_id,
        "book": BOOK_NAMES.get(book_code, book_code),
        "textNumber": text_number,
        "location": LOCATION_NAMES.get(location_code, location_code) if location_code else "",
        "date": date_str,
        "title": title,
        # Use project-relative path expected by Flutter assets
        "audioPath": f"audio/{folder_name}/{filename}"
    }
# Generate a variable name like 'bhagavadGitaLectures'
def to_variable_name(book):
    parts = book.replace("-", " ").replace("_", " ").split()
    return parts[0].lower() + ''.join(word.capitalize() for word in parts[1:]) + "Lectures"


def parse_bhajan_filename(filename):
    """
    Parse bhajan/kirtan style filenames to extract:
    - id (fallback to filename stem when no numeric id at start)
    - title (human-friendly)
    - optional date and location (best-effort)

    Works for Bhajan/Japa/Kirtan folders alike.
    """
    name, _ = os.path.splitext(filename)
    tokens = name.strip().split()

    if not tokens:
        return None

    def is_date_token(token: str) -> bool:
        if len(token) not in (8, 10):
            return False
        if '-' not in token:
            return False
        pieces = token.split('-')
        if len(pieces) != 3:
            return False
        if not (pieces[0].isdigit() and pieces[1].isdigit() and pieces[2].isdigit()):
            return False
        if not (
            (len(pieces[0]) == 2 and len(pieces[1]) == 2 and len(pieces[2]) in (2, 4))
            or (len(pieces[0]) == 4 and len(pieces[1]) == 2 and len(pieces[2]) == 2)
        ):
            return False
        return True

    # Detect id if first token is numeric, otherwise use the full stem as id
    id_token = tokens[0] if tokens[0].isdigit() else name

    # Start parsing from index 1 if first token was numeric id
    start_idx = 1 if tokens[0].isdigit() else 0

    date_value = None
    location_code = None
    title_start = start_idx

    # Find a date token in remaining tokens
    date_idx = -1
    for i in range(start_idx, len(tokens)):
        if is_date_token(tokens[i]):
            date_idx = i
            break

    if date_idx != -1:
        date_value = tokens[date_idx]
        title_start = date_idx + 1
        # Optional location next
        if title_start < len(tokens):
            maybe_loc = tokens[title_start]
            if maybe_loc.isalpha() and 2 <= len(maybe_loc) <= 4:
                location_code = maybe_loc
                title_start += 1

    title = " ".join(tokens[title_start:]).strip()
    if not title:
        # Fallback: use full stem without id/date/location tokens
        title = name

    folder_name = os.path.basename(INPUT_DIR)
    return {
        "id": id_token,
        "title": title,
        "type": "Bhajan",  # will be overridden based on OUTPUT_FILE
        "audioPath": f"audio/{folder_name}/{filename}",
        "date": date_value or "",
        "location": LOCATION_NAMES.get(location_code, location_code) if location_code else "",
    }


def _determine_list_name(output_file: str) -> str:
    lower = output_file.replace('\\', '/').lower()
    if lower.endswith('/japa.dart'):
        return 'japaKirtans'
    if lower.endswith('/bhajan.dart'):
        return 'bhajanKirtans'
    if lower.endswith('/kirtan.dart'):
        return 'kirtanKirtans'
    return 'kirtanKirtans'


def generate_dart_kirtans(items, output_file, list_name: str):
    def esc(s: str) -> str:
        return s.replace('\\', r'\\').replace('"', r'\"')

    with open(output_file, "w", encoding="utf-8") as f:
        # data/ -> models/ is one directory up
        f.write("import '../models/kirtan.dart';\n\n")
        f.write(f"final List<Kirtan> {list_name} = [\n")

        for it in items:
            date_part = f",\n    date: \"{esc(it['date'])}\"" if it.get('date') else ""
            location_part = f",\n    location: \"{esc(it['location'])}\"" if it.get('location') else ""
            f.write(
                f"""  Kirtan(
    id: \"{esc(it['id'])}\",\n    title: \"{esc(it['title'])}\",\n    type: \"{esc(it['type'])}\",\n    audioPath: \"{esc(it['audioPath'])}\"{date_part}{location_part},\n  ),\n"""
            )

        f.write("]\n")


def generate_dart_lectures(items, output_file, var_name: str):
    def esc(s: str) -> str:
        return s.replace('\\', r'\\').replace('"', r'\"')

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("import '../../models/lecture.dart';\n\n")
        f.write(f"final List<Lecture> {var_name} = [\n")
        for lec in items:
            f.write(
                f"""  Lecture(
    id: \"{esc(lec['id'])}\",\n    title: \"{esc(lec['title'])}\",\n    book: \"{esc(lec['book'])}\",\n    date: \"{esc(lec['date'])}\",\n    location: \"{esc(lec['location'])}\",\n    audioPath: \"{esc(lec['audioPath'])}\",\n    textNumber: \"{esc(lec['textNumber'])}\",\n    transcript: [],\n  ),\n"""
            )
        f.write("]\n")


# Replace main to emit Lecture for discussion, otherwise Kirtan lists
def main():
    lower_out = OUTPUT_FILE.replace('\\', '/').lower()
    is_discussion = lower_out.endswith('/discussion.dart')
    is_devotee_address = lower_out.endswith('/devoteeaddress.dart')
    is_asorted = lower_out.endswith('/asorted.dart')
    is_srimad_bhagavatam = lower_out.endswith('/srimadbhagavad.dart')

    if is_discussion or is_devotee_address or is_asorted or is_srimad_bhagavatam:
        lectures = []
        for file in os.listdir(INPUT_DIR):
            if file.lower().endswith((".mp3", ".m4a", ".wav")):
                parsed = parse_filename(file)
                if parsed:
                    lectures.append(parsed)
                else:
                    print(f"Skipped: {file}")
        lectures.sort(key=lambda x: (x["id"], x["date"], x["title"]))
        var_name = (
            "discussionLectures" if is_discussion else (
                "devoteeAddressLectures" if is_devotee_address else (
                    "srimadBhagavatamLectures" if is_srimad_bhagavatam else "asortedLectures"
                )
            )
        )
        generate_dart_lectures(lectures, OUTPUT_FILE, var_name=var_name)
        print(f"Generated {len(lectures)} lectures in {OUTPUT_FILE}")
        return

    items = []
    for file in os.listdir(INPUT_DIR):
        # Case-insensitive audio extension check
        if file.lower().endswith((".mp3", ".m4a", ".wav")):
            parsed = parse_bhajan_filename(file)
            if parsed:
                items.append(parsed)
            else:
                print(f"Skipped: {file}")

    # Determine list name and type based on OUTPUT_FILE
    list_name = _determine_list_name(OUTPUT_FILE)
    desired_type = 'Japa' if list_name == 'japaKirtans' else ('Bhajan' if list_name == 'bhajanKirtans' else 'Kirtan')
    for it in items:
        it['type'] = desired_type

    # Keep deterministic order
    items.sort(key=lambda x: (str(x.get("id", "")), str(x.get("date", "")), str(x.get("title", ""))))
    generate_dart_kirtans(items, OUTPUT_FILE, list_name)
    # Avoid Unicode in Windows cp1252 terminals
    print(f"Generated {len(items)} {desired_type.lower()} items in {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
