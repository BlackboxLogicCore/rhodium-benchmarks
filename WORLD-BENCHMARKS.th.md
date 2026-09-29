# Rhodium Germany — ชุดทดสอบ Benchmark สาธารณะระดับโลก

**สถานะ: กำลังทดสอบแบบสาธารณะ**  
เว็บไซต์: https://rhodium-germany.de  
หลักฐานสาธารณะ: https://github.com/BlackboxLogicCore/rhodium-benchmarks  
กำหนดรอบแรกสำหรับพันธมิตร/ไลเซนส์: **30 กันยายน 2026 เวลา 05:00 CEST**

Rhodium Germany ทำการทดสอบแบบสาธารณะโดยใช้ GitHub repository และขั้นตอนทดสอบอย่างเป็นทางการที่บริษัทเทคโนโลยีเผยแพร่เอง โดยบันทึก upstream commit ที่ใช้จริงและเก็บหลักฐานการรันไว้แบบสาธารณะ

กติกา:
- ไม่เปิดเผย protected core, private key หรือ logic วิจัยภายในของ Rhodium
- ไม่แทนที่การทดสอบอย่างเป็นทางการของผู้ผลิตด้วยการทดสอบที่สร้างขึ้นเอง
- จะเผยแพร่ผลเปรียบเทียบโดยตรงเฉพาะเมื่อ input, environment, task และ metric เปรียบเทียบกันได้จริง
- หากเงื่อนไขไม่เพียงพอ จะระบุ NOT_COMPARABLE, INFRASTRUCTURE_REQUIRED หรือ HARDWARE_REQUIRED
- PASS ใช้ได้เฉพาะกับขอบเขตการทดสอบที่ระบุไว้ ไม่ใช่คำกล่าวว่าเหนือกว่าทุกผลิตภัณฑ์หรือทุกกรณี

ชุดปัจจุบันครอบคลุมเส้นทางทดสอบโอเพนซอร์สอย่างเป็นทางการจาก Cloudflare, Meta, Google, AWS, Microsoft และรายอื่น

พันธมิตรและไลเซนส์: info@rhodium-germany.tech  
Rhodium Germany ยังคงถือ protected core, ระบบวิจัย, signing authority และการควบคุม release.