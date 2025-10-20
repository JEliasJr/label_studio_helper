import 'package:equatable/equatable.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class YoloImportState extends Equatable {
  const YoloImportState({
    this.currentStep = 0,
    this.datasetRootPath = '',
    this.projectPath = '',
    this.imagePath = '',
    this.outputFileName = 'output.json',
    this.generatedUnixEnv,
    this.generatedWindowsEnv,
    this.generatedConverterCommand,
    this.imageSubPath,
  });

  final int currentStep;
  final String datasetRootPath;
  final String projectPath;
  final String imagePath;
  final String outputFileName;
  final String? generatedUnixEnv;
  final String? generatedWindowsEnv;
  final String? generatedConverterCommand;
  final String? imageSubPath;
  
  // Um getter útil para verificar se temos dados para mostrar nos passos 2 e 3.
  bool get hasDataForReport => generatedUnixEnv != null && generatedConverterCommand != null;

  YoloImportState copyWith({
    int? currentStep,
    String? datasetRootPath,
    String? projectPath,
    String? imagePath,
    String? outputFileName,
    String? generatedUnixEnv,
    String? generatedWindowsEnv,
    String? generatedConverterCommand,
    String? imageSubPath,
  }) {
    return YoloImportState(
      currentStep: currentStep ?? this.currentStep,
      datasetRootPath: datasetRootPath ?? this.datasetRootPath,
      projectPath: projectPath ?? this.projectPath,
      imagePath: imagePath ?? this.imagePath,
      outputFileName: outputFileName ?? this.outputFileName,
      generatedUnixEnv: generatedUnixEnv ?? this.generatedUnixEnv,
      generatedWindowsEnv: generatedWindowsEnv ?? this.generatedWindowsEnv,
      generatedConverterCommand: generatedConverterCommand ?? this.generatedConverterCommand,
      imageSubPath: imageSubPath ?? this.imageSubPath,
    );
  }

  @override
  List<Object?> get props => [
        currentStep, datasetRootPath, projectPath, imagePath, outputFileName,
        generatedUnixEnv, generatedWindowsEnv, generatedConverterCommand, imageSubPath,
      ];
}