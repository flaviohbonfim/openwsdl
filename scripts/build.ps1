# Script de build para o SOAP-Lite (Fase 7)

Write-Host "Iniciando build do SOAP-Lite v1.0.0..." -ForegroundColor Cyan

# 1. Limpeza
Write-Host "Limpando build anterior..."
flutter clean

# 2. Dependências
Write-Host "Obtendo dependências..."
flutter pub get

# 3. Build Windows (Runner)
Write-Host "Compilando executável nativo (Windows)..."
flutter build windows --release --obfuscate --split-debug-info=build/debug

# 4. Gerar instalador MSIX
Write-Host "Gerando instalador MSIX..."
flutter pub run msix:create

Write-Host "Build concluído com sucesso!" -ForegroundColor Green
Write-Host "O instalador (.msix) encontra-se em build\windows\runner\Release\SOAP-Lite.msix"
