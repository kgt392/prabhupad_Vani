import '../models/kirtan.dart';
import 'bhajan.dart';
import 'kirtan.dart' as k;
import 'japa.dart';

final List<Kirtan> allKirtansData = [
  ...bhajanKirtans,
  ...k.kirtanKirtans,
  ...japaKirtans,
];


