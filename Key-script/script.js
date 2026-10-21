// ================================================================= //
// 🔑 RYGDEEEEEE VIP HUB - KEY SYSTEM SCRIPT (SCRIPT.JS)
// ================================================================= //

let completedSteps = 0;
const KEY_EXPIRY_HOURS = 24; // กำหนดเวลาหมดอายุคีย์ 24 ชั่วโมง

// 1. ทำงานทันทีเมื่อเปิดหน้าเว็บ
document.addEventListener("DOMContentLoaded", function () {
    checkKeyExpiration();
});

// 2. อัปเดตหลอดความคืบหน้า (Progress Bar)
function updateProgress() {
    let percent = (completedSteps / 2) * 100;
    let progressBar = document.getElementById('progressBar');
    let progressText = document.getElementById('progressText');

    if (progressBar) progressBar.style.width = percent + '%';
    if (progressText) progressText.innerText = percent + '% เสร็จสิ้น';

    if (completedSteps === 2) {
        unlockKeySystem();
    }
}

// 3. ฟังก์ชันปลดล็อกหน้าคีย์
function unlockKeySystem() {
    let keyOverlay = document.getElementById('keyOverlay');
    let keyDisplay = document.getElementById('keyDisplay');
    let btnUnlock = document.getElementById('btnUnlock');

    if (keyOverlay) keyOverlay.style.display = 'none';
    if (keyDisplay) keyDisplay.classList.remove('key-blur');
    if (btnUnlock) btnUnlock.disabled = false;
}

// 4. ฟังก์ชันล็อกหน้าคีย์ (เมื่อเปิดใหม่หรือหมดเวลา)
function lockKeySystem() {
    let keyOverlay = document.getElementById('keyOverlay');
    let keyDisplay = document.getElementById('keyDisplay');
    let btnUnlock = document.getElementById('btnUnlock');
    let timerDisplay = document.getElementById('timerDisplay');

    if (keyOverlay) keyOverlay.style.display = 'flex';
    if (keyDisplay) keyDisplay.classList.add('key-blur');
    if (btnUnlock) btnUnlock.disabled = true;
    if (timerDisplay) timerDisplay.style.display = 'none';

    // รีเซ็ตปุ่มขั้นตอน
    completedSteps = 0;
    updateProgress();

    let btn1 = document.getElementById('btnStep1');
    let btn2 = document.getElementById('btnStep2');
    let stepCard1 = document.getElementById('stepCard1');
    let stepCard2 = document.getElementById('stepCard2');
    let stepNum1 = document.getElementById('stepNum1');
    let stepNum2 = document.getElementById('stepNum2');

    if (btn1) {
        btn1.disabled = false;
        btn1.innerText = 'เริ่มขั้นตอน';
    }
    if (stepCard1) stepCard1.classList.remove('completed');
    if (stepNum1) stepNum1.innerText = '1';

    if (btn2) {
        btn2.disabled = true;
        btn2.innerText = 'เริ่มขั้นตอน';
    }
    if (stepCard2) stepCard2.classList.remove('completed');
    if (stepNum2) stepNum2.innerText = '2';
}

// 5. ระบบทำขั้นตอนนับถอยหลัง 10 วินาที (Step 1 & Step 2)
function startStep(step) {
    if (step === 1) {
        let btn1 = document.getElementById('btnStep1');
        if (!btn1) return;

        btn1.disabled = true;
        btn1.innerText = 'กำลังรอ 10s...';

        // เปิดลิงก์สปอนเซอร์/โฆษณา
        window.open('https://google.com', '_blank');

        let countdown = 10;
        let timer = setInterval(() => {
            countdown--;
            btn1.innerText = `รอ ${countdown}s...`;
            if (countdown <= 0) {
                clearInterval(timer);
                btn1.innerText = '✅ สำเร็จ';
                document.getElementById('stepCard1').classList.add('completed');
                document.getElementById('stepNum1').innerText = '✓';

                let btn2 = document.getElementById('btnStep2');
                if (btn2) btn2.disabled = false;

                completedSteps = 1;
                updateProgress();
            }
        }, 1000);
    } else if (step === 2) {
        let btn2 = document.getElementById('btnStep2');
        if (!btn2) return;

        btn2.disabled = true;
        btn2.innerText = 'กำลังรอ 10s...';

        // เปิดลิงก์สปอนเซอร์/โฆษณา
        window.open('https://youtube.com', '_blank');

        let countdown = 10;
        let timer = setInterval(() => {
            countdown--;
            btn2.innerText = `รอ ${countdown}s...`;
            if (countdown <= 0) {
                clearInterval(timer);
                btn2.innerText = '✅ สำเร็จ';
                document.getElementById('stepCard2').classList.add('completed');
                document.getElementById('stepNum2').innerText = '✓';

                completedSteps = 2;
                updateProgress();
            }
        }, 1000);
    }
}

// 6. ฟังก์ชันกดคัดลอกคีย์ และบันทึกเวลานับถอยหลัง 24 ชม.
function copyKey() {
    let keyElement = document.getElementById('keyDisplay');
    if (!keyElement) return;

    let key = keyElement.innerText;

    // ตั้งเวลาหมดอายุล่วงหน้า 24 ชั่วโมง
    let now = new Date().getTime();
    let expiryTime = now + (KEY_EXPIRY_HOURS * 60 * 60 * 1000);
    localStorage.setItem("key_expiry_time", expiryTime);

    navigator.clipboard.writeText(key).then(() => {
        alert('🎉 คัดลอก Key สำเร็จ!\nKey: ' + key + '\n\n⏳ อายุการใช้งาน: 24 ชั่วโมง (เมื่อหมดเวลาต้องมาทำขั้นตอนใหม่)');
        checkKeyExpiration();
    }).catch(err => {
        alert('คัดลอกสำเร็จ: ' + key);
        checkKeyExpiration();
    });
}

// 7. ระบบนับถอยหลัง Real-time 24 ชั่วโมง
function checkKeyExpiration() {
    let savedExpiry = localStorage.getItem("key_expiry_time");
    if (!savedExpiry) return;

    let timerInterval = setInterval(() => {
        let now = new Date().getTime();
        let distance = savedExpiry - now;

        if (distance <= 0) {
            // หมดเวลา 24 ชั่วโมง ล็อกหน้าคีย์ทันที
            clearInterval(timerInterval);
            localStorage.removeItem("key_expiry_time");
            alert("⏰ คีย์ของคุณหมดอายุแล้ว (ครบ 24 ชม.) กรุณายืนยันตัวตนเพื่อรับคีย์ใหม่อีกครั้ง!");
            lockKeySystem();
        } else {
            // คำนวณ ชั่วโมง, นาที, วินาที
            let hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            let minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            let seconds = Math.floor((distance % (1000 * 60)) / 1000);

            unlockKeySystem();
            let timerLabel = document.getElementById('timerDisplay');
            if (timerLabel) {
                timerLabel.style.display = 'block';
                timerLabel.innerText = `⏳ คีย์หมดอายุในอีก: ${hours} ชม. ${minutes} นาที ${seconds} วินาที`;
            }
        }
    }, 1000);
}
