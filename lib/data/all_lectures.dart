import 'brahma_samhita.dart';
import 'Asorted.dart';
import 'BG.dart';
import 'cc.dart';
import 'devoteeaddress.dart';
import 'discussion.dart';
import 'festival.dart';
import 'initiantions.dart';
import 'iso.dart';
import 'interviews.dart';
import 'Krishnabook.dart';
import 'nod.dart';
import 'SrimadBhagavad.dart';
import 'story.dart';
import 'walk.dart';

import '../../models/lecture.dart';

// 🔥 Merge all lecture lists into one big list
final List<Lecture> allLecturesData = [
  ...brahmaSamhitaLectures,
  ...asortedLectures,
  ...bhagavadGitaLectures,
  ...caitanyaCaritamrtaLectures,
  ...devoteeAddressLectures,
  ...discussionLectures,
  ...festivalLectures,
  ...initiationsLectures,
  ...isopanishadLectures,
  ...interviewsLectures,
  ...krishnaBookLectures,
  ...lecturesLectures,
  ...srimadBhagavatamLectures,
  ...srimadLectures,
  ...morningWalksLectures,
];
