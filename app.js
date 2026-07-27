/**
 * 国内城市匹配测试（开放直链，无需口令）
 */

const DIMENSIONS = [
  "pace",
  "ambition",
  "climate",
  "social",
  "cost",
  "nature",
  "culture",
  "spice",
];

/** @type {Record<string, {name:string, tag:string, quote:string, body:string, scores:Record<string,number>}>} */
const CITIES = {
  chengdu: {
    name: "成都",
    tag: "松弛感天花板",
    quote: "你要的不是更快，是被好好对待的日常。",
    body:
      "你的身体会在太卷的地方发紧，也会在太空的地方无聊。成都刚好卡在中间：有烟火，有朋友局，也允许你什么都不干。\n\n你适合被火锅、茶馆和慢吞吞的下午养着。效率可以有，但不该成为唯一信仰。当你开始想「过得舒坦一点」时，这座城往往最先回应你。",
    scores: { pace: 2, ambition: 3, climate: 4, social: 6, cost: 4, nature: 5, culture: 4, spice: 4 },
  },
  hangzhou: {
    name: "杭州",
    tag: "精致生活派",
    quote: "你想要体面，也想要一点山水。",
    body:
      "你不是拒绝奋斗的人，但你受不了粗糙的生活。杭州给你一种「努力也可以很干净」的感觉：湖、绿道、咖啡、数字行业的节奏，都刚好。\n\n你适合有秩序、有审美、又不太喧嚣的城市。若你渴望事业与生活同时在线，杭州会让你觉得：自己被认真对待了。",
    scores: { pace: 6, ambition: 7, climate: 5, social: 5, cost: 7, nature: 7, culture: 5, spice: 3 },
  },
  chongqing: {
    name: "重庆",
    tag: "反差感暴击",
    quote: "你需要一座城，把沉睡的那部分叫醒。",
    body:
      "平淡会消耗你。你需要立体的街景、陡峭的情绪、突然出现的江风和夜景。重庆不温柔，但很真实——它逼你往上走，也给你痛快的释放。\n\n如果你骨子里有一点野、一点热、一点「别太规规矩矩」，重庆会让你重新觉得自己还活着。",
    scores: { pace: 7, ambition: 6, climate: 6, social: 8, cost: 4, nature: 6, culture: 5, spice: 9 },
  },
  shanghai: {
    name: "上海",
    tag: "机会密度之王",
    quote: "你愿意为更大的舞台付一点代价。",
    body:
      "你对平庸过敏。你要资源、效率、国际化的空气，也接受更高的房租和更快的心跳。上海会很累，但很少无聊。\n\n适合已经想清楚「我要往上走」的你。若你需要被城市推着走，而不是被温柔哄着躺，上海就是那台发动机。",
    scores: { pace: 9, ambition: 9, climate: 5, social: 7, cost: 9, nature: 3, culture: 6, spice: 6 },
  },
  shenzhen: {
    name: "深圳",
    tag: "年轻奋斗城",
    quote: "你还想再拼一次，而且现在就要结果。",
    body:
      "你讨厌论资排辈，喜欢清晰规则和快速反馈。深圳年轻、直接、少历史包袱——很适合想换赛道、想证明自己的人。\n\n这里不负责浪漫叙事，但负责给你机会。若你正处于「我想冲一把」的阶段，深圳会站在你这边。",
    scores: { pace: 9, ambition: 9, climate: 7, social: 6, cost: 8, nature: 4, culture: 3, spice: 5 },
  },
  beijing: {
    name: "北京",
    tag: "格局与资源",
    quote: "你要的不只是生活，还有更大的坐标系。",
    body:
      "你在意信息密度、文化厚度和「能碰到什么人」。北京冷、大、贵，但给得也多。它适合有野心、也扛得住风的人。\n\n如果你觉得小城会限制想象力，北京会把天花板往上抬一截。记得：留下的不是忍耐，而是你真正想要的舞台。",
    scores: { pace: 8, ambition: 9, climate: 3, social: 6, cost: 8, nature: 4, culture: 9, spice: 5 },
  },
  xian: {
    name: "西安",
    tag: "厚重且踏实",
    quote: "你想要根，也想要烟火气。",
    body:
      "你不喜欢漂着的感觉。西安给你历史的重量，也给你面食和城墙根下的人间味。生活成本更友好，情绪更稳。\n\n适合想扎根、想把日子过实的你。若你厌倦了悬浮的焦虑，西安会告诉你：慢一点，也可以很有底气。",
    scores: { pace: 4, ambition: 5, climate: 4, social: 6, cost: 3, nature: 4, culture: 9, spice: 4 },
  },
  xiamen: {
    name: "厦门",
    tag: "海风治愈系",
    quote: "你需要被风和海轻轻托住。",
    body:
      "你的身体在高压里会罢工。厦门不大，却刚好：海、岛、慢节奏、可以散步的傍晚。它适合修复，也适合重新开始。\n\n如果你最近总想逃，却不是想躺平到消失，厦门是「温柔撤退」的最优解。",
    scores: { pace: 2, ambition: 3, climate: 8, social: 4, cost: 5, nature: 8, culture: 4, spice: 2 },
  },
  kunming: {
    name: "昆明",
    tag: "气候与松弛",
    quote: "你最需要的，其实是一年四季都被善待。",
    body:
      "很多城市消耗天气，昆明返还天气。四季如春对你不是广告词，是身体需求。这里适合怕极端气候、想把日子过轻一点的人。\n\n若你追求稳定情绪与自然亲近感，昆明会让你少很多无谓消耗。",
    scores: { pace: 2, ambition: 3, climate: 9, social: 4, cost: 3, nature: 8, culture: 4, spice: 2 },
  },
  changsha: {
    name: "长沙",
    tag: "热闹烟火气",
    quote: "你需要快乐来得直接一点。",
    body:
      "你讨厌沉闷。长沙有夜市、综艺感、年轻人和不怕吵的活力。它不一定最精致，但一定很有人味。\n\n适合社交电量高、想被城市情绪带着走的你。想开心的时候，长沙很少让你空手而归。",
    scores: { pace: 6, ambition: 5, climate: 6, social: 9, cost: 4, nature: 4, culture: 4, spice: 7 },
  },
  nanjing: {
    name: "南京",
    tag: "书卷与分寸",
    quote: "你要热闹，也要留一点安静给自己。",
    body:
      "你既不爱过度表演，也不想完全隐居。南京有历史，有大学城气质，也有恰好的城市配套。它像一个会留白的朋友。\n\n适合追求平衡感的你：能发展，也能阅读；能出门，也能回家。",
    scores: { pace: 5, ambition: 6, climate: 4, social: 5, cost: 5, nature: 5, culture: 8, spice: 3 },
  },
  qingdao: {
    name: "青岛",
    tag: "海风与边界感",
    quote: "你想靠近海，但不想被旅游人潮吞掉。",
    body:
      "青岛给你海的开阔，也保留北方城市的利落。啤酒、老建筑、沿海的风，都让人容易呼吸。它比一线松，比小城完整。\n\n适合想要生活质量、又不想卷进超一线旋涡的你。",
    scores: { pace: 4, ambition: 5, climate: 5, social: 5, cost: 4, nature: 8, culture: 5, spice: 3 },
  },
  suzhou: {
    name: "苏州",
    tag: "园林式体面",
    quote: "你要精致，但不必活成表演。",
    body:
      "苏州把秩序和柔软放在一起：园林、江南、产业园区与恰到好处的生活半径。它适合既在意审美，又不愿被超一线彻底榨干的人。\n\n如果你想要「有质量的安稳」，苏州常常比口号更兑现。",
    scores: { pace: 4, ambition: 6, climate: 5, social: 4, cost: 6, nature: 6, culture: 8, spice: 2 },
  },
  wuhan: {
    name: "武汉",
    tag: "江湖气与韧性",
    quote: "你需要一座城，既热烈又扛得住事。",
    body:
      "武汉有热干面的痛快，也有大江大湖的开阔。生活成本相对友好，年轻人密度高，容错率不低。它适合想拼、也想吃得痛快的人。\n\n若你厌烦精致到发假的城市感，武汉的真实会让你踏实。",
    scores: { pace: 6, ambition: 6, climate: 5, social: 8, cost: 3, nature: 5, culture: 5, spice: 7 },
  },
  guangzhou: {
    name: "广州",
    tag: "烟火与实在",
    quote: "你要的繁荣，最好带着一口热汤。",
    body:
      "广州把商业和生活煮在一锅：早茶、夜市、务实、包容。气候偏暖，机会不少，却比一些一线更有人间味。\n\n适合重视吃喝社交、也想把日子过实的你。广州很少逼你表演成功，但会给你持续往前走的空间。",
    scores: { pace: 6, ambition: 7, climate: 8, social: 8, cost: 6, nature: 4, culture: 5, spice: 5 },
  },
  zhuhai: {
    name: "珠海",
    tag: "湾区松弛感",
    quote: "你想靠近机会，却不想被卷进中心漩涡。",
    body:
      "珠海海风明显，节奏比广深慢一拍，却仍连着大湾区的可能性。它适合想要海边生活、又不完全离开发展圈的人。\n\n如果你既怕落后，又怕燃尽，珠海是一个温和折中。",
    scores: { pace: 3, ambition: 5, climate: 8, social: 4, cost: 5, nature: 8, culture: 3, spice: 2 },
  },
  dalian: {
    name: "大连",
    tag: "海风北方感",
    quote: "你想要海，也想要一点利落的城市骨架。",
    body:
      "大连清爽、有海、有广场和步行的欲望。它没有超一线那么压迫，却足够完整。适合喜欢干净城市界面、又能接受北方季节的人。\n\n若你要的是呼吸感而不是表演场，大连值得认真考虑。",
    scores: { pace: 4, ambition: 5, climate: 3, social: 5, cost: 4, nature: 8, culture: 4, spice: 3 },
  },
  guilin: {
    name: "桂林",
    tag: "山水慢生活",
    quote: "你的眼睛比日程更需要被喂饱。",
    body:
      "桂林用山水把人劝慢。适合创作、修复、重新安排人生节奏的阶段。机会密度不如一线，但风景和松弛是硬补偿。\n\n如果你已经听够了效率叙事，桂林会提醒你：活着也可以很好看。",
    scores: { pace: 1, ambition: 2, climate: 6, social: 3, cost: 2, nature: 9, culture: 5, spice: 2 },
  },
  sanya: {
    name: "三亚",
    tag: "热带回血地",
    quote: "你暂时不需要更多证明，只需要被阳光接住。",
    body:
      "三亚是明确的气候答案：暖、海、度假感。它不一定适合所有长期奋斗剧本，但极适合阶段性修复、远程生活和把身体先救回来。\n\n若你最近的核心需求是回血，而不是攀登，三亚会非常直接。",
    scores: { pace: 1, ambition: 2, climate: 9, social: 5, cost: 7, nature: 9, culture: 2, spice: 3 },
  },
  tianjin: {
    name: "天津",
    tag: "京畿烟火气",
    quote: "你想靠近大舞台，却更想把日子过稳。",
    body:
      "天津离北京很近，却保留自己的相声、码头和市井温度。生活压力通常更可控，城市感完整。适合想借京津资源、又不想被完全卷走的人。\n\n如果你要的是「够用的机会 + 更松的呼吸」，天津常常被低估。",
    scores: { pace: 4, ambition: 5, climate: 3, social: 6, cost: 3, nature: 4, culture: 6, spice: 4 },
  },
  hefei: {
    name: "合肥",
    tag: "科教上升城",
    quote: "你想成长，但不想只靠硬扛一线房价。",
    body:
      "合肥这些年的关键词是科教、产业和上升感。节奏在加快，但仍比超一线留有余地。适合看重发展潜力、也看重生活性价比的人。\n\n若你处在「要往上走，但要算总账」的阶段，合肥值得进备选。",
    scores: { pace: 6, ambition: 7, climate: 5, social: 5, cost: 3, nature: 4, culture: 5, spice: 4 },
  },
};

const QUESTIONS = [
  {
    text: "周末醒来，你最渴望的状态是？",
    options: [
      { label: "慢慢吃brunch，谁也别催我", scores: { pace: 1, ambition: 2, social: 3 } },
      { label: "约人出门，城市要有点热闹", scores: { social: 8, pace: 6, spice: 6 } },
      { label: "去山海走走，把肺洗干净", scores: { nature: 9, pace: 2, climate: 7 } },
      { label: "赶上项目/学习，效率拉满", scores: { ambition: 9, pace: 9, cost: 7 } },
    ],
  },
  {
    text: "你更能接受哪种「城市的刺」？",
    options: [
      { label: "房租贵，但机会多", scores: { cost: 9, ambition: 8, pace: 8 } },
      { label: "冬天冷，但城市有底蕴", scores: { climate: 2, culture: 8, ambition: 6 } },
      { label: "节奏慢，但可能少一点刺激", scores: { pace: 2, spice: 2, ambition: 3 } },
      { label: "反差大、爬坡多，但很过瘾", scores: { spice: 9, pace: 7, social: 7 } },
    ],
  },
  {
    text: "选城时，你最先看哪一项？",
    options: [
      { label: "气候舒不舒服", scores: { climate: 9, nature: 6, pace: 3 } },
      { label: "收入和发展空间", scores: { ambition: 9, cost: 8, pace: 8 } },
      { label: "生活成不成本友好", scores: { cost: 2, pace: 3, ambition: 4 } },
      { label: "吃喝玩乐与社交浓度", scores: { social: 9, spice: 7, culture: 4 } },
    ],
  },
  {
    text: "你理想中的朋友局更像？",
    options: [
      { label: "三两人喝茶聊天就够", scores: { social: 2, pace: 2, culture: 6 } },
      { label: "夜宵、音乐、随时能续摊", scores: { social: 9, spice: 8, pace: 7 } },
      { label: "徒步、看展、有点审美", scores: { nature: 7, culture: 7, social: 5 } },
      { label: "行业局、信息局、交换机会", scores: { ambition: 8, social: 6, pace: 8 } },
    ],
  },
  {
    text: "面对压力，你的身体更想？",
    options: [
      { label: "逃到海边或四季如春的地方", scores: { climate: 8, nature: 8, pace: 1 } },
      { label: "用更强的刺激把压力冲掉", scores: { spice: 8, social: 7, pace: 7 } },
      { label: "找一座有文化厚度的城沉淀", scores: { culture: 9, pace: 4, ambition: 5 } },
      { label: "继续待在资源密集的地方硬刚", scores: { ambition: 9, cost: 8, pace: 9 } },
    ],
  },
  {
    text: "你更受不了哪种生活？",
    options: [
      { label: "每天都在赶，呼吸都浅", scores: { pace: 1, ambition: 2, nature: 6 } },
      { label: "太安逸，像人生暂停了", scores: { ambition: 8, spice: 7, pace: 8 } },
      { label: "气候极端，身体先崩溃", scores: { climate: 9, nature: 5, cost: 4 } },
      { label: "没朋友、没烟火，空得慌", scores: { social: 9, spice: 6, culture: 4 } },
    ],
  },
  {
    text: "如果城市是一种味道，你选？",
    options: [
      { label: "火锅麻辣，出汗就开心", scores: { spice: 8, social: 7, pace: 5 } },
      { label: "清茶淡甜，精致留白", scores: { pace: 3, culture: 6, nature: 6 } },
      { label: "海鲜啤酒，风里有盐", scores: { nature: 8, climate: 6, pace: 3 } },
      { label: "黑咖啡，醒脑又锋利", scores: { ambition: 8, pace: 8, cost: 7 } },
    ],
  },
  {
    text: "你对「一线城市」的态度是？",
    options: [
      { label: "值得，我想要最大舞台", scores: { ambition: 9, cost: 9, pace: 9 } },
      { label: "可以，但别牺牲生活质量", scores: { ambition: 6, nature: 6, cost: 6 } },
      { label: "算了，我要性价比和呼吸感", scores: { cost: 2, pace: 2, climate: 6 } },
      { label: "看阶段，年轻时冲，之后再调", scores: { ambition: 7, pace: 6, cost: 5 } },
    ],
  },
  {
    text: "一座城最能打动你的瞬间？",
    options: [
      { label: "凌晨还能吃到热乎的东西", scores: { social: 8, spice: 6, culture: 4 } },
      { label: "下班路上能看到山或湖", scores: { nature: 9, pace: 3, climate: 6 } },
      { label: "随手碰到行业大牛与展览", scores: { culture: 8, ambition: 8, pace: 7 } },
      { label: "天气舒服到让人想多走路", scores: { climate: 9, pace: 2, nature: 7 } },
    ],
  },
  {
    text: "此刻的你，更需要城市给你什么？",
    options: [
      { label: "滋养与修复", scores: { pace: 1, climate: 8, nature: 8, ambition: 2 } },
      { label: "机会与加速度", scores: { ambition: 9, pace: 9, cost: 8, spice: 5 } },
      { label: "热闹与情绪价值", scores: { social: 9, spice: 8, pace: 6 } },
      { label: "稳定与扎根感", scores: { culture: 8, cost: 3, pace: 3, ambition: 4 } },
    ],
  },
  {
    text: "房租占收入多少，你会开始焦虑？",
    options: [
      { label: "超过三成就不干了", scores: { cost: 1, pace: 3, ambition: 3 } },
      { label: "四成左右还能咬牙", scores: { cost: 5, ambition: 6, pace: 5 } },
      { label: "为了机会，一半也认", scores: { cost: 9, ambition: 9, pace: 8 } },
      { label: "不太算这笔账，先看舒不舒服", scores: { nature: 6, climate: 6, pace: 2, cost: 4 } },
    ],
  },
  {
    text: "你理想的通勤是？",
    options: [
      { label: "走路或骑车就到", scores: { pace: 2, nature: 6, cost: 3 } },
      { label: "地铁半小时内，能接受", scores: { pace: 5, ambition: 5, cost: 5 } },
      { label: "远一点没关系，工作要够劲", scores: { ambition: 8, pace: 8, cost: 7 } },
      { label: "最好经常在咖啡馆/家里办公", scores: { pace: 2, nature: 5, spice: 2 } },
    ],
  },
  {
    text: "陌生人密度，你更能适应哪种？",
    options: [
      { label: "人少一点，别总被注视", scores: { social: 2, pace: 2, nature: 6 } },
      { label: "适中，有人气但不拥挤", scores: { social: 5, pace: 4, culture: 5 } },
      { label: "越热闹越好，空城会慌", scores: { social: 9, spice: 7, pace: 6 } },
      { label: "白天忙、夜里静，层次分明", scores: { pace: 6, ambition: 6, culture: 6 } },
    ],
  },
  {
    text: "一座城的「文化感」，对你有多重要？",
    options: [
      { label: "很重要，我要博物馆和老街", scores: { culture: 9, pace: 4, ambition: 4 } },
      { label: "有最好，没有也能过", scores: { culture: 5, social: 5, pace: 5 } },
      { label: "更在意新事物和潮流", scores: { spice: 7, ambition: 7, culture: 3 } },
      { label: "自然风景比人文更戳我", scores: { nature: 9, climate: 7, culture: 3 } },
    ],
  },
  {
    text: "换季时你的身体通常？",
    options: [
      { label: "很敏感，极端天气直接躺平", scores: { climate: 9, pace: 2, nature: 6 } },
      { label: "还行，加件衣服就适应", scores: { climate: 5, pace: 5, ambition: 5 } },
      { label: "不太在意，冷热都扛得住", scores: { climate: 2, ambition: 7, spice: 5 } },
      { label: "只怕潮和闷，干冷反而清爽", scores: { climate: 4, nature: 5, culture: 5 } },
    ],
  },
  {
    text: "你更想被一座城怎样「对待」？",
    options: [
      { label: "温柔包容，允许我慢", scores: { pace: 1, social: 4, climate: 6 } },
      { label: "推着我成长，偶尔痛也值", scores: { ambition: 9, pace: 8, spice: 6 } },
      { label: "给我舞台和识人场", scores: { social: 8, ambition: 8, culture: 6 } },
      { label: "给我秩序和可预期的日常", scores: { culture: 6, cost: 4, pace: 4, ambition: 5 } },
    ],
  },
  {
    text: "夜宵对你来说是？",
    options: [
      { label: "灵魂需求，城市得有烟火", scores: { social: 8, spice: 7, pace: 6 } },
      { label: "偶尔来一顿就好", scores: { social: 5, pace: 4, cost: 4 } },
      { label: "能免则免，更爱早睡早起", scores: { pace: 2, ambition: 5, climate: 5 } },
      { label: "不如去夜跑或看江景", scores: { nature: 8, pace: 3, spice: 4 } },
    ],
  },
  {
    text: "如果三年后回头看，你希望这座城给过你？",
    options: [
      { label: "把身体和精神都养回来", scores: { pace: 1, climate: 8, nature: 8 } },
      { label: "一份拿得出手的履历跃迁", scores: { ambition: 9, cost: 8, pace: 8 } },
      { label: "一群真朋友和热闹的回忆", scores: { social: 9, spice: 7, culture: 4 } },
      { label: "一种「我属于这里」的踏实", scores: { culture: 8, cost: 3, pace: 3 } },
    ],
  },
];

const DIM_LABELS = {
  pace: "节奏",
  ambition: "事业",
  climate: "气候",
  social: "社交",
  cost: "成本",
  nature: "自然",
  culture: "人文",
  spice: "刺激",
};

const DIM_WHY = {
  pace: ["你更需要被允许慢下来", "你适应偏快的城市心跳", "你处在不快不慢的舒适区"],
  ambition: ["你暂时更想被滋养而不是被推着跑", "你愿意为成长付一点代价", "你在生活与进取之间找平衡"],
  climate: ["气候舒适对你几乎是刚需", "你扛得住季节的脾气", "天气不是你的第一决定因素"],
  social: ["你需要留白，而不是高密度社交", "热闹和人气会给你充电", "你对人群浓度没有极端偏好"],
  cost: ["性价比会显著影响你的幸福感", "你愿意为机会买单", "成本敏感度中等"],
  nature: ["靠近山海会让你明显回血", "城市感对你已足够", "自然是加分项但非唯一"],
  culture: ["文化厚度会让你有归属感", "你更在意当下体验而非历史感", "人文氛围对你有一定吸引力"],
  spice: ["你受不了太平淡的日常", "稳定比刺激更让你安心", "偶尔的反差感刚刚好"],
};

const els = {
  intro: document.getElementById("intro"),
  quiz: document.getElementById("quiz"),
  analyzing: document.getElementById("analyzing"),
  analyzeText: document.getElementById("analyzeText"),
  result: document.getElementById("result"),
  startBtn: document.getElementById("startBtn"),
  qIndex: document.getElementById("qIndex"),
  qText: document.getElementById("qText"),
  options: document.getElementById("options"),
  bar: document.getElementById("bar"),
  cityName: document.getElementById("cityName"),
  cityTag: document.getElementById("cityTag"),
  matchScore: document.getElementById("matchScore"),
  cityBody: document.getElementById("cityBody"),
  cityQuote: document.getElementById("cityQuote"),
  why: document.getElementById("why"),
  profile: document.getElementById("profile"),
  alts: document.getElementById("alts"),
  retryBtn: document.getElementById("retryBtn"),
};

let step = 0;
let userScores = Object.fromEntries(DIMENSIONS.map((d) => [d, 0]));
let answerCount = Object.fromEntries(DIMENSIONS.map((d) => [d, 0]));

function show(id) {
  ["intro", "quiz", "analyzing", "result"].forEach((key) => {
    els[key].classList.toggle("hidden", key !== id);
  });
}

function startQuiz() {
  step = 0;
  userScores = Object.fromEntries(DIMENSIONS.map((d) => [d, 0]));
  answerCount = Object.fromEntries(DIMENSIONS.map((d) => [d, 0]));
  show("quiz");
  renderQuestion();
}

function renderQuestion() {
  const q = QUESTIONS[step];
  const keys = ["A", "B", "C", "D"];
  els.qIndex.textContent = `${step + 1} / ${QUESTIONS.length}`;
  els.qText.textContent = q.text;
  els.bar.style.width = `${(step / QUESTIONS.length) * 100}%`;
  els.options.innerHTML = "";

  q.options.forEach((opt, idx) => {
    const btn = document.createElement("button");
    btn.className = "option";
    btn.type = "button";
    btn.innerHTML = `<span class="opt-key">${keys[idx] || idx + 1}</span><span class="opt-text"></span>`;
    btn.querySelector(".opt-text").textContent = opt.label;
    btn.addEventListener("click", () => {
      if (btn.disabled) return;
      [...els.options.querySelectorAll(".option")].forEach((el) => {
        el.disabled = true;
        el.classList.toggle("is-chosen", el === btn);
      });
      window.setTimeout(() => choose(opt.scores), 160);
    });
    els.options.appendChild(btn);
  });
}

function choose(scores) {
  Object.entries(scores).forEach(([k, v]) => {
    userScores[k] += v;
    answerCount[k] += 1;
  });
  step += 1;
  if (step >= QUESTIONS.length) {
    els.bar.style.width = "100%";
    finish();
  } else {
    renderQuestion();
  }
}

function normalizeUser() {
  const out = {};
  DIMENSIONS.forEach((d) => {
    out[d] = answerCount[d] ? userScores[d] / answerCount[d] : 5;
  });
  return out;
}

function distance(a, b) {
  let sum = 0;
  DIMENSIONS.forEach((d) => {
    const diff = (a[d] ?? 5) - (b[d] ?? 5);
    sum += diff * diff;
  });
  return Math.sqrt(sum);
}

function rankCities(user) {
  return Object.entries(CITIES)
    .map(([id, city]) => ({ id, city, dist: distance(user, city.scores) }))
    .sort((x, y) => x.dist - y.dist);
}

function matchPct(dist, maxDist) {
  return Math.max(62, Math.min(98, Math.round((1 - dist / maxDist) * 100)));
}

function finish() {
  const user = normalizeUser();
  const ranked = rankCities(user);
  show("analyzing");
  const lines = ["读取生活节奏偏好", "分析气候与身体耐受", "比对社交能量需求", "匹配最滋养的城市"];
  let i = 0;
  els.analyzeText.textContent = lines[0];
  const timer = setInterval(() => {
    i += 1;
    if (i < lines.length) {
      els.analyzeText.textContent = lines[i];
    } else {
      clearInterval(timer);
      renderResult(ranked, user);
      show("result");
    }
  }, 420);
}

function topTraits(user) {
  return Object.entries(user)
    .sort((a, b) => Math.abs(b[1] - 5) - Math.abs(a[1] - 5))
    .slice(0, 3)
    .map(([key, val]) => {
      const idx = val < 4 ? 0 : val > 6 ? 1 : 2;
      return DIM_WHY[key][idx];
    });
}

function renderResult(ranked, user) {
  const top = ranked[0];
  const city = top.city;
  const maxDist = ranked[ranked.length - 1].dist || 1;
  const score = matchPct(top.dist, maxDist);

  els.cityName.textContent = city.name;
  els.cityTag.textContent = city.tag;
  els.matchScore.textContent = `综合契合度 ${score}% · 基于 18 题偏好模型`;
  els.cityBody.textContent = city.body;
  els.cityQuote.textContent = `「${city.quote}」`;

  els.why.innerHTML = topTraits(user)
    .map((t) => `<div class="why-item">· ${t}</div>`)
    .join("");

  els.profile.innerHTML = DIMENSIONS.map((d) => {
    const val = user[d];
    const pct = Math.round((val / 9) * 100);
    return `<div class="dim"><span>${DIM_LABELS[d]}</span><div class="dim-bar"><i style="width:${pct}%"></i></div><span>${val.toFixed(1)}</span></div>`;
  }).join("");

  // trigger bar animation
  requestAnimationFrame(() => {
    els.profile.querySelectorAll(".dim-bar > i").forEach((el) => {
      const w = el.style.width;
      el.style.width = "0";
      requestAnimationFrame(() => {
        el.style.width = w;
      });
    });
  });

  els.alts.innerHTML = ranked
    .slice(1, 3)
    .map((item, idx) => {
      const match = matchPct(item.dist, maxDist);
      return `<div class="alt"><span>备选 ${idx + 1} · <strong>${item.city.name}</strong> · ${item.city.tag}</span><span class="muted">契合 ${match}%</span></div>`;
    })
    .join("");
}

els.startBtn.addEventListener("click", startQuiz);
els.retryBtn.addEventListener("click", startQuiz);

show("intro");
