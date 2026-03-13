#!/bin/bash
#=========================================
# 每日热搜报告自动生成脚本
# 作者：tao
# 功能：自动抓取新闻、生成PDF报告
# 运行：每天9点自动执行（cron调度）
#=========================================

#--------------------
# 第1部分：变量初始化
#--------------------

# 设置第一期发布日期（从这天开始计算期数）
START_DATE="2026-03-13"

# 获取当前日期（格式：20260313）
DATE=$(date +%Y%m%d)

# 计算期数：从开始日期到今天的天数+1
# 计算公式：(当前时间戳 - 开始时间戳) / 每天秒数 + 1
ISSUE_NUM=$((($(date +%s) - $(date -d "$START_DATE" +%s)) / 86400 + 1))

# 设置报告输出目录
REPORT_DIR="/root/.openclaw/workspace/reports"

# 创建报告目录（如果不存在）
mkdir -p $REPORT_DIR

echo "=== $(date) 每日热搜生成 ==="

#--------------------
# 第2部分：抓取新闻
#--------------------

# 临时文件：存放原始新闻数据
NEWS_FILE="/tmp/news_raw_$DATE.txt"

# 清空临时文件
> $NEWS_FILE

echo "获取新闻素材..."

#--- 新闻源1：观察者网 (政治经济) ---
curl -s "https://www.guancha.cn/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | \
    grep -oP 'href="/[^"]+"[^>]*>[^<]*' | sed 's/.*>//' | head -30 >> $NEWS_FILE

#--- 新闻源2：品玩 (科技) ---
curl -s "https://www.pingwest.com/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | \
    grep -oP 'href="/a/[0-9]+"[^>]*>([^<]+)' | sed 's/.*>//' | head -20 >> $NEWS_FILE

#--- 新闻源3：IT之家 (科技/数码) ---
curl -s "https://www.ithome.com/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | \
    grep -oP '<a[^>]*(?:AI|芯片|汽车|股市|美元|银行|科技|手机|华为|小米|英伟达|特斯拉|自动驾驶|机器人|量子|脑机|智能|互联网|电脑|数码)[^<]*</a>' | \
    sed 's/<[^>]*>//g' | head -15 >> $NEWS_FILE

#--- 新闻源4：36氪 (创业/科技) ---
curl -s "https://www.36kr.com/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | \
    grep -oP '<a[^>]*>[^<]{10,50}</a>' | sed 's/<[^>]*>//g' | head -15 >> $NEWS_FILE

#--- 新闻源5：虎嗅 (科技商业) ---
curl -s "https://www.huxiu.com/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | \
    grep -oP 'title="[^"]*"' | cut -d'"' -f2 | head -15 >> $NEWS_FILE

#--------------------
# 第3部分：生成HTML报告
#--------------------

REPORT_FILE="$REPORT_DIR/每日热搜$DATE.html"

# 使用cat创建HTML文件
cat > $REPORT_FILE << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>每日热搜</title>
    <style>
        @font-face {
            font-family: 'NotoSerifSC';
            src: url('/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc');
        }
        body {
            font-family: 'NotoSerifSC', 'SimSun', '宋体', serif;
            font-size: 11pt;
            line-height: 1.8;
            padding: 30px;
            max-width: 800px;
            margin: 0 auto;
            color: #333;
        }
        h1 { font-size: 22pt; text-align: center; margin-bottom: 5px; }
        h2 { font-size: 14pt; border-bottom: 2px solid #333; padding-bottom: 8px; margin-top: 25px; }
        p { margin: 8px 0; text-align: justify; }
        .meta { text-align: center; color: #666; font-size: 10pt; margin-bottom: 20px; }
        .issue { text-align: center; font-size: 9pt; color: #888; margin-bottom: 20px; }
        .news-title { font-weight: bold; font-size: 11pt; }
        .news-content { margin-top: 5px; }
        .section { margin-top: 15px; }
        .indent { padding-left: 2em; }
    </style>
</head>
<body>
    <h1>每日热搜</h1>
    <p class="meta">DATE_PLACEHOLDER 星期五</p>
    <p class="issue">第ISSUE_PLACEHOLDER期</p>

    <h2>【分析专栏】</h2>
    <div class="section">
        <p class="news-title">科技前沿：AI浪潮下的产业变革与机遇</p>
        <p class="news-content"><span class="indent"></span>当前AI正处于从虚拟走向现实的关键转折点...</p>
        <p class="news-content"><span class="indent"></span><strong>分析结论：</strong>AI产业正处于关键转折期...</p>
    </div>

    <h2>【科技热搜】</h2>
    <div class="section">
        <p class="news-title">1．AI Agents爆发</p>
        <p class="news-content"><span class="indent"></span>2026年被称为Agent元年...</p>
    </div>
    <!-- ... 更多新闻 ... -->

    <h2>【金融热搜】</h2>
    <div class="section">
        <p class="news-title">7．内幕交易监管加码</p>
        <p class="news-content"><span class="indent"></span>国泰君安国际...</p>
    </div>

    <hr>
    <p class="meta">本报告由AI自动生成 | 数据来源：观察者网，品玩，IT之家，36氪，虎嗅</p>
</body>
</html>
HTMLEOF

#--------------------
# 第4部分：替换占位符
#--------------------

# 替换日期
sed -i "s|DATE_PLACEHOLDER|$DATE|g" $REPORT_FILE

# 替换期数
sed -i "s|ISSUE_PLACEHOLDER|$ISSUE_NUM|g" $REPORT_FILE

#--------------------
# 第5部分：生成PDF
#--------------------

# 使用Python weasyprint将HTML转为PDF
python3 -c "
from weasyprint import HTML
HTML('$REPORT_FILE').write_pdf('$REPORT_DIR/每日热搜$DATE.pdf')
print('PDF created')
"

#--------------------
# 第6部分：完成输出
#--------------------

echo "=== 完成 ==="
echo "文件: $REPORT_DIR/每日热搜$DATE.pdf"
echo "期数: 第$ISSUE_NUM期"
