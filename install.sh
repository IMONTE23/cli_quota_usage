#!/usr/bin/env bash
set -e

TARGET_DIR="$HOME/.gemini/antigravity-cli"
TARGET_SCRIPT="$TARGET_DIR/statusline.py"
TARGET_SETTINGS="$TARGET_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/statusline.py"

echo -e "\033[1;36m==> Installing Antigravity CLI Custom Statusline (macOS / Linux)...\033[0m"

# 1. Ensure target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    echo -e "\033[92mCreated directory: $TARGET_DIR\033[0m"
fi

# 2. Copy script and set execution permission
if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo -e "\033[91mError: Source script '$SOURCE_SCRIPT' not found.\033[0m"
    exit 1
fi

cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"
echo -e "\033[92mCopied script to: $TARGET_SCRIPT\033[0m"

# 3. Update or create settings.json safely via Python
python3 - <<EOF
import json
import os

settings_path = "$TARGET_SETTINGS"
script_path = "$TARGET_SCRIPT"

config = {}
if os.path.exists(settings_path):
    try:
        with open(settings_path, "r", encoding="utf-8") as f:
            content = f.read().strip()
            if content:
                config = json.loads(content)
    except Exception as e:
        print(f"\033[93mWarning: Failed to parse existing settings.json ({e}). Creating backup.\033[0m")
        os.system(f'cp "{settings_path}" "{settings_path}.bak"')
        config = {}

config["statusLine"] = {
    "type": "command",
    "command": script_path,
    "enabled": True,
    "stack_with_default": True
}

with open(settings_path, "w", encoding="utf-8") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write("\n")

print(f"\033[92mUpdated configuration: {settings_path}\033[0m")
EOF

echo -e "\n\033[92mInstallation completed successfully!\033[0m"
echo -e "\033[1;36mLaunch 'agy' in your terminal to see the statusline in action.\033[0m"
