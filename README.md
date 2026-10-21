# Antigravity CLI Quota Statusline

Custom statusline สำหรับ **Google Antigravity CLI (`agy`)** แสดงปริมาณการใช้งานโควตา (Quota Usage) แยกตามตระกูลโมเดล (Gemini, Argon, Claude) พร้อม Progress Bar แสดงแถบสีตามระดับคงเหลือ และเวลานับถอยหลังการรีเซ็ตโควตา

---

## 📸 Preview

```text
*[Gemini]* 5h:[█████] 99% (2h)  Wk:[████░] 87% (2.9d)  |  [Argon] Wk:[█░░░░] 6% (6d)  |  [Claude] 5h:[█████] 100% (4h)  Wk:[██░░░] 37% (4.2d)
```

---

## ✨ Features

- **Multi-Model Quota Tracking**: จัดกลุ่มโควตาแยกตามตระกูลโมเดลอัตโนมัติ (`Gemini`, `Argon`, `Claude`) ทั้งแบบ 5 ชั่วโมง (`5h`) และรายสัปดาห์ (`Wk`)
- **Visual Progress Bar**: แถบความคืบหน้าแบบบล็อก ANSI สวยงาม
- **Color-Coded Status**:
  - 🟢 **สีเขียว**: โควตาคงเหลือ $\ge$ 50%
  - 🟡 **สีเหลือง**: โควตาคงเหลือ 20% - 49%
  - 🔴 **สีแดง**: โควตาคงเหลือ $<$ 20%
- **Active Model Highlight**: ไฮไลต์ชื่อโมเดลที่กำลังใช้งานอยู่ด้วยเครื่องหมายดอกจันและสี Cyan เช่น `*[Gemini]*`
- **Reset Countdown**: แสดงเวลาคงเหลือก่อนรอบรีเซ็ตโควตา (เช่น `2h`, `2.9d`)
- **Adaptive Layout**: ปรับขนาดแถบและความละเอียดอัตโนมัติตามความกว้างหน้าจอเทอร์มินัล (Terminal Width)
- **Cross-Platform**: รองรับทั้ง **macOS**, **Linux** (ผ่าน Python 3) และ **Windows** (ผ่าน PowerShell)
- **Non-Destructive**: ทำงานควบคู่กับแถบสถานะเริ่มต้นของ CLI (`stack_with_default: true`)

---

## 📁 โครงสร้างโปรเจ็ค

```text
cli_quota_usage/
├── statusline.py           # สคริปต์ Python สำหรับ macOS / Linux (และ Windows ที่มี Python)
├── install.sh              # สคริปต์ติดตั้งอัตโนมัติสำหรับ macOS / Linux
├── statusline.ps1          # สคริปต์ PowerShell สำหรับ Windows
├── install.ps1             # สคริปต์ติดตั้งอัตโนมัติสำหรับ Windows
├── settings.example.json   # ตัวอย่างคอนฟิก settings.json
├── statusline_setup_guide.txt # เอกสารคู่มืออ้างอิงเดิม
└── README.md               # เอกสารแนะนำการใช้งาน
```

---

## 🚀 การติดตั้ง (Installation)

### สำหรับ macOS / Linux

#### วิธีที่ 1: ติดตั้งอัตโนมัติ (แนะนำ)
เปิด Terminal ในโฟลเดอร์โปรเจ็คแล้วรันคำสั่ง:

```bash
chmod +x install.sh
./install.sh
```

#### วิธีที่ 2: ติดตั้งด้วยตนเอง (Manual)
1. คัดลอกสคริปต์:
   ```bash
   mkdir -p ~/.gemini/antigravity-cli
   cp statusline.py ~/.gemini/antigravity-cli/statusline.py
   chmod +x ~/.gemini/antigravity-cli/statusline.py
   ```
2. แก้ไขไฟล์ `~/.gemini/antigravity-cli/settings.json` เพิ่มบล็อก `"statusLine"`:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "/Users/<USERNAME>/.gemini/antigravity-cli/statusline.py",
       "enabled": true,
       "stack_with_default": true
     }
   }
   ```

---

### สำหรับ Windows

#### วิธีที่ 1: ติดตั้งอัตโนมัติ (แนะนำ)
เปิด PowerShell ในโฟลเดอร์โปรเจ็คแล้วรันคำสั่ง:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

#### วิธีที่ 2: ติดตั้งด้วยตนเอง (Manual)
1. คัดลอกสคริปต์:
   ```powershell
   New-Item -ItemType Directory -Force -Path "$HOME\.gemini\antigravity-cli"
   Copy-Item -Path ".\statusline.ps1" -Destination "$HOME\.gemini\antigravity-cli\statusline.ps1"
   ```
2. แก้ไขไฟล์ `$HOME\.gemini\antigravity-cli\settings.json` เพิ่มบล็อก `"statusLine"`:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/<USERNAME>/.gemini/antigravity-cli/statusline.ps1",
       "enabled": true,
       "stack_with_default": true
     }
   }
   ```

---

## 🎮 การเปิดใช้งานและคำสั่งควบคุม

เปิด Antigravity CLI:
```bash
agy
```

แถบโควตาจะแสดงอยู่บรรทัดล่างสุดของ CLI ทันที

### คำสั่งควบคุม Statusline ภายใน CLI
- ปิดการแสดงผลแถบ: `/statusline off`
- เปิดการแสดงผลแถบ: `/statusline on`
