/// The background style of the avatar.
enum AvatarStyle {
  /// Circular background.
  circle('Circle'),

  /// Transparent background.
  transparent('Transparent')
  ;

  const AvatarStyle(this.label);

  /// Human-readable label.
  final String label;
}

/// Top / hair type.
enum TopType {
  /// No hair.
  noHair('No Hair'),

  /// Eyepatch.
  eyepatch('Eyepatch'),

  /// Hat.
  hat('Hat'),

  /// Hijab.
  hijab('Hijab'),

  /// Turban.
  turban('Turban'),

  /// Winter hat 1.
  winterHat1('Winter Hat 1'),

  /// Winter hat 2.
  winterHat2('Winter Hat 2'),

  /// Winter hat 3.
  winterHat3('Winter Hat 3'),

  /// Winter hat 4.
  winterHat4('Winter Hat 4'),

  /// Long hair big hair.
  longHairBigHair('Long Hair Big Hair'),

  /// Long hair bob.
  longHairBob('Long Hair Bob'),

  /// Long hair bun.
  longHairBun('Long Hair Bun'),

  /// Long hair curly.
  longHairCurly('Long Hair Curly'),

  /// Long hair curvy.
  longHairCurvy('Long Hair Curvy'),

  /// Long hair dreads.
  longHairDreads('Long Hair Dreads'),

  /// Long hair frida.
  longHairFrida('Long Hair Frida'),

  /// Long hair fro.
  longHairFro('Long Hair Fro'),

  /// Long hair fro band.
  longHairFroBand('Long Hair Fro Band'),

  /// Long hair mia wallace.
  longHairMiaWallace('Long Hair Mia Wallace'),

  /// Long hair not too long.
  longHairNotTooLong('Long Hair Not Too Long'),

  /// Long hair shaved sides.
  longHairShavedSides('Long Hair Shaved Sides'),

  /// Long hair straight.
  longHairStraight('Long Hair Straight'),

  /// Long hair straight 2.
  longHairStraight2('Long Hair Straight 2'),

  /// Long hair straight strand.
  longHairStraightStrand('Long Hair Straight Strand'),

  /// Short hair dreads 01.
  shortHairDreads01('Short Hair Dreads 01'),

  /// Short hair dreads 02.
  shortHairDreads02('Short Hair Dreads 02'),

  /// Short hair frizzle.
  shortHairFrizzle('Short Hair Frizzle'),

  /// Short hair shaggy.
  shortHairShaggy('Short Hair Shaggy'),

  /// Short hair shaggy mullet.
  shortHairShaggyMullet('Short Hair Shaggy Mullet'),

  /// Short hair short curly.
  shortHairShortCurly('Short Hair Short Curly'),

  /// Short hair short flat.
  shortHairShortFlat('Short Hair Short Flat'),

  /// Short hair short round.
  shortHairShortRound('Short Hair Short Round'),

  /// Short hair short waved.
  shortHairShortWaved('Short Hair Short Waved'),

  /// Short hair sides.
  shortHairSides('Short Hair Sides'),

  /// Short hair the caesar.
  shortHairTheCaesar('Short Hair The Caesar'),

  /// Short hair the caesar side part.
  shortHairTheCaesarSidePart('Short Hair The Caesar Side Part')
  ;

  const TopType(this.label);

  /// Human-readable label.
  final String label;

  /// Whether this top type displays hair (and thus uses [HairColor]).
  bool get hasHair =>
      name.startsWith('longHair') || name.startsWith('shortHair');

  /// Whether this top type is a hat (and thus uses [HatColor]).
  bool get hasHat =>
      this == hat ||
      this == hijab ||
      this == turban ||
      name.startsWith('winterHat');
}

/// Accessories / glasses type.
enum AccessoriesType {
  /// No accessories.
  blank('Blank'),

  /// Kurt style glasses.
  kurt('Kurt'),

  /// Prescription glasses 01.
  prescription01('Prescription 01'),

  /// Prescription glasses 02.
  prescription02('Prescription 02'),

  /// Round glasses.
  round('Round'),

  /// Sunglasses.
  sunglasses('Sunglasses'),

  /// Wayfarers.
  wayfarers('Wayfarers')
  ;

  const AccessoriesType(this.label);

  /// Human-readable label.
  final String label;
}

/// Hair color.
enum HairColor {
  /// Auburn.
  auburn('Auburn', 0xFFA55728),

  /// Black.
  black('Black', 0xFF2C1B18),

  /// Blonde.
  blonde('Blonde', 0xFFB58143),

  /// Blonde golden.
  blondeGolden('Blonde Golden', 0xFFD6B370),

  /// Brown.
  brown('Brown', 0xFF724133),

  /// Brown dark.
  brownDark('Brown Dark', 0xFF4A312C),

  /// Pastel pink.
  pastelPink('Pastel Pink', 0xFFF59797),

  /// Blue.
  blue('Blue', 0xFF000FDB),

  /// Platinum.
  platinum('Platinum', 0xFFECDCBF),

  /// Red.
  red('Red', 0xFFC93305),

  /// Silver gray.
  silverGray('Silver Gray', 0xFFE8E1E1)
  ;

  const HairColor(this.label, this.color);

  /// Human-readable label.
  final String label;

  /// The ARGB color value.
  final int color;
}

/// Hat color (same palette used for clothe colors).
enum HatColor {
  /// Black.
  black('Black', 0xFF262E33),

  /// Blue 01.
  blue01('Blue 01', 0xFF65C9FF),

  /// Blue 02.
  blue02('Blue 02', 0xFF5199E4),

  /// Blue 03.
  blue03('Blue 03', 0xFF25557C),

  /// Gray 01.
  gray01('Gray 01', 0xFFE6E6E6),

  /// Gray 02.
  gray02('Gray 02', 0xFF929598),

  /// Heather.
  heather('Heather', 0xFF3C4F5C),

  /// Pastel blue.
  pastelBlue('Pastel Blue', 0xFFB1E2FF),

  /// Pastel green.
  pastelGreen('Pastel Green', 0xFFA7FFC4),

  /// Pastel orange.
  pastelOrange('Pastel Orange', 0xFFFFDEB5),

  /// Pastel red.
  pastelRed('Pastel Red', 0xFFFFAFB9),

  /// Pastel yellow.
  pastelYellow('Pastel Yellow', 0xFFFFFFB1),

  /// Pink.
  pink('Pink', 0xFFFF488E),

  /// Red.
  red('Red', 0xFFFF5C5C),

  /// White.
  white('White', 0xFFFFFFFF)
  ;

  const HatColor(this.label, this.color);

  /// Human-readable label.
  final String label;

  /// The ARGB color value.
  final int color;
}

/// Facial hair type.
enum FacialHairType {
  /// No facial hair.
  blank('Blank'),

  /// Light beard.
  beardLight('Beard Light'),

  /// Majestic beard.
  beardMajestic('Beard Majestic'),

  /// Medium beard.
  beardMedium('Beard Medium'),

  /// Fancy moustache.
  moustacheFancy('Moustache Fancy'),

  /// Magnum moustache.
  moustacheMagnum('Moustache Magnum')
  ;

  const FacialHairType(this.label);

  /// Human-readable label.
  final String label;

  /// Whether this type has visible facial hair
  /// (and thus uses [FacialHairColor]).
  bool get hasFacialHair => this != blank;
}

/// Facial hair color.
enum FacialHairColor {
  /// Auburn.
  auburn('Auburn', 0xFFA55728),

  /// Black.
  black('Black', 0xFF2C1B18),

  /// Blonde.
  blonde('Blonde', 0xFFB58143),

  /// Blonde golden.
  blondeGolden('Blonde Golden', 0xFFD6B370),

  /// Brown.
  brown('Brown', 0xFF724133),

  /// Brown dark.
  brownDark('Brown Dark', 0xFF4A312C),

  /// Platinum.
  platinum('Platinum', 0xFFECDCBF),

  /// Red.
  red('Red', 0xFFC93305)
  ;

  const FacialHairColor(this.label, this.color);

  /// Human-readable label.
  final String label;

  /// The ARGB color value.
  final int color;
}

/// Clothe type.
enum ClotheType {
  /// Blazer with shirt.
  blazerShirt('Blazer Shirt'),

  /// Blazer with sweater.
  blazerSweater('Blazer Sweater'),

  /// Collar sweater.
  collarSweater('Collar Sweater'),

  /// Graphic shirt.
  graphicShirt('Graphic Shirt'),

  /// Hoodie.
  hoodie('Hoodie'),

  /// Overall.
  overall('Overall'),

  /// Crew neck shirt.
  shirtCrewNeck('Shirt Crew Neck'),

  /// Scoop neck shirt.
  shirtScoopNeck('Shirt Scoop Neck'),

  /// V-neck shirt.
  shirtVNeck('Shirt V-Neck')
  ;

  const ClotheType(this.label);

  /// Human-readable label.
  final String label;

  /// Whether this clothing type uses [ClotheColor].
  bool get hasClotheColor => this != blazerShirt && this != blazerSweater;

  /// Whether this clothing type displays a graphic
  /// (and thus uses [GraphicType]).
  bool get hasGraphic => this == graphicShirt;
}

/// Clothe color (same palette as hat color).
enum ClotheColor {
  /// Black.
  black('Black', 0xFF262E33),

  /// Blue 01.
  blue01('Blue 01', 0xFF65C9FF),

  /// Blue 02.
  blue02('Blue 02', 0xFF5199E4),

  /// Blue 03.
  blue03('Blue 03', 0xFF25557C),

  /// Gray 01.
  gray01('Gray 01', 0xFFE6E6E6),

  /// Gray 02.
  gray02('Gray 02', 0xFF929598),

  /// Heather.
  heather('Heather', 0xFF3C4F5C),

  /// Pastel blue.
  pastelBlue('Pastel Blue', 0xFFB1E2FF),

  /// Pastel green.
  pastelGreen('Pastel Green', 0xFFA7FFC4),

  /// Pastel orange.
  pastelOrange('Pastel Orange', 0xFFFFDEB5),

  /// Pastel red.
  pastelRed('Pastel Red', 0xFFFFAFB9),

  /// Pastel yellow.
  pastelYellow('Pastel Yellow', 0xFFFFFFB1),

  /// Pink.
  pink('Pink', 0xFFFF488E),

  /// Red.
  red('Red', 0xFFFF5C5C),

  /// White.
  white('White', 0xFFFFFFFF)
  ;

  const ClotheColor(this.label, this.color);

  /// Human-readable label.
  final String label;

  /// The ARGB color value.
  final int color;
}

/// Graphic on a graphic shirt.
enum GraphicType {
  /// Skull.
  skull('Skull'),

  /// Skull outline.
  skullOutline('Skull Outline'),

  /// Bat.
  bat('Bat'),

  /// Cumbia.
  cumbia('Cumbia'),

  /// Deer.
  deer('Deer'),

  /// Diamond.
  diamond('Diamond'),

  /// Hola.
  hola('Hola'),

  /// Selena.
  selena('Selena'),

  /// Pizza.
  pizza('Pizza'),

  /// Resist.
  resist('Resist'),

  /// Bear.
  bear('Bear')
  ;

  const GraphicType(this.label);

  /// Human-readable label.
  final String label;
}

/// Eye type.
enum EyeType {
  /// Closed eyes.
  close('Close'),

  /// Crying eyes.
  cry('Cry'),

  /// Default eyes.
  defaultEye('Default'),

  /// Dizzy eyes.
  dizzy('Dizzy'),

  /// Eye roll.
  eyeRoll('Eye Roll'),

  /// Happy eyes.
  happy('Happy'),

  /// Heart eyes.
  hearts('Hearts'),

  /// Side glance.
  side('Side'),

  /// Squinting eyes.
  squint('Squint'),

  /// Surprised eyes.
  surprised('Surprised'),

  /// Wink.
  wink('Wink'),

  /// Wacky wink.
  winkWacky('Wink Wacky')
  ;

  const EyeType(this.label);

  /// Human-readable label.
  final String label;
}

/// Eyebrow type.
enum EyebrowType {
  /// Angry eyebrows.
  angry('Angry'),

  /// Angry natural eyebrows.
  angryNatural('Angry Natural'),

  /// Default eyebrows.
  defaultBrow('Default'),

  /// Default natural eyebrows.
  defaultNatural('Default Natural'),

  /// Flat natural eyebrows.
  flatNatural('Flat Natural'),

  /// Frown natural eyebrows.
  frownNatural('Frown Natural'),

  /// Raised excited eyebrows.
  raisedExcited('Raised Excited'),

  /// Raised excited natural eyebrows.
  raisedExcitedNatural('Raised Excited Natural'),

  /// Sad concerned eyebrows.
  sadConcerned('Sad Concerned'),

  /// Sad concerned natural eyebrows.
  sadConcernedNatural('Sad Concerned Natural'),

  /// Unibrow natural.
  unibrowNatural('Unibrow Natural'),

  /// Up down eyebrows.
  upDown('Up Down'),

  /// Up down natural eyebrows.
  upDownNatural('Up Down Natural')
  ;

  const EyebrowType(this.label);

  /// Human-readable label.
  final String label;
}

/// Mouth type.
enum MouthType {
  /// Concerned mouth.
  concerned('Concerned'),

  /// Default mouth.
  defaultMouth('Default'),

  /// Disbelief mouth.
  disbelief('Disbelief'),

  /// Eating.
  eating('Eating'),

  /// Grimace.
  grimace('Grimace'),

  /// Sad.
  sad('Sad'),

  /// Scream open.
  screamOpen('Scream Open'),

  /// Serious.
  serious('Serious'),

  /// Smile.
  smile('Smile'),

  /// Tongue out.
  tongue('Tongue'),

  /// Twinkle.
  twinkle('Twinkle'),

  /// Vomit.
  vomit('Vomit')
  ;

  const MouthType(this.label);

  /// Human-readable label.
  final String label;
}

/// Skin color.
enum SkinColor {
  /// Tanned.
  tanned('Tanned', 0xFFFD9841),

  /// Yellow.
  yellow('Yellow', 0xFFF8D25C),

  /// Pale.
  pale('Pale', 0xFFFFDBB4),

  /// Light.
  light('Light', 0xFFEDB98A),

  /// Brown.
  brown('Brown', 0xFFD08B5B),

  /// Dark brown.
  darkBrown('Dark Brown', 0xFFAE5D29),

  /// Black.
  black('Black', 0xFF614335)
  ;

  const SkinColor(this.label, this.color);

  /// Human-readable label.
  final String label;

  /// The ARGB color value.
  final int color;
}
