class SeedItem {
  const SeedItem(this.name, this.emoji, this.price, this.level);
  final String name;
  final String emoji;
  final int price;
  final int level;
}

const seeds = <SeedItem>[
  SeedItem('القمح', '🌾', 10000, 1),
  SeedItem('الذرة', '🌽', 25000, 3),
  SeedItem('الجزر', '🥕', 57000, 5),
  SeedItem('الخيار', '🥒', 123000, 7),
  SeedItem('الطماطم', '🍅', 257000, 10),
  SeedItem('البطاطس', '🥔', 527000, 14),
  SeedItem('الليمون', '🍋', 1300000, 18),
  SeedItem('التفاح', '🍎', 2680000, 25),
  SeedItem('البرتقال', '🍊', 5560000, 30),
  SeedItem('العنب', '🍇', 11320000, 37),
  SeedItem('الفراولة', '🍓', 22950000, 45),
  SeedItem('التوت', '🫐', 46200000, 60),
  SeedItem('الكرز', '🍒', 135000000, 75),
  SeedItem('الأناناس', '🍍', 340000000, 100),
  SeedItem('جوز الهند', '🥥', 1000000000, 120),
];

class AnimalItem {
  const AnimalItem(this.name, this.emoji, this.price, {this.productive = true});
  final String name;
  final String emoji;
  final int price;
  final bool productive;
}

const animals = <AnimalItem>[
  AnimalItem('الدجاج', '🐓', 100000),
  AnimalItem('البقر', '🐄', 250000),
  AnimalItem('الغنم', '🐑', 750000),
  AnimalItem('السمك', '🐟', 1500000),
  AnimalItem('الطيور', '🦅', 2000000),
  AnimalItem('النحل', '🐝', 1000000),
  AnimalItem('القطط', '🐈', 120000, productive: false),
  AnimalItem('الكلاب', '🦮', 360000, productive: false),
  AnimalItem('الخيول', '🐎', 950000, productive: false),
];

class ToolItem {
  const ToolItem(this.name, this.emoji, this.price, this.description);
  final String name;
  final String emoji;
  final int price;
  final String description;
}

const tools = <ToolItem>[
  ToolItem('الفأس', '🪓', 15, 'يزيد سرعة الحصاد بنسبة 25%'),
  ToolItem('الدلو', '🪣', 20, 'يقلل وقت نمو المحاصيل إلى النصف'),
  ToolItem('المعول', '⛏️', 30, 'يضاعف كمية الحصاد'),
];

String formatDinar(int amount) {
  final s = amount.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return '$out د.ع';
}
