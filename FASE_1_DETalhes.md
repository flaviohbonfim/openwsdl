# Fase 1: Fundação e Shell Visual

**Período:** Semana 1-2  
**Status:** 🟦 Em andamento  
**Entregável:** Aplicação que abre instantaneamente, alterna temas e possui painéis funcionais

---

## 📋 Visão Geral

Esta fase estabelece a base da aplicação com layout estilo VS Code e sistema de temas. O objetivo é criar uma estrutura sólida e visualmente consistente que servirá como fundação para todas as funcionalidades subsequentes.

---

## ✅ Tarefas da Fase 1

### 1.1 Configurar Projeto Flutter Multiplataforma

**Descrição:** Configurar o projeto Flutter com suporte a Windows, macOS e Linux.

**Subtarefas:**
- [x] Criar estrutura de diretórios do projeto
- [x] Configurar `pubspec.yaml` com dependências básicas
- [x] Configurar `analysis_options.yaml` com linting
- [ ] Executar `flutter create --platforms=windows,macos,linux .`
- [ ] Testar build em cada plataforma alvo

**Critérios de Aceitação:**
- ✅ Projeto Flutter criado com sucesso
- ✅ Dependências instaladas via `flutter pub get`
- ✅ Aplicação compila em todas as plataformas

**Comandos:**
```bash
cd soap-lite
flutter pub get
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

---

### 1.2 Implementar Estrutura de Layout Principal

**Descrição:** Criar o layout estilo VS Code com NavigationRail, área central e StatusBar.

**Subtarefas:**
- [x] Implementar `ShellScreen` (tela principal)
- [x] Criar `AppNavigationRail` com ícones de navegação
- [x] Criar `ExplorerSidebar` (barra lateral de explorador)
- [x] Implementar `StatusBar` (barra de status inferior)
- [ ] Adicionar funcionalidade de redimensionamento da sidebar (SplitView)
- [ ] Implementar colapsar/expander sidebar

**Critérios de Aceitação:**
- ✅ NavigationRail exibe 3 destinos (Explorador, Buscar, Extensões)
- ✅ Sidebar pode ser expandida/recolhida
- ✅ StatusBar exibe informações de status
- ✅ Layout responsivo se adapta a diferentes tamanhos de janela

**Arquivos Criados:**
```
lib/features/shell/
├── shell_screen.dart      ✅
├── navigation_rail.dart   ✅
└── sidebar.dart           ✅

lib/core/widgets/
└── status_bar.dart        ✅
```

---

### 1.3 Criar Sistema de Temas Dark/White

**Descrição:** Implementar temas de alto contraste inspirados no VS Code.

**Subtarefas:**
- [x] Criar `ThemeProvider` para gerenciar estado do tema
- [x] Definir `lightTheme` com cores claras
- [x] Definir `darkTheme` com cores escuras (VS Code style)
- [ ] Adicionar botão de toggle de tema na UI
- [ ] Aplicar temas a todos os widgets

**Critérios de Aceitação:**
- ✅ Tema claro e escuro definidos no `ThemeProvider`
- ✅ Cores de alto contraste em ambos temas
- ✅ Temas aplicados globalmente via `MaterialApp`

**Paleta de Cores:**

| Elemento | Dark Theme | Light Theme |
|----------|-----------|-------------|
| Surface | `#1E1E1E` | `#FFFFFF` |
| Sidebar | `#252526` | `#F3F3F3` |
| Header | `#2D2D2D` | `#FFFFFF` |
| Primary | `#60A5FA` | `#1E40AF` |
| Border | `#404040` | `#E5E5E5` |

**Arquivos Criados:**
```
lib/config/theme/
└── theme_provider.dart    ✅
```

---

### 1.4 Implementar Persistência de Preferência de Tema

**Descrição:** Salvar a preferência de tema do usuário usando SharedPreferences.

**Subtarefas:**
- [x] Adicionar pacote `shared_preferences` ao pubspec.yaml
- [x] Implementar método `toggleTheme()` no ThemeProvider
- [x] Implementar método `setTheme()` no ThemeProvider
- [ ] Carregar preferência salva na inicialização
- [ ] Salvar preferência ao alternar tema

**Critérios de Aceitação:**
- ✅ Preferência persistida entre sessões
- ✅ Tema restaurado ao reiniciar aplicativo
- ✅ Valor padrão é `ThemeMode.system`

**Arquivos Atualizados:**
```
lib/config/theme/theme_provider.dart  ✅
```

---

### 1.5 Integrar Provider para Gerenciamento de Estado

**Descrição:** Configurar Provider para gerenciar o estado do tema e outros estados globais.

**Subtarefas:**
- [x] Adicionar pacote `provider` ao pubspec.yaml
- [ ] Envolver `MaterialApp` com `MultiProvider`
- [ ] Adicionar `ChangeNotifierProvider` para ThemeProvider
- [ ] Atualizar `app.dart` para usar Provider

**Critérios de Aceitação:**
- ✅ Provider configurado no nível da aplicação
- ✅ ThemeProvider acessível via `context.watch` ou `context.read`

---

## 📁 Estrutura de Arquivos da Fase 1

```
soap-lite/
├── lib/
│   ├── main.dart                      ✅
│   ├── app.dart                       ✅
│   ├── config/
│   │   └── theme/
│   │       └── theme_provider.dart    ✅
│   ├── core/
│   │   ├── utils/
│   │   │   └── constants.dart         ✅
│   │   └── widgets/
│   │       └── status_bar.dart        ✅
│   └── features/
│       └── shell/
│           ├── shell_screen.dart      ✅
│           ├── navigation_rail.dart   ✅
│           └── sidebar.dart           ✅
├── pubspec.yaml                       ✅
├── analysis_options.yaml              ✅
└── README.md                          ✅
```

---

## 🎯 Critérios de Aceitação da Fase 1

A fase será considerada completa quando todos os seguintes critérios forem atendidos:

| Critério | Status |
|----------|--------|
| Aplicação abre em < 2 segundos | ⏳ Pendente |
| NavigationRail funcional com 3 destinos | ⏳ Pendente |
| Sidebar exibe conteúdo do explorador | ⏳ Pendente |
| StatusBar exibe informações de status | ⏳ Pendente |
| Tema Dark pode ser ativado/desativado | ⏳ Pendente |
| Preferência de tema é persistida | ⏳ Pendente |
| Layout responsivo e consistente | ⏳ Pendente |

---

## 🧪 Testes da Fase 1

**Testes Manuais:**
1. [ ] Iniciar aplicativo e medir tempo de inicialização
2. [ ] Alternar entre temas e verificar persistência
3. [ ] Redimensionar janela e verificar layout responsivo
4. [ ] Clicar em cada item do NavigationRail
5. [ ] Expandir/recolher sidebar

**Testes Unitários (Futuro):**
```dart
// test/config/theme/theme_provider_test.dart
test('ThemeProvider deve alternar entre dark e light', () { ... });
test('ThemeProvider deve persistir preferência', () { ... });

// test/features/shell/shell_screen_test.dart
test('ShellScreen deve exibir NavigationRail', () { ... });
test('ShellScreen deve alternar visibilidade da sidebar', () { ... });
```

---

## 🚀 Próximos Passos

Após completar esta fase, prosseguir para:

**Fase 2: Editor de Código e Gestão de Abas**
- Integrar Monaco Editor via `flutter_monaco`
- Implementar syntax highlighting para XML
- Criar sistema de abas dinâmico
- Adicionar funcionalidades de formatação XML

---

## 📝 Notas de Desenvolvimento

### Dependências Utilizadas
- `flutter/material`: UI base
- `provider`: Gerenciamento de estado
- `shared_preferences`: Persistência local

### Decisões de Design
- **Layout VS Code:** Escolhido por ser familiar para desenvolvedores
- **Provider:** Preferido sobre Riverpod/Bloc por simplicidade nesta fase inicial
- **SharedPreferences:** Adequado para preferências simples; migrar para Hive se necessário mais performance

### Problemas Conhecidos
- [ ] SplitView redimensionável ainda não implementado
- [ ] Monaco Editor será integrado na Fase 2
- [ ] Testes unitários serão adicionados após estabilização da UI

---

*Última atualização: 10 de março de 2026*
