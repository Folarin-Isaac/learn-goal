class PracticeQuestion {
  const new({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.solution,
  });

  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String solution;

  String get correctLetter => String.fromCharCode(65 + correctOptionIndex);
}

const _longAnswer =
    "Medication review involves an evaluation of a patient's medicines "
    'with the aim of optimising the quality use of medicines';

const mockPracticeQuestions = [
  PracticeQuestion(
    text: 'What is Patient Medication Review?',
    options: [_longAnswer, _longAnswer, _longAnswer],
    correctOptionIndex: 2,
    solution: _longAnswer,
  ),
  PracticeQuestion(
    text: 'Which bone is also known as the shoulder blade?',
    options: [
      'The clavicle, which sits across the front of the upper chest',
      'The scapula, a flat triangular bone of the shoulder girdle',
      'The humerus, the long bone of the upper arm',
    ],
    correctOptionIndex: 1,
    solution:
        'The scapula is the flat triangular bone that forms the back of '
        'the shoulder girdle in vertebrates.',
  ),
  PracticeQuestion(
    text: 'What is the primary function of bone marrow?',
    options: [
      'It produces the blood cells the body circulates',
      'It stores fat reserves and nothing else',
      'It secretes the hormones that regulate growth',
    ],
    correctOptionIndex: 0,
    solution:
        'Red bone marrow is the site of haematopoiesis, where red cells, '
        'white cells and platelets are produced.',
  ),
  PracticeQuestion(
    text: 'The axial skeleton includes all of the following except:',
    options: [
      'The skull, which encloses and protects the brain',
      'The vertebral column, which supports the trunk',
      'The pelvic girdle, which anchors the lower limbs',
    ],
    correctOptionIndex: 2,
    solution:
        'The pelvic girdle belongs to the appendicular skeleton, not the '
        'axial skeleton.',
  ),
  PracticeQuestion(
    text: 'Which part of the skeleton facilitates limb movement?',
    options: [
      'The axial skeleton, formed by the skull and trunk',
      'The appendicular skeleton, formed by the limbs and girdles',
      'The thoracic cage, formed by the ribs and sternum',
    ],
    correctOptionIndex: 1,
    solution:
        'The appendicular skeleton carries the limbs and their girdles, '
        'which is what makes limb movement possible.',
  ),
];
