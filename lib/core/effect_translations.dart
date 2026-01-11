/// WLED 效果名称中英文映射
/// 基于 WLED 0.14.x 版本效果列表
const Map<String, String> wledEffectTranslations = {
  // 基础效果
  'Solid': '纯色',
  'Blink': '闪烁',
  'Breathe': '呼吸',
  'Wipe': '擦除',
  'Wipe Random': '随机擦除',
  'Random Colors': '随机色彩',
  'Sweep': '扫描',
  'Dynamic': '动态',
  'Colorloop': '色彩循环',
  'Rainbow': '彩虹',
  'Scan': '扫描',
  'Scan Dual': '双向扫描',
  'Fade': '渐变',
  'Theater': '剧场',
  'Theater Rainbow': '剧场彩虹',
  'Running': '跑马灯',
  'Saw': '锯齿',
  'Twinkle': '闪烁星',
  'Dissolve': '溶解',
  'Dissolve Rnd': '随机溶解',
  'Sparkle': '火花',
  'Sparkle Dark': '暗火花',
  'Sparkle+': '火花+',
  'Strobe': '频闪',
  'Strobe Rainbow': '彩虹频闪',
  'Strobe Mega': '超级频闪',
  'Blink Rainbow': '彩虹闪烁',
  'Android': '安卓',
  'Chase': '追逐',
  'Chase Random': '随机追逐',
  'Chase Rainbow': '彩虹追逐',
  'Chase Flash': '闪光追逐',
  'Chase Flash Rnd': '随机闪光追逐',
  'Rainbow Runner': '彩虹跑者',
  'Colorful': '多彩',
  'Traffic Light': '红绿灯',
  'Sweep Random': '随机扫描',
  'Chase 2': '追逐2',
  'Aurora': '极光',
  'Stream': '流光',
  'Scanner': '扫描器',
  'Lighthouse': '灯塔',
  'Fireworks': '烟花',
  'Rain': '雨滴',
  'Tetrix': '俄罗斯方块',
  'Fire Flicker': '火焰闪烁',
  'Gradient': '渐变',
  'Loading': '加载中',
  'Police': '警灯',
  'Fairy': '仙女',
  'Two Dots': '双点',
  'Fairytwinkle': '仙女闪烁',
  'Running Dual': '双向跑马灯',
  'Halloween': '万圣节',
  'Chase 3': '追逐3',
  'Tri Wipe': '三色擦除',
  'Tri Fade': '三色渐变',
  'Lightning': '闪电',
  'ICU': '重症监护',
  'Multi Comet': '多彗星',
  'Scanner Dual': '双向扫描器',
  'Stream 2': '流光2',
  'Oscillate': '振荡',
  'Pride 2015': '骄傲2015',
  'Juggle': '杂耍',
  'Palette': '调色板',
  'Fire 2012': '火焰2012',
  'Colorwaves': '色彩波浪',
  'Bpm': '节拍',
  'Fill Noise': '噪点填充',
  'Noise 1': '噪点1',
  'Noise 2': '噪点2',
  'Noise 3': '噪点3',
  'Noise 4': '噪点4',
  'Colortwinkles': '彩色闪烁',
  'Lake': '湖泊',
  'Meteor': '流星',
  'Meteor Smooth': '平滑流星',
  'Railway': '铁路',
  'Ripple': '涟漪',
  'Twinklefox': '狐狸闪烁',
  'Twinklecat': '猫咪闪烁',
  'Halloween Eyes': '万圣节眼睛',
  'Solid Pattern': '纯色图案',
  'Solid Pattern Tri': '三色纯色图案',
  'Spots': '光斑',
  'Spots Fade': '渐变光斑',
  'Glitter': '闪光',
  'Candle': '蜡烛',
  'Fireworks Starburst': '星爆烟花',
  'Fireworks 1D': '一维烟花',
  'Bouncing Balls': '弹跳球',
  'Sinelon': '正弦',
  'Sinelon Dual': '双正弦',
  'Sinelon Rainbow': '彩虹正弦',
  'Popcorn': '爆米花',
  'Drip': '水滴',
  'Plasma': '等离子',
  'Percent': '百分比',
  'Ripple Rainbow': '彩虹涟漪',
  'Heartbeat': '心跳',
  'Pacifica': '太平洋',
  'Candle Multi': '多彩蜡烛',
  'Solid Glitter': '闪光纯色',
  'Sunrise': '日出',
  'Phased': '相位',
  'Twinkleup': '闪烁上升',
  'Noise Pal': '调色板噪点',
  'Sine': '正弦波',
  'Phased Noise': '噪点相位',
  'Flow': '流动',
  'Chunchun': '啾啾',
  'Dancing Shadows': '舞动阴影',
  'Washing Machine': '洗衣机',
  'Candy Cane': '拐杖糖',
  'Blends': '混合',
  'TV Simulator': '电视模拟',
  'Dynamic Smooth': '平滑动态',

  // 2D 效果
  'Spaceships': '飞船',
  'Crazy Bees': '疯狂蜜蜂',
  'Ghost Rider': '恶灵骑士',
  'Blobs': '水滴球',
  'Scrolling Text': '滚动文字',
  'Drift Rose': '漂移玫瑰',
  'Distortion Waves': '扭曲波浪',
  'Soap': '肥皂泡',
  'Octopus': '章鱼',
  'Waving Cell': '波动细胞',
  'Pixels': '像素',
  'Pixelwave': '像素波',
  'Juggles': '杂耍球',
  'Matripix': '矩阵像素',
  'Gravimeter': '重力计',
  'Plasmoid': '等离子体',
  'Puddles': '水坑',
  'Midnoise': '正午噪点',
  'Noisemeter': '噪点计',
  'Freqwave': '频率波',
  'Freqmatrix': '频率矩阵',
  'GEQ': '图形均衡器',
  'Waterfall': '瀑布',
  'Freqpixels': '频率像素',
  'Binmap': '二进制映射',
  'Noisefire': '噪点火焰',
  'Puddlepeak': '水坑峰值',
  'Noisemove': '噪点移动',
  'Noise2D': '2D噪点',
  'Perlin Move': '柏林移动',
  'Ripple Peak': '涟漪峰值',
  'Firenoise': '火焰噪点',
  'Squared Swirl': '方形漩涡',
  'Fire2D': '2D火焰',
  'DNA': 'DNA螺旋',
  'Matrix': '黑客帝国',
  'Metaballs': '融合球',
  'Freqmap': '频率映射',
  'Gravcenter': '重力中心',
  'Gravcentric': '重力同心',
  'Gravfreq': '重力频率',
  'DJ Light': 'DJ灯光',
  'Funky Plank': '时髦木板',
  'Pulser': '脉冲器',
  'Blurz': '模糊',
  'Drift': '漂移',
  'Waverly': '波浪利',
  'Sun Radiation': '太阳辐射',
  'Colored Bursts': '彩色爆发',
  'Julia': '朱利亚集',
  'Game Of Life': '生命游戏',
  'Tartan': '格子呢',
  'Polar Lights': '极地光',
  'Swirl': '漩涡',
  'Lissajous': '李萨如曲线',
  'Frizzles': '卷曲',
  'Plasma Ball': '等离子球',
  'Flow Stripe': '流动条纹',
  'Hiphotic': '催眠',
  'Sindots': '正弦点',
  'DNA Spiral': 'DNA螺旋',
  'Black Hole': '黑洞',
  'Wavesins': '波浪正弦',
  'Rocktaves': '摇滚音阶',
  'Akemi': '明美',

  // 保留字段
  'RSVD': '保留',
  '-': '-',
};

/// 获取效果的中文名称
/// 如果没有对应翻译，返回原名称
/// 获取效果的中文名称
/// 如果没有对应翻译，返回原名称
String getEffectChineseName(String englishName) {
  // 检查是否有前缀 *
  final hasAsterisk = englishName.trim().startsWith('*');

  // 清理名称
  var cleanName = englishName.replaceAll(RegExp(r'^[\*\s]+'), '').trim();

  String translatedName = cleanName;
  bool found = false;

  if (wledEffectTranslations.containsKey(cleanName)) {
    translatedName = wledEffectTranslations[cleanName]!;
    found = true;
  } else {
    // 尝试不区分大小写匹配
    final lowerName = cleanName.toLowerCase();
    for (final key in wledEffectTranslations.keys) {
      if (key.toLowerCase() == lowerName) {
        translatedName = wledEffectTranslations[key]!;
        found = true;
        break;
      }
    }
  }

  if (found) {
    return hasAsterisk ? '* $translatedName' : translatedName;
  }

  return englishName;
}

/// WLED 调色板名称中英文映射
const Map<String, String> wledPaletteTranslations = {
  'Default': '默认',
  'Random Cycle': '随机循环',
  'Color 1': '颜色1',
  'Colors 1&2': '颜色1和2',
  'Color Gradient': '颜色渐变',
  'Colors Only': '仅颜色',
  'Party': '派对',
  'Cloud': '云彩',
  'Lava': '熔岩',
  'Ocean': '海洋',
  'Forest': '森林',
  'Rainbow': '彩虹',
  'Rainbow Bands': '彩虹条带',
  'Sunset': '日落',
  'Rivendell': '瑞文戴尔',
  'Breeze': '微风',
  'Red & Blue': '红蓝',
  'Yellowout': '黄色渐出',
  'Analogous': '类似色',
  'Splash': '飞溅',
  'Pastel': '粉彩',
  'Sunset 2': '日落2',
  'Beach': '海滩',
  'Vintage': '复古',
  'Departure': '启程',
  'Landscape': '风景',
  'Beech': '山毛榉',
  'Sherbet': '果汁冰',
  'Hult': '胡尔特',
  'Hult 64': '胡尔特64',
  'Drywet': '干湿',
  'Jul': '七月',
  'Grintage': '灰复古',
  'Rewhi': '雷维',
  'Tertiary': '三次色',
  'Fire': '火焰',
  'Icefire': '冰火',
  'Cyane': '青色',
  'Light Pink': '浅粉',
  'Autumn': '秋天',
  'Magenta': '洋红',
  'Magred': '洋红红',
  'Yelmag': '黄洋红',
  'Yelblu': '黄蓝',
  'Orange & Teal': '橙青',
  'Tiamat': '提亚马特',
  'April Night': '四月之夜',
  'Orangery': '橘园',
  'C9': 'C9',
  'Sakura': '樱花',
  'Aurora': '极光',
  'Atlantica': '亚特兰蒂斯',
  'C9 2': 'C9 2',
  'C9 New': 'C9新版',
  'Temperature': '温度',
  'Aurora 2': '极光2',
  'Retro Clown': '复古小丑',
  'Candy': '糖果',
  'Toxy Reaf': '毒礁',
  'Fairy Reaf': '仙境礁',
  'Semi Blue': '半蓝',
  'Pink Candy': '粉色糖果',
  'Red Reaf': '红礁',
  'Aqua Flash': '水色闪光',
  'Yelblu Hot': '热黄蓝',
  'Lite Light': '轻光',
  'Red Flash': '红色闪光',
  'Blink Red': '红色闪烁',
  'Red Shift': '红移',
  'Red Tide': '红潮',
  'Candy2': '糖果2',
};

/// 获取调色板的中文名称
String getPaletteChineseName(String englishName) {
  // 检查是否有前缀 *
  // WLED 有时会在调色板名称前加 * 表示动态/特殊调色板
  final hasAsterisk = englishName.trim().startsWith('*');

  // 清理名称：去除开头的 * 和多余空格以便查找
  var cleanName = englishName.replaceAll(RegExp(r'^[\*\s]+'), '').trim();

  String translatedName = cleanName;
  bool found = false;

  // 尝试直接匹配清理后的名称
  if (wledPaletteTranslations.containsKey(cleanName)) {
    translatedName = wledPaletteTranslations[cleanName]!;
    found = true;
  } else {
    // 尝试不区分大小写匹配
    final lowerName = cleanName.toLowerCase();
    for (final key in wledPaletteTranslations.keys) {
      if (key.toLowerCase() == lowerName) {
        translatedName = wledPaletteTranslations[key]!;
        found = true;
        break;
      }
    }
  }

  // 如果找到翻译且原名有星号，则把星号加回去
  // 通常保持 "* " 的格式
  if (found) {
    return hasAsterisk ? '* $translatedName' : translatedName;
  }

  // 如果没找到翻译，返回原名
  return englishName;
}

/// WLED 效果参数名称中英文映射
const Map<String, String> wledParameterTranslations = {
  'Speed': '速度',
  'Intensity': '强度',
  'Custom 1': '参数 1',
  'Custom 2': '参数 2',
  'Custom 3': '参数 3',
  'Custom 1-3': '参数 1-3',
  'Fade rate': '渐变速率',
  'Fade': '渐变',
  'Decay': '衰减',
  'Size': '尺寸',
  'Width': '宽度',
  'Length': '长度',
  'Speed/Rate': '速率',
  'Rate': '频率',
  'Hue': '色相',
  'Saturation': '饱和度',
  'Density': '密度',
  'Spread': '扩散',
  'Frequency': '频率',
  'Direction': '方向',
  'Mode': '模式',
  'Probability': '概率',
  'Count': '数量',
  'Weight': '权重',
  'Ripple width': '涟漪宽度',
  'Wave width': '波浪宽度',
  'Wave count': '波浪数量',
  'Wave size': '波浪尺寸',
  'Pulse rate': '脉冲频率',
  'Duration': '持续时间',
  'Delay': '延时',
  'Amount': '数量',
  'Distance': '距离',
  'Offset': '偏移',
  'Range': '范围',
  'Sensitivity': '灵敏度',
  'Threshold': '阈值',
  'Center': '中心',
  'Mirror': '镜像',
  'Reverse': '反向',
  'Random': '随机',
  'Sparkle': '火花',
  'Glitter': '闪光',
  'Softness': '柔和度',
  'Sharpness': '锐度',
  'Brightness': '亮度',
  'Scale': '缩放',
  'Selection': '选择',
  'Interval': '间隔',
  'Probability / Mode': '概率/模式',
  'Duty cycle': '工作周期',
  '# of lines': '线条数',
  'Blur': '模糊',
  'Trail': '拖尾',
  'Segments': '分段',
  'Zones': '区域',
  'Gap size': '间隙大小',
  'Color depth': '颜色深度',
  'Rotate': '旋转',
  'Angle': '角度',
  'Zoom': '放大',
  'X scale': 'X 缩放',
  'Y scale': 'Y 缩放',
};

/// 获取效果参数的翻译名称
String getParameterTranslation(String englishLabel) {
  if (englishLabel.isEmpty) return englishLabel;

  // 如果已经是中文，直接返回（检测是否包含中文字符）
  if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(englishLabel)) {
    return englishLabel;
  }

  // 尝试直接匹配
  if (wledParameterTranslations.containsKey(englishLabel)) {
    return wledParameterTranslations[englishLabel]!;
  }

  // 尝试不区分大小写匹配
  final lowerLabel = englishLabel.toLowerCase();
  for (final key in wledParameterTranslations.keys) {
    if (key.toLowerCase() == lowerLabel) {
      return wledParameterTranslations[key]!;
    }
  }

  // 关键词模糊匹配 (优先级覆盖)
  if (lowerLabel.contains('speed')) return '速度';
  if (lowerLabel.contains('intensity')) return '强度';
  if (lowerLabel.contains('width')) return '宽度';
  if (lowerLabel.contains('size')) return '尺寸';
  if (lowerLabel.contains('length')) return '长度';
  if (lowerLabel.contains('count')) return '数量';
  if (lowerLabel.contains('amount')) return '数量';
  if (lowerLabel.contains('fade')) return '渐变';
  if (lowerLabel.contains('rate')) return '速率';
  if (lowerLabel.contains('decay')) return '衰减';
  if (lowerLabel.contains('hue')) return '色相';
  if (lowerLabel.contains('sat')) return '饱和度';
  if (lowerLabel.contains('den')) return '密度';
  if (lowerLabel.contains('freq')) return '频率';
  if (lowerLabel.contains('prob')) return '概率';
  if (lowerLabel.contains('mode')) return '模式';
  if (lowerLabel.contains('dist')) return '距离';
  if (lowerLabel.contains('range')) return '范围';
  if (lowerLabel.contains('off')) return '偏移';
  if (lowerLabel.contains('thresh')) return '阈值';

  if (lowerLabel.contains('custom')) {
    if (lowerLabel.contains('1')) return '参数 1';
    if (lowerLabel.contains('2')) return '参数 2';
    if (lowerLabel.contains('3')) return '参数 3';
    return '自定义';
  }

  return englishLabel;
}
