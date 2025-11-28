import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/app_theme.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// アプリ内アンケートウィジェット
class SurveyWidget extends StatefulWidget {
  final Survey survey;
  final Function(SurveyResponse) onSubmit;
  final VoidCallback? onSkip;

  const SurveyWidget({
    super.key,
    required this.survey,
    required this.onSubmit,
    this.onSkip,
  });

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  final Map<String, dynamic> _answers = {};
  int _currentQuestionIndex = 0;

  SurveyQuestion get _currentQuestion =>
      widget.survey.questions[_currentQuestionIndex];
  bool get _isLastQuestion =>
      _currentQuestionIndex == widget.survey.questions.length - 1;
  bool get _canProceed => _answers.containsKey(_currentQuestion.id);

  void _nextQuestion() {
    if (_isLastQuestion) {
      _submitSurvey();
    } else {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitSurvey() {
    final response = SurveyResponse(
      surveyId: widget.survey.id,
      answers: _answers,
      completedAt: DateTime.now(),
    );
    widget.onSubmit(response);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ヘッダー
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.survey.title,
                      style: tokens.typography.h3.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.survey.description != null) ...[
                      SizedBox(height: tokens.spacing.xs),
                      Text(
                        widget.survey.description!,
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.onSkip != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onSkip,
                ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          // 進捗インジケーター
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.survey.questions.length,
            backgroundColor: tokens.background,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.primary),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            '質問 ${_currentQuestionIndex + 1} / ${widget.survey.questions.length}',
            style: tokens.typography.caption.copyWith(
              color: tokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacing.xl),
          // 質問
          _buildQuestion(_currentQuestion, tokens),
          SizedBox(height: tokens.spacing.xl),
          // ナビゲーションボタン
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    child: const Text('戻る'),
                  ),
                ),
              if (_currentQuestionIndex > 0) SizedBox(width: tokens.spacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canProceed ? _nextQuestion : null,
                  child: Text(_isLastQuestion ? '送信' : '次へ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(SurveyQuestion question, MinqTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: tokens.typography.body.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (question.isRequired)
          Text(
            ' *必須',
            style: tokens.typography.caption.copyWith(color: tokens.error),
          ),
        SizedBox(height: tokens.spacing.md),
        _buildQuestionInput(question, tokens),
      ],
    );
  }

  Widget _buildQuestionInput(SurveyQuestion question, MinqTheme tokens) {
    switch (question.type) {
      case SurveyQuestionType.multipleChoice:
        return _buildMultipleChoice(question, tokens);
      case SurveyQuestionType.rating:
        return _buildRating(question, tokens);
      case SurveyQuestionType.text:
        return _buildTextInput(question, tokens);
      case SurveyQuestionType.yesNo:
        return _buildYesNo(question, tokens);
    }
  }

  Widget _buildMultipleChoice(SurveyQuestion question, MinqTheme tokens) {
    return Column(
      children:
          question.options!.map((option) {
            final isSelected = _answers[question.id] == option;
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.sm),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _answers[question.id] = option;
                  });
                },
                borderRadius: BorderRadius.circular(tokens.radius.md),
                child: Container(
                  padding: EdgeInsets.all(tokens.spacing.md),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? tokens.primary.withValues(alpha: 0.1)
                            : tokens.background,
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                    border: Border.all(
                      color: isSelected ? tokens.primary : tokens.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color:
                            isSelected ? tokens.primary : tokens.textSecondary,
                      ),
                      SizedBox(width: tokens.spacing.sm),
                      Expanded(
                        child: Text(
                          option,
                          style: tokens.typography.body.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildRating(SurveyQuestion question, MinqTheme tokens) {
    final maxRating = question.maxRating ?? 5;
    final currentRating = _answers[question.id] as int?;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(maxRating, (index) {
        final rating = index + 1;
        final isSelected = currentRating == rating;
        return InkWell(
          onTap: () {
            setState(() {
              _answers[question.id] = rating;
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? tokens.primary : tokens.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? tokens.primary : tokens.border,
              ),
            ),
            child: Center(
              child: Text(
                rating.toString(),
                style: tokens.typography.body.copyWith(
                  color: isSelected ? Colors.white : tokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextInput(SurveyQuestion question, MinqTheme tokens) {
    return TextField(
      decoration: InputDecoration(
        hintText: '回答を入力してください',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
        ),
      ),
      maxLines: 3,
      onChanged: (value) {
        setState(() {
          _answers[question.id] = value;
        });
      },
    );
  }

  Widget _buildYesNo(SurveyQuestion question, MinqTheme tokens) {
    return Row(
      children: [
        Expanded(child: _buildYesNoButton('はい', true, tokens)),
        SizedBox(width: tokens.spacing.md),
        Expanded(child: _buildYesNoButton('いいえ', false, tokens)),
      ],
    );
  }

  Widget _buildYesNoButton(String label, bool value, MinqTheme tokens) {
    final isSelected = _answers[_currentQuestion.id] == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _answers[_currentQuestion.id] = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? tokens.primary : tokens.surface,
        foregroundColor: isSelected ? Colors.white : tokens.textPrimary,
        padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          side: BorderSide(color: isSelected ? tokens.primary : tokens.border),
        ),
      ),
      child: Text(label),
    );
  }
}

/// アンケート定義
class Survey {
  final String id;
  final String title;
  final String? description;
  final List<SurveyQuestion> questions;

  const Survey({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
  });
}

/// アンケート質問
class SurveyQuestion {
  final String id;
  final String text;
  final SurveyQuestionType type;
  final bool isRequired;
  final List<String>? options;
  final int? maxRating;

  const SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.isRequired = true,
    this.options,
    this.maxRating,
  });
}

/// 質問タイプ
enum SurveyQuestionType { multipleChoice, rating, text, yesNo }

/// アンケート回答
class SurveyResponse {
  final String surveyId;
  final Map<String, dynamic> answers;
  final DateTime completedAt;

  const SurveyResponse({
    required this.surveyId,
    required this.answers,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'surveyId': surveyId,
      'answers': answers,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}

/// サンプルアンケート
class SampleSurveys {
  static Survey get userSatisfaction => const Survey(
    id: 'user_satisfaction_2025',
    title: 'ユーザー満足度調査',
    description: 'MinQをより良くするため、ご意見をお聞かせください',
    questions: [
      SurveyQuestion(
        id: 'q1',
        text: 'MinQの使いやすさを5段階で評価してください',
        type: SurveyQuestionType.rating,
        maxRating: 5,
      ),
      SurveyQuestion(
        id: 'q2',
        text: '最も気に入っている機能は何ですか？',
        type: SurveyQuestionType.multipleChoice,
        options: ['クエスト管理', 'ペア機能', '統計・グラフ', '通知機能', 'その他'],
      ),
      SurveyQuestion(
        id: 'q3',
        text: '友人にMinQを勧めますか？',
        type: SurveyQuestionType.yesNo,
      ),
      SurveyQuestion(
        id: 'q4',
        text: '改善してほしい点があれば教えてください',
        type: SurveyQuestionType.text,
        isRequired: false,
      ),
    ],
  );
}
