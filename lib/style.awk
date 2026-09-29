# kuhl-shell: shared gawk helpers for dir and tree. Load with gawk -f style.awk -e '...'
# and pass the palette as -v pal="$ATLAS_FRAME $ATLAS_ACCENT ... $ATLAS_GOOD".
function rgb(h) { return sprintf("\033[38;2;%d;%d;%dm", strtonum("0x" substr(h,2,2)), strtonum("0x" substr(h,4,2)), strtonum("0x" substr(h,6,2))) }
function human(n,   u, i) {
    split("B K M G T", u, " ")
    for (i = 1; n >= 1024 && i < 5; i++) n /= 1024
    return i == 1 ? n "B" : sprintf(n < 10 ? "%.1f%s" : "%.0f%s", n, u[i])
}
# drwxr-xr-x → rwxr-xr-x with r/w/x each in their own color
function perms(p,   s, i, c) {
    for (i = 2; i <= 10; i++) {
        c = substr(p, i, 1)
        s = s (c == "r" ? WARN : c == "w" ? BAD : c ~ /[xsStT]/ ? GOOD : FRAME) c
    }
    return s R
}
function rule(n,   s) { s = ""; while (n-- > 0) s = s "─"; return s }
function pad(n) { return sprintf("%*s", n > 0 ? n : 0, "") }
# classify(type, isdir, mode, name) sets ICON and COLOR for an entry. type is find's %y,
# isdir is 1 when it (or its link target) is a directory, mode is find's %M.
function classify(type, isdir, mode, name,   ext) {
    ext = tolower(name); sub(/.*\./, "", ext); if (ext == tolower(name)) ext = ""
    if (type == "l")          { ICON = isdir ? "" : ""; COLOR = LANG }
    else if (type == "d")     { ICON = ""; COLOR = B ACCENT }
    else if (mode ~ /x/)      { ICON = ""; COLOR = B GOOD }
    else if (ext in ARCH)     { ICON = ""; COLOR = WARN }
    else if (ext in IMG)      { ICON = ""; COLOR = GIT }
    else if (ext in CODE)     { ICON = ""; COLOR = LANG }
    else if (ext in CONF)     { ICON = ""; COLOR = SOFT }
    else if (ext in DOC)      { ICON = ""; COLOR = SOFT }
    else                      { ICON = ""; COLOR = "" }
    if (name ~ /^\./) COLOR = DIM COLOR
}
BEGIN {
    R = "\033[0m"; B = "\033[1m"; DIM = "\033[2m"
    split(pal, _c, " ")
    FRAME = rgb(_c[1]); ACCENT = rgb(_c[2]); SOFT = rgb(_c[3]); GIT = rgb(_c[4])
    LANG = rgb(_c[5]); WARN = rgb(_c[6]); BAD = rgb(_c[7]); GOOD = rgb(_c[8])
    split("zip tar gz tgz xz bz2 7z rar deb zst", _a, " "); for (_k in _a) ARCH[_a[_k]] = 1
    split("png jpg jpeg gif svg webp ico bmp", _a, " "); for (_k in _a) IMG[_a[_k]] = 1
    split("ts tsx js jsx mjs py php sh bash rs go c h cpp java rb lua", _a, " "); for (_k in _a) CODE[_a[_k]] = 1
    split("json toml yaml yml ini conf cfg env lock xml", _a, " "); for (_k in _a) CONF[_a[_k]] = 1
    split("md txt rst log pdf doc docx", _a, " "); for (_k in _a) DOC[_a[_k]] = 1
}
