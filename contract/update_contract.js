const fs = require('fs');
let content = fs.readFileSync('عقد_احترافي_مصطفى_حسين.html', 'utf8');

// Header changes
content = content.replace(/تاريخ العقد: 29 مارس 2026/, 'تاريخ العقد: 4 يونيو 2026');
content = content.replace(/رقم المرجع: MH-ERP-01\/26/, 'رقم المرجع: MH-ERP-02/26');
content = content.replace(/عقـــد تنفيـــذ نظام إدارة المبيعات والمخازن/, 'عقـــد تنفيـــذ تطبيق إدارة الورشة (الباقة الاحترافية)');

// Parties
content = content.replace(/الأستاذ \/ أحمد عاشور/g, 'الأستاذ / يحيى');
content = content.replace(/صاحب أنشطة تجارية \(مخزن الحدايد والأخشاب\)/g, 'صاحب مصنع النجارة والأثاث');

// Article 1
content = content.replace(/لمخزن الطرف الثاني، يشمل إدارة المخزون، المبيعات بحساباتها، المشتريات، والجرد الآلي/g, 'لمصنع وورشة الطرف الثاني، يشمل إدارة الشغلانات وحساب التكاليف والمصنعيات، بالإضافة إلى الخزنة والتقارير المالية');

// Article 2
const newScope = `
            <div class="detailed-scope">
                <div class="scope-card">
                    <h6>💰 الخزنة والماليات</h6>
                    <ul>
                        <li>تسجيل كافة الواردات والمصروفات وتصنيفها.</li>
                        <li>معرفة رصيد الخزنة اللحظي بدقة.</li>
                    </ul>
                </div>
                <div class="scope-card">
                    <h6>📈 لوحة التحكم (داشبورد)</h6>
                    <ul>
                        <li>شاشة مبسطة توضح الموقف المالي للورشة.</li>
                        <li>إحصائيات الإيرادات والمصروفات.</li>
                    </ul>
                </div>
                <div class="scope-card">
                    <h6>🏢 إدارة تعدد الورش</h6>
                    <ul>
                        <li>دعم إدارة ورشتين (أو فرعين) في نفس النظام.</li>
                        <li>فصل حسابات وتقارير كل ورشة على حدة.</li>
                    </ul>
                </div>
                <div class="scope-card">
                    <h6>📋 إدارة الشغلانات</h6>
                    <ul>
                        <li>تسجيل ومتابعة الشغلانات من البداية للنهاية.</li>
                        <li>حفظ بيانات كل شغلانة والعميل المرتبط بها.</li>
                    </ul>
                </div>
                <div class="scope-card">
                    <h6>📊 حساب التكاليف والمصنعيات</h6>
                    <ul>
                        <li>حساب دقيق لتكلفة المواد الخام والمصنعيات لكل شغلانة.</li>
                        <li>تحديد صافي الربح الفعلي لكل شغلانة.</li>
                    </ul>
                </div>
                <div class="scope-card">
                    <h6>📱 التقارير والتواصل</h6>
                    <ul>
                        <li>إمكانية إرسال تقرير فوري للعميل عبر واتساب.</li>
                        <li>تقارير أرباح وخسائر دقيقة وشاملة.</li>
                    </ul>
                </div>
                <div class="scope-card">
                    <h6>🔒 الحفظ والأمان</h6>
                    <ul>
                        <li>تطبيق موبايل سريع وموثوق.</li>
                        <li>نسخ احتياطي للبيانات على Google Drive.</li>
                    </ul>
                </div>
            </div>`;
content = content.replace(/<div class="detailed-scope">[\s\S]*?<\/div>\s*<\/div>\s*<!-- Article 3/m, newScope + '\n        </div>\n\n        <!-- Article 3');

// Article 3: Financials
const financials = `
        <!-- Article 3: Financials -->
        <div class="article avoid-break">
            <div class="article-title">
                <span>المادة الثالثة: القيمة المالية وجدولة الدفع</span>
            </div>
            <div class="financial-summary">
                <div class="fin-row total">
                    <span>قيمة العقد الإجمالية (الباقة الاحترافية):</span>
                    <span>7,500 ج.م</span>
                </div>
            </div>
            
            <table class="financial-table">
                <thead>
                    <tr>
                        <th>الدفعة المالية</th>
                        <th>القيمة (ج.م)</th>
                        <th>موعد الاستحقاق</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>مقدم التعاقد</td>
                        <td>4,000 ج.م</td>
                        <td>عند التوقيع (بدء العمل)</td>
                    </tr>
                    <tr>
                        <td>الدفعة النهائية</td>
                        <td>3,500 ج.م</td>
                        <td>عند التسليم النهائي والتدريب</td>
                    </tr>
                </tbody>
            </table>
        </div>
`;
content = content.replace(/<!-- <div class="article avoid-break">\s*<div class="article-title">\s*<span>المادة الثالثة: القيمة المالية وجدولة الدفع<\/span>[\s\S]*?<\/div> -->/, financials);


fs.writeFileSync('عقد_احترافي_استاذ_يحيى_04_06_2026.html', content);
console.log('Contract updated and created successfully.');
