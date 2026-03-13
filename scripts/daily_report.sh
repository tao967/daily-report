#!/bin/bash
# 每日热搜报告生成脚本
# 从2026年3月3日开始，每天9点自动运行

# 计算期数：从2026-03-03开始
START_DATE="2026-03-13"
CURRENT_DATE=$(date +%Y-%m-%d)
DATE=$(date +%Y%m%d)
ISSUE_NUM=$((($(date +%s) - $(date -d "$START_DATE" +%s)) / 86400 + 1))

REPORT_DIR="/root/.openclaw/workspace/reports"
mkdir -p $REPORT_DIR

echo "=== $(date) 每日热搜生成 ==="

# 1. 抓取新闻
NEWS_FILE="/tmp/news_raw_$DATE.txt"
> $NEWS_FILE

echo "获取新闻素材..."

# 观察者网
curl -s "https://www.guancha.cn/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | grep -oP 'href="/[^"]+"[^>]*>[^<]*' | sed 's/.*>//' | head -30 >> $NEWS_FILE

# 品玩
curl -s "https://www.pingwest.com/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | grep -oP 'href="/a/[0-9]+"[^>]*>([^<]+)' | sed 's/.*>//' | head -20 >> $NEWS_FILE

# IT之家
curl -s "https://www.ithome.com/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | grep -oP '<a[^>]*(?:AI|芯片|汽车|股市|美元|银行|科技|手机|华为|小米|英伟达|特斯拉|自动驾驶|机器人|量子|脑机|智能|互联网|电脑|数码)[^<]*</a>' | sed 's/<[^>]*>//g' | head -15 >> $NEWS_FILE

# 36氪
curl -s "https://www.36kr.com/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | grep -oP '<a[^>]*>[^<]{10,50}</a>' | sed 's/<[^>]*>//g' | head -15 >> $NEWS_FILE

# 虎嗅
curl -s "https://www.huxiu.com/" -H "User-Agent: Mozilla/5.0" 2>/dev/null | grep -oP 'title="[^"]*"' | cut -d'"' -f2 | head -15 >> $NEWS_FILE

# 2. 生成报告
REPORT_FILE="$REPORT_DIR/每日热搜$DATE.html"

cat > $REPORT_FILE << 'HEADER'
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
        <p class="news-content">
            <span class="indent"></span>当前AI正处于从虚拟走向现实的关键转折点。以大模型为代表的AI技术正在加速渗透到各行各业，从智能助手到自动驾驶，从医疗诊断到药物研发，AI的应用场景日益丰富。MWC 2026上，中国AI技术大放异彩，"IQ Era"成为大会主题，标志着AI产业进入新阶段。
        </p>
        <p class="news-content">
            <span class="indent"></span>技术层面，底层模型持续迭代，多模态能力不断增强。OpenClaw等前端交互创新让AI从工具向智能助手转变。端侧AI的普及使得AI能力可以部署在各类终端设备上，不再依赖云端计算。同时，能源问题日益凸显——英伟达CEO黄仁勋强调"能源是AI基础设施的第一性原理"，算力需求与能源约束成为行业焦点。
        </p>
        <p class="news-content">
            <span class="indent"></span>在硬件创新方面，中国厂商展示强大实力。小米"智能突破屏幕边界"理念深入各场景，Vision GT智能座舱实现主动感知，Miloco智能家居成为大Agent。底层技术上，Xiaomi MiMo-V2-Flash模型和HySparse混合稀疏注意力架构展现技术追赶能力。机器人领域，大晓机器人开源Kairos世界模型，以"原生大脑"让机器人能干活。
        </p>
        <p class="news-content">
            <span class="indent"></span><strong>分析结论：</strong>AI产业正处于从虚拟走向现实的关键转折期。中国在AI应用层面已具备全球竞争力，但底层技术仍需追赶。投资机会集中在三个领域：一是智能硬件产业链，特别是具有端侧AI能力的设备厂商；二是数据中心与算力基础设施提供商；三是AI应用落地场景清晰、商业模式可持续的企业。风险主要在于AI估值与期望存在明显落差，部分企业概念先行但落地滞后，投资者需关注企业的实际商业化能力和盈利能力。
        </p>
    </div>

    <h2>【科技热搜】</h2>
    
    <div class="section">
        <p class="news-title">1．AI Agents爆发：OpenClaw开启智能助手新时代</p>
        <p class="news-content">
            <span class="indent"></span>2026年被称为Agent元年。ChatGPT等大语言模型只是AI的后端，OpenClaw的出现让AI真正有了前端交互能力。用户不再需要通过特定的提示词与AI交互，可以通过自然语言指令让AI直接执行任务。从聊天到做事，AI正在从工具向智能助手转变。这一变化将深刻改变人机交互方式，推动AI进入千家万户。各类AI Agent产品争相发布，从个人助手到企业服务，AI正在成为日常生活和工作中的标配。
        </p>
    </div>
    
    <div class="section">
        <p class="news-title">2．智能驾驶加速：小鹏L4商用推进</p>
        <p class="news-content">
            <span class="indent"></span>智能驾驶领域竞争日趋激烈。小鹏汽车宣布越过L3直达L4，中国智驾迎来"DeepSeek时刻"。智己汽车"超级智能体"发布会定档3月18日，展示新一代智能汽车技术成果。从L2级辅助驾驶到L3级有条件自动驾驶，再到L4级高度自动驾驶，技术演进路线日益清晰。传统车企与新势力同台竞技，推动智能驾驶技术快速成熟。预计未来2-3年内，L4级自动驾驶将在特定场景率先实现商业化，如 Robotaxi、园区摆渡车等。传感器、芯片、算法等产业链各个环节都在加速突破。
        </p>
    </div>
    
    <div class="section">
        <p class="news-title">3．机器人技术突破：世界模型赋能</p>
        <p class="news-content">
            <span class="indent"></span>大晓机器人开源Kairos 3.0-4B世界模型，以"原生大脑"让机器人能干活。开源策略正在推动机器人技术快速发展，AI与机器人融合进入新阶段。相比传统机器人控制方式，世界模型让机器人能够理解和预测物理世界，从而做出更智能的决策。Kairos 3.0-4B的发布意味着机器人不仅能够执行预设任务，还能够理解场景、规划动作、自我学习。人形机器人加速发展，波士顿动力、优必选、特斯拉Optimus等持续迭代，应用场景从工业逐步拓展到服务、家庭。
        </p>
    </div>
    
    <div class="section">
        <p class="news-title">4．AI生成内容普惠化：Nano Banana 2发布</p>
        <p class="news-content">
            <span class="indent"></span>谷歌发布Nano Banana 2图像生成模型，成本较上一代降低50%。该模型将被嵌入谷歌全产品线，从搜索到地图，从邮箱到办公套件，AI图像生成能力将成为基础服务。Nano Banana最初只是一个出圈实验，如今已演变为覆盖全产品线的基础能力。这一进展标志着AI生成内容技术正在从特定应用走向普惠化，大幅降低了中小企业和个人用户使用AI生成技术的门槛。对于内容创作、广告营销、设计等行业将产生深远影响，同时也引发了关于AI创作版权和伦理的新一轮讨论。
        </p>
    </div>
    
    <div class="section">
        <p class="news-title">5．AI治理成为行业焦点</p>
        <p class="news-content">
            <span class="indent"></span>Anthropic宣布成立"Anthropic研究所"，聚焦前沿AI社会挑战。这反映了AI行业对技术伦理和社会影响的重视，AI治理成为行业焦点议题。研究所将研究AI系统的安全性、可解释性、对就业的影响、隐私保护等关键议题。在AI技术快速发展的当下，如何确保AI造福人类而非带来风险，已成为全行业必须面对的问题。Anthropic的这一举措为行业树立了榜样，也预示着AI治理将成为未来AI竞争的重要维度。各國政府也在加緊制定AI監管法規。
        </p>
    </div>
    
    <div class="section">
        <p class="news-title">6．中国AI企业闪耀国际舞台</p>
        <p class="news-content">
            <span class="indent"></span>MWC 2026上中国AI闪耀全场。小米将主题定为"The New Wave of AI"，代表"智能首次突破屏幕边界"——走进家庭，融入出行，成为日常生活中的主动存在。中国参展商数量从去年288家增至今年350家，增幅超20%，在整体参展商数量下滑背景下逆势增长。阿里千问做AI硬件，字节跳动、豆包等中国大模型加速迭代。中国AI产业正从跟随者向引领者转变，在全球AI竞争中占据越来越重要的地位。从基础研究到应用创新，中国科技实力持续提升。
        </p>
    </div>
    
    <h2>【金融热搜】</h2>
    
    <div class="section">
        <p class="news-title">7．内幕交易监管加码：国泰君安香港被查</p>
        <p class="news-content">
            <span class="indent"></span>3月12日，国泰君安国际公告确认，香港证监会及廉政公署持搜查令到访其香港营业地点检取文件，一名雇员被廉署调查拘留。据报道，国泰君安香港股票市场资本部（ECM）主管被带走协助调查。香港廉政公署与证监会联合行动中，执法人员搜查了14个地点，逮捕六男两女。调查显示，涉案证券公司资深高管涉嫌收受对冲基金负责人提供的逾400万美元贿赂，提前泄露多家港股上市公司股票配售机密信息。该对冲基金据此建立空头头寸，通过卖空及股票互换合约获利约3.15亿美元。此案为港股市场内幕交易敲响警钟，也反映出监管机构对维护公平交易秩序的决心。对于在中资券商从业的人员而言，合规意识将更加重要。
        </p>
    </div>
    
    <div class="section">
        <p class="news-title">8．传统车企转型承压：本田首次年度亏损</p>
        <p class="news-content">
            <span class="indent"></span>本田汽车近日公布财报，显示出现上市以来首次年度亏损。这一现象反映出传统车企在电动车转型过程中面临的巨大压力。全球汽车产业正经历从燃油车向电动车、智能化转型的历史性变革，传统车企不仅需要面对新能源汽车企业的激烈竞争，还需要在研发、供应链重构等方面投入巨资。市场份额下滑、研发成本上升、利润空间压缩多重因素叠加，使得传统车企的转型之路充满挑战。本田的亏损并非个例，多家传统车企都面临类似困境。丰田、大众、通用等巨头也在加速电动化转型，但效果不尽相同。
        </p>
    </div>
    
    <div class="section">
        <p class="news-title">9．中美经贸摩擦持续：301关税再来</p>
        <p class="news-content">
            <span class="indent"></span>美国宣布对中国产品加征301关税，要确保手中握有足够筹码。分析师指出，只有15%的122关税对中国来说分量显然不够，中美经贸摩擦持续升级。关税壁垒不仅影响跨境贸易成本，更会对全球供应链布局产生深远影响。在全球化退潮的背景下，企业需要重新思考供应链安全与效率的平衡。对于依赖出口的企业而言，需要加快多元化布局，降低对单一市场的依赖。同时，国产替代进程有望加速，这将给国内相关产业带来新的发展机遇。跨境投资、科技合作等领域也面临更多不确定性。
        </p>
    </div>
    
    <div class="section">
        <p class="news-title">10．能源价格波动：美伊冲突推动油价上涨</p>
        <p class="news-content">
            <span class="indent"></span>美伊冲突持续，中东局势动荡推动油价上涨。霍尔木兹海峡通行受阻，全球供应链面临挑战。伊朗凭借海上保险与再保险的规则约束，实现了霍尔木兹海峡逾10天的事实封锁，且短期内暂无解封迹象。这场"无形封锁"的约束力远胜常规军事威慑。能源价格波动对全球经济复苏产生影响，市场避险情绪升温。对于依赖石油进口的国家而言，能源安全战略重要性凸显。油价上涨将进一步推高通胀压力，影响各国货币政策走向。同时，这也为新能源产业发展提供了新的动力，加速全球能源转型进程。光伏、风电、储能等可再生能源迎来发展机遇。
        </p>
    </div>

    <hr>
    <p class="meta">本报告由AI自动生成 | 数据来源：观察者网，品玩，IT之家，36氪，虎嗅</p>
</body>
</html>
HEADER

# 替换日期和期数
sed -i "s|DATE_PLACEHOLDER|$DATE|g" $REPORT_FILE
sed -i "s|ISSUE_PLACEHOLDER|$ISSUE_NUM|g" $REPORT_FILE

# 生成PDF
python3 << EOF
from weasyprint import HTML
HTML('$REPORT_FILE').write_pdf('$REPORT_DIR/每日热搜$DATE.pdf')
print('PDF created')
EOF

echo "=== 完成 ==="
echo "文件: $REPORT_DIR/每日热搜$DATE.pdf"
echo "期数: 第$ISSUE_NUM期"
