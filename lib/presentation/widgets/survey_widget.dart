import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

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
    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(6)),
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: BorderRadius.circular(MinqTokens.spacing(10)),
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
                      style: MinqTokens.titleLarge.copyWith(
                        color: MinqTokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.survey.description != null) ...[
                      SizedBox(height: MinqTokens.spacing(1)),
                      Text(
                        widget.survey.description!,
                        style: MinqTokens.bodySmall.copyWith(
                          color: MinqTokens.textSecondary,
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
          SizedBox(height: MinqTokens.spacing(6)),
          // 進捗インジケーター
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.survey.questions.length,
            backgroundColor: MinqTokens.background,
            valueColor: AlwaysStoppedAnimation<Color>(MinqTokens.brandPrimary),
          ),
          SizedBox(height: MinqTokens.spacing(1)),
          Text(
            '${_currentQuestionIndex + 1} / ${widget.survey.questions.length}',
            style: MinqTokens.bodySmall.copyWith(
              color: MinqTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MinqTokens.spacing(10)),
          // 質問
          _buildQuestion(_currentQuestion),
          SizedBox(height: MinqTokens.spacing(10)),
          // ナビゲーションボタン
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    child: Text(AppLocalizations.of(context).back),
                  ),
                ),
              if (_currentQuestionIndex > 0)
                SizedBox(width: MinqTokens.spacing(4)),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canProceed ? _nextQuestion : null,
                  child: Text(
                    _isLastQuestion
                        ? AppLocalizations.of(context).submit
                        : AppLocalizations.of(context).next,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(SurveyQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: MinqTokens.bodyLarge.copyWith(
            color: MinqTokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (question.isRequired)
          Text(
            AppLocalizations.of(context).required,
            style: MinqTokens.bodySmall.copyWith(
              color: const Color(0xFFEF4444),
            ),
          ),
        SizedBox(height: MinqTokens.spacing(4)),
        _buildQuestionInput(question),
      ],
    );
  }

  Widget _buildQuestionInput(SurveyQuestion question) {
    switch (question.type) {
      case SurveyQuestionType.multipleChoice:
        return _buildMultipleChoice(question);
      case SurveyQuestionType.rating:
        return _buildRating(question);
      case SurveyQuestionType.text:
        return _buildTextInput(question);
      case SurveyQuestionType.yesNo:
        return _buildYesNo(question);
    }
  }

  Widget _buildMultipleChoice(SurveyQuestion question) {
    return Column(
      children:
          question.options!.map((option) {
            final isSelected = _answers[question.id] == option;
            return Padding(
              padding: EdgeInsets.only(bottom: MinqTokens.spacing(2)),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _answers[question.id] = option;
                  });
                },
                borderRadius: MinqTokens.cornerMedium(),
                child: Container(
                  padding: EdgeInsets.all(MinqTokens.spacing(4)),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? MinqTokens.brandPrimary.withAlpha(
                              (255 * 0.1).round(),
                            )
                            : MinqTokens.background,
                    borderRadius: MinqTokens.cornerMedium(),
                    border: Border.all(
                      color:
                          isSelected
                              ? MinqTokens.brandPrimary
                              : const Color(0xFFE5E7EB),
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
                            isSelected
                                ? MinqTokens.brandPrimary
                                : MinqTokens.textSecondary,
                      ),
                      SizedBox(width: MinqTokens.spacing(2)),
                      Expanded(
                        child: Text(
                          option,
                          style: MinqTokens.bodyLarge.copyWith(
                            color: MinqTokens.textPrimary,
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

  Widget _buildRating(SurveyQuestion question) {
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
              color:
                  isSelected ? MinqTokens.brandPrimary : MinqTokens.background,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected
                        ? MinqTokens.brandPrimary
                        : const Color(0xFFE5E7EB),
              ),
            ),
            child: Center(
              child: Text(
                rating.toString(),
                style: MinqTokens.bodyLarge.copyWith(
                  color: isSelected ? Colors.white : MinqTokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextInput(SurveyQuestion question) {
    return TextField(
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).pleaseEnterAnswer,
        border: OutlineInputBorder(borderRadius: MinqTokens.cornerMedium()),
      ),
      maxLines: 3,
      onChanged: (value) {
        setState(() {
          _answers[question.id] = value;
        });
      },
    );
  }

  Widget _buildYesNo(SurveyQuestion question) {
    return Row(
      children: [
        Expanded(
          child: _buildYesNoButton(AppLocalizations.of(context).yes, true),
        ),
        SizedBox(width: MinqTokens.spacing(4)),
        Expanded(
          child: _buildYesNoButton(AppLocalizations.of(context).no, false),
        ),
      ],
    );
  }

  Widget _buildYesNoButton(String label, bool value) {
    final isSelected = _answers[_currentQuestion.id] == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _answers[_currentQuestion.id] = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? MinqTokens.brandPrimary : MinqTokens.surface,
        foregroundColor: isSelected ? Colors.white : MinqTokens.textPrimary,
        padding: EdgeInsets.symmetric(vertical: MinqTokens.spacing(4)),
        shape: RoundedRectangleBorder(
          borderRadius: MinqTokens.cornerMedium(),
          side: BorderSide(
            color:
                isSelected ? MinqTokens.brandPrimary : const Color(0xFFE5E7EB),
          ),
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
  static Survey userSatisfaction(BuildContext context) => Survey(
    id: 'user_satisfaction_2025',
    title: AppLocalizations.of(context).userSatisfactionSurvey,
    description: AppLocalizations.of(context).userSatisfactionDescription,
    questions: [
      SurveyQuestion(
        id: 'q1',
        text: AppLocalizations.of(context).usabilityRating,
        type: SurveyQuestionType.rating,
        maxRating: 5,
      ),
      SurveyQuestion(
        id: 'q2',
        text: AppLocalizations.of(context).mostLikedFeature,
        type: SurveyQuestionType.multipleChoice,
        options: [
          AppLocalizations.of(context).questManagement,
          AppLocalizations.of(context).pairFeature,
          AppLocalizations.of(context).statisticsGraphs,
          AppLocalizations.of(context).notificationFeature,
          AppLocalizations.of(context).other,
        ],
      ),
      SurveyQuestion(
        id: 'q3',
        text: AppLocalizations.of(context).wouldRecommendMinq,
        type: SurveyQuestionType.yesNo,
      ),
      SurveyQuestion(
        id: 'q4',
        text: AppLocalizations.of(context).improvementSuggestions,
        type: SurveyQuestionType.text,
        isRequired: false,
      ),
    ],
  );
}
