import 'dart:convert';
import 'dart:typed_data'; // Import necessário para Uint8List
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Importações do nosso próprio projeto
import 'package:label_studio_helper/features/yolo_import/cubit/yolo_import_cubit.dart';
import 'package:label_studio_helper/features/yolo_import/cubit/yolo_import_state.dart';
import 'package:label_studio_helper/features/yolo_import/widgets/check_url_card.dart'; // CORREÇÃO: Import que faltava
import 'package:label_studio_helper/features/yolo_import/widgets/code_viewer.dart';
import 'package:label_studio_helper/features/yolo_import/widgets/copyable_card.dart';
import 'package:label_studio_helper/services/download_service.dart';

class YoloImportPage extends StatelessWidget {
  const YoloImportPage({super.key});
  @override
  Widget build(BuildContext context) {
    // O BlocProvider é responsável por criar e "fornecer" nosso Cubit
    // para todos os widgets filhos.
    return BlocProvider(
      create: (_) => YoloImportCubit(),
      child: const YoloImportView(),
    );
  }
}

class YoloImportView extends StatelessWidget {
  const YoloImportView({super.key});

  // Função para gerar o conteúdo do relatório de texto.
  void _generateAndDownloadTxtReport(YoloImportState state) {
    final buffer = StringBuffer();
    final separator = '==================================================\n';
    
    buffer.writeln(separator);
    buffer.writeln('  RELATÓRIO DE CONFIGURAÇÃO - LABEL STUDIO (YOLO)');
    buffer.writeln(separator);
    buffer.writeln('Gerado em: ${DateTime.now().toLocal().toString().substring(0, 16)}\n');
    buffer.writeln('--- 1. ENTRADAS DO USUÁRIO ---');
    buffer.writeln('Caminho Raiz: ${state.datasetRootPath}');
    buffer.writeln('Caminho do Projeto: ${state.projectPath}');
    buffer.writeln('Caminho da Imagem: ${state.imagePath}');
    buffer.writeln('Nome do Arquivo de Saída: ${state.outputFileName}\n');
    buffer.writeln('--- 2. COMANDOS DE AMBIENTE (Unix) ---');
    buffer.writeln('${state.generatedUnixEnv}\n');
    buffer.writeln('--- 3. COMANDOS DE AMBIENTE (Windows) ---');
    buffer.writeln('${state.generatedWindowsEnv}\n');
    buffer.writeln('--- 4. CONFIGURAÇÃO DO LABEL STUDIO (Cloud Storage) ---');
    buffer.writeln('Absolute local path: ${state.projectPath}/images');
    buffer.writeln('Relative path: ${state.imageSubPath}\n');
    buffer.writeln('--- 5. COMANDO DE CONVERSÃO ---');
    buffer.writeln(state.generatedConverterCommand);
    buffer.writeln(separator);

    final textBytes = utf8.encode(buffer.toString());
    
    // Chama nosso serviço de download, que funcionará em todas as plataformas!
    DownloadService().downloadFile(
      bytes: Uint8List.fromList(textBytes), // CORREÇÃO: Conversão de List<int> para Uint8List
      downloadName: 'relatorio-label-studio.txt',
      mimeType: 'text/plain',
    );
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<...>() "assiste" a mudanças no Cubit e reconstrói este widget.
    final state = context.watch<YoloImportCubit>().state;
    // context.read<...>() é usado para chamar funções no Cubit.
    final cubit = context.read<YoloImportCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Label Studio: Assistente de Importação YOLO'), backgroundColor: Colors.deepPurple.shade50),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: state.currentStep,
        onStepTapped: cubit.goToStep,
        onStepContinue: () { if (state.currentStep < 2) cubit.goToStep(state.currentStep + 1); },
        onStepCancel: () { if (state.currentStep > 0) cubit.goToStep(state.currentStep - 1); },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                if (state.currentStep < 2) ElevatedButton(onPressed: details.onStepContinue, child: const Text('Próximo')),
                const SizedBox(width: 8),
                if (state.currentStep > 0) TextButton(onPressed: details.onStepCancel, child: const Text('Voltar')),
              ],
            ),
          );
        },
        steps: [
          _buildStepPaths(context),
          _buildStepSetup(context),
          _buildStepConvert(context),
        ],
      ),
    );
  }

  // A seguir, os métodos que constroem cada passo do Stepper.
  // Note como eles agora usam nossos widgets reutilizáveis!

  Step _buildStepPaths(BuildContext context) {
    final state = context.watch<YoloImportCubit>().state;
    final cubit = context.read<YoloImportCubit>();
    final pathsAreValid = state.projectPath.isEmpty || state.datasetRootPath.isEmpty || state.projectPath.replaceAll('\\', '/').startsWith(state.datasetRootPath.replaceAll('\\', '/'));

    return Step(
      title: const Text('1. Configurar Caminhos'), isActive: state.currentStep >= 0,
      content: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(initialValue: state.datasetRootPath, decoration: const InputDecoration(labelText: 'Caminho Raiz dos Datasets', hintText: '/yolo/datasets ou c:\\yolo\\datasets'), onChanged: cubit.setDatasetRootPath),
          const SizedBox(height: 16),
          TextFormField(initialValue: state.projectPath, decoration: const InputDecoration(labelText: 'Caminho do Projeto Específico', hintText: '/yolo/datasets/one ou c:\\yolo\\datasets\\one'), onChanged: cubit.setProjectPath),
          const SizedBox(height: 16),
          TextFormField(initialValue: state.imagePath, decoration: const InputDecoration(labelText: 'Caminho da imagem', hintText: '/yolo/datasets/one/*.jpg ou c:\\yolo\\datasets\\*.jpg'), onChanged: cubit.setImagePath),
          if (!pathsAreValid) const Padding(padding: EdgeInsets.only(top: 12.0), child: Text('Atenção: O caminho do projeto deve estar contido dentro do caminho raiz.', style: TextStyle(color: Colors.redAccent, fontSize: 12))),
        ],
      ),
    );
  }

  Step _buildStepSetup(BuildContext context) {
    final state = context.watch<YoloImportCubit>().state;
    final checkUrlBase = "http://localhost:8080/data/local-files/?d=${state.imagePath ?? ''}";

    return Step(
      title: const Text('2. Preparar Ambiente'), isActive: state.currentStep >= 1,
      content: !state.hasDataForReport
          ? const Text('Por favor, preencha os caminhos no passo anterior de forma válida.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Execute no seu terminal:', style: TextStyle(fontWeight: FontWeight.bold)),
                CodeViewer(title: 'Unix (Linux/macOS)', code: state.generatedUnixEnv!),
                CodeViewer(title: 'Windows', code: state.generatedWindowsEnv!),
                const SizedBox(height: 16),
                const Text('2. No Label Studio, preencha os campos de Cloud Storage:', style: TextStyle(fontWeight: FontWeight.bold)),
                CopyableCard(title: 'Absolute local path', value: state.projectPath),
                const SizedBox(height: 8),
                CopyableCard(title: 'Relative path', value: state.imageSubPath!),
                const SizedBox(height: 16),
                const Text('3. Verifique o acesso no navegador:', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckUrlCard(baseUrl: checkUrlBase),
              ],
            ),
    );
  }

  Step _buildStepConvert(BuildContext context) {
    final state = context.watch<YoloImportCubit>().state;
    final cubit = context.read<YoloImportCubit>();

    return Step(
      title: const Text('3. Converter e Importar'), isActive: state.currentStep >= 2,
      content: !state.hasDataForReport
          ? const Text('Por favor, preencha os caminhos no Passo 1.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Escolha o nome do arquivo de saída:', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: TextFormField(initialValue: state.outputFileName, decoration: const InputDecoration(suffixText: '.json'), onChanged: cubit.setOutputFileName),
                ),
                const Text('2. Execute este comando:', style: TextStyle(fontWeight: FontWeight.bold)),
                CodeViewer(title: 'Comando de Conversão', code: state.generatedConverterCommand!),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.description),
                    label: const Text('Gerar Relatório (.txt)'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                    onPressed: state.hasDataForReport
                      ? () => _generateAndDownloadTxtReport(state)
                      : null,
                  ),
                ),
              ],
            ),
    );
  }
}