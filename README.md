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
- **Non-Destructive**: ทำงานควบคู่กับแถบสถานะเริ่มต้นของ CLI (`stack_with_default: true`)

---

## 📁 โครงสร้างโปรเจ็ค

```text
cli_quota_usage/
├── statusline.ps1          # สคริปต์หลักสำหรับประมวลผล JSON และเรนเดอร์ Statusline
├── install.ps1             # สคริปต์ติดตั้งอัตโนมัติ (คัดลอกไฟล์และอัปเดต settings.json)
├── settings.example.json   # ตัวอย่างคอนฟิก settings.json
├── statusline_setup_guide.txt # เอกสารคู่มืออ้างอิงเดิม
├── LICENSE                 # MIT License
└── README.md               # เอกสารแนะนำการใช้งาน
```

---

## 🚀 การติดตั้ง (Installation)

### วิธีที่ 1: ติดตั้งอัตโนมัติด้วยสคริปต์ (แนะนำ)

เปิด PowerShell ในโฟลเดอร์โปรเจ็คแล้วรันคำสั่ง:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

สคริปต์จะทำการ:
1. สร้างโฟลเดอร์ `$HOME\.gemini\antigravity-cli\` ให้โดยอัตโนมัติ
2. คัดลอก `statusline.ps1` ไปยังโฟลเดอร์เป้าหมาย
3. อัปเดตการตั้งค่า `statusLine` ใน `settings.json` โดยไม่กระทบคอนฟิกอื่น

---

### วิธีที่ 2: ติดตั้งด้วยตนเอง (Manual Installation)

#### 1. คัดลอกสคริปต์ไปยังโฟลเดอร์ Antigravity CLI
เปิด PowerShell แล้วรัน:
```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.gemini\antigravity-cli"
Copy-Item -Path ".\statusline.ps1" -Destination "$HOME\.gemini\antigravity-cli\statusline.ps1"
```

#### 2. แก้ไขไฟล์ `settings.json`
เปิดไฟล์:
```powershell
notepad "$HOME\.gemini\antigravity-cli\settings.json"
```

เพิ่มบล็อก `"statusLine"` เข้าไปดังนี้ (แทนที่ `<USERNAME>` ด้วยชื่อ User Windows ของคุณ):

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

> **ข้อควรระวัง:** ใน JSON ให้ใช้เครื่องหมาย Slash (`/`) เสมอสำหรับพาธไฟล์

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

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
