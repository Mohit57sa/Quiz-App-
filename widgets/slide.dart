import 'package:flutter/material.dart';

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  const Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
    imageUrl: 'assets/image1.jpg',
    title: 'QuizMaster',
    description: '  Challenge your brain with thousands of questions across subjects like science, history, and more.',
  ),
  Slide(
    imageUrl: 'assets/ImagE2..jpg',
    title: 'MindSpark',
    description: 'Ignite your knowledge with exciting quizzes. Learn and play every day!',
  ),
  Slide(
    imageUrl: 'assets/ImagE3.jpg',
    title: 'KnowQuest',
    description: 'Embark on a journey of learning through fun, interactive questions.',
  ),
];