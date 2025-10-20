import 'package:flutter_bloc/flutter_bloc.dart';
import 'yolo_import_state.dart';

class YoloImportCubit extends Cubit<YoloImportState> {
  YoloImportCubit() : super(const YoloImportState());

  // Esta função é chamada quando o usuário digita no campo "Caminho Raiz".
  void setDatasetRootPath(String path) {
    emit(state.copyWith(datasetRootPath: path));
    _generateCommands();
  }

  // Esta função é chamada quando o usuário digita no campo "Caminho do Projeto".
  void setProjectPath(String path) {
    emit(state.copyWith(projectPath: path));
    _generateCommands();
  }

    // Esta função é chamada quando o usuário digita no campo "Caminho da imagem".
  void setImagePath(String path) {
    emit(state.copyWith(imagePath: path));
    _generateCommands();
  }
  
  // Esta função é chamada quando o usuário digita o nome do arquivo de saída.
  void setOutputFileName(String name) {
    String finalName = name;
    if (name.isNotEmpty && !name.endsWith('.json')) {
      finalName = '$name.json';
    }
    emit(state.copyWith(outputFileName: finalName));
    _generateCommands();
  }

  // Usado para controlar o Stepper.
  void goToStep(int step) => emit(state.copyWith(currentStep: step));
  
  // Lógica para extrair o caminho relativo (ex: "one/images").
  String _getRelativePath(String path, String from) {
    // Normaliza as barras para o padrão unix para facilitar a comparação.
    String p = path.replaceAll('\\', '/');
    String f = from.replaceAll('\\', '/');
    if (p.startsWith(f)) {
      String rel = p.substring(f.length);
      // Remove a barra inicial se houver.
      return rel.startsWith('/') ? rel.substring(1) : rel;
    }
    return path;
  }

  // O coração da nossa lógica: gera todos os comandos e caminhos.
  void _generateCommands() {
    final root = state.datasetRootPath.trim();
    final project = state.projectPath.trim();
    final imageurl = state.imagePath.trim();
    // Validação: se os caminhos estiverem vazios ou inválidos, limpa os resultados.
    if (root.isEmpty || project.isEmpty || !project.replaceAll('\\', '/').startsWith(root.replaceAll('\\', '/'))) {
      emit(state.copyWith(generatedUnixEnv: null, generatedWindowsEnv: null, generatedConverterCommand: null, imageSubPath: null));
      return;
    }
    
//  final pImagesPath = '$project/images';
    final pImagesPath = project;
    final imageURL = imageurl;
    final urlPath = _getRelativePath(pImagesPath, root);
    final urlImagePath = _getRelativePath(imageURL, root);
    final unixEnv = "export LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED=true\nexport LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT=$root";
    final winRoot = root.replaceAll(RegExp(r'[/\\]'), r'\\');
    final windowsEnv = "set LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED=true\nset LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT=$winRoot";
    final outputName = state.outputFileName.isEmpty ? 'output.json' : state.outputFileName;
//  final converterCommand = 'label-studio-converter import yolo -i "$project" -o "$outputName" --image-root-url "/data/local-files/?d=$urlPath"';
    final converterCommand = 'label-studio-converter import yolo -i "$root" -o "$outputName" --image-root-url "/data/local-files/?d=$urlPath"';
    
    // Emite um novo estado com todos os dados gerados.
    emit(state.copyWith(
      generatedUnixEnv: unixEnv,
      generatedWindowsEnv: windowsEnv,
      generatedConverterCommand: converterCommand,
      imageSubPath: urlPath,
      imagePath: urlImagePath,
    ));
  }
}