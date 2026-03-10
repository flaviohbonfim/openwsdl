# Plano de Desenvolvimento: SOAP-Lite

Cliente SOAP desktop cross-platform leve, rápido e moderno, focado em performance e ergonomia visual.

---

## **Fase 1: Fundação e Shell Visual (Semana 1-2)**
**Objetivo:** Estabelecer a base da aplicação com layout estilo VS Code e sistema de temas.

- [ ] **1.1** Configurar projeto Flutter multiplataforma (Windows, macOS, Linux)
- [ ] **1.2** Implementar estrutura de layout principal:
  - NavigationRail lateral
  - Área central de editor
  - Painel de status inferior
  - SplitView redimensionável para explorador de serviços
- [ ] **1.3** Criar sistema de temas Dark/White de alto contraste
- [ ] **1.4** Implementar persistência de preferência de tema
- [ ] **Entregável:** Aplicação que abre instantaneamente, alterna temas e possui painéis funcionais

---

## **Fase 2: Editor de Código e Gestão de Abas (Semana 3-4)**
**Objetivo:** Integrar editor com syntax highlighting e sistema de abas para multitarefa.

- [ ] **2.1** Integrar Monaco Editor (via `flutter_monaco` ou WebView)
- [ ] **2.2** Implementar syntax highlighting para XML
- [ ] **2.3** Criar TabController dinâmico para múltiplas requisições
- [ ] **2.4** Adicionar funcionalidades do editor:
  - Go to Line
  - Busca e substituição
  - Prettify/Format XML
  - Folding de tags
- [ ] **2.5** Preservar estado do editor (cursor, scroll, texto) ao alternar abas
- [ ] **Entregável:** Editor funcional com abas múltiplas e formatação XML

---

## **Fase 3: Motor de Parsing WSDL/XSD (Semana 5-7)**
**Objetivo:** Desenvolver inteligência de leitura de contratos SOAP e geração automática de templates.

- [ ] **3.1** Implementar parser de WSDL 1.1 e 1.2 (usar pacote `xml` do Dart)
- [ ] **3.2** Criar resolvedor de namespaces e tipos complexos (XSD)
- [ ] **3.3** Desenvolver gerador de envelopes SOAP:
  - Detectar versão SOAP (1.1 vs 1.2)
  - Incluir namespaces corretos
  - Gerar Body com parâmetros da operação
- [ ] **3.4** Construir TreeView hierárquica na sidebar:
  - Projeto → Serviço → Binding → Operação
- [ ] **3.5** Implementar processamento assíncrono para WSDLs grandes
- [ ] **3.6** Adicionar comentários inteligentes no XML (minOccurs, maxOccurs, nillable)
- [ ] **Entregável:** Importação de WSDL gera coleção navegável com templates XML pré-preenchidos

---

## **Fase 4: Cliente HTTP e Ciclo de Resposta (Semana 8-9)**
**Objetivo:** Implementar comunicação de rede e visualização de respostas.

- [ ] **4.1** Implementar envio de requisições via POST
- [ ] **4.2** Configurar headers automaticamente:
  - Content-Type (baseado na versão SOAP)
  - SOAPAction (para SOAP 1.1)
- [ ] **4.3** Criar sistema de captura de resposta:
  - Status HTTP
  - Tempo de latência (timer)
  - Tamanho do payload
- [ ] **4.4** Exibir resposta em painel dedicado (Monaco Editor read-only)
- [ ] **4.5** Adicionar tratamento de erros de rede e timeout
- [ ] **Entregável:** Fluxo completo: Importar WSDL → Selecionar Operação → Editar → Enviar → Ver Resposta

---

## **Fase 5: Variáveis de Ambiente e Interpolação (Semana 10-11)**
**Objetivo:** Permitir gestão de múltiplos ambientes (Dev, Staging, Prod).

- [ ] **5.1** Criar gestor de ambientes com variáveis (ex: `{{BASE_URL}}`, `{{AUTH_TOKEN}}`)
- [ ] **5.2** Implementar motor de interpolação em tempo de execução
- [ ] **5.3** Desenvolver UI para criação/edição de ambientes
- [ ] **5.4** Permitir troca rápida entre ambientes ativos
- [ ] **5.5** Substituir padrões `{{chave}}` antes do envio da requisição
- [ ] **Entregável:** Sistema de ambientes funcional com substituição de variáveis

---

## **Fase 6: Persistência e Gestão de Coleções (Semana 12-13)**
**Objetivo:** Salvar trabalho localmente e permitir migração de outras ferramentas.

- [ ] **6.1** Implementar persistência em JSON local (filosofia "Local-first, Git-friendly")
- [ ] **6.2** Criar sistema de salvamento automático de coleções e requisições
- [ ] **6.3** Desenvolver importador de coleções Postman
- [ ] **6.4** Implementar exportação de coleções (formato Postman/JSON)
- [ ] **6.5** Adicionar histórico de requisições executadas
- [ ] **Entregável:** Aplicação salva estado entre sessões e importa/exporta coleções

---

## **Fase 7: Otimização e Polimento Final (Semana 14-15)**
**Objetivo:** Garantir performance, estabilidade e experiência refinada.

- [ ] **7.1** Profile de memória (meta: <150MB em repouso)
- [ ] **7.2** Otimizar tempo de inicialização (meta: <1.5 segundos)
- [ ] **7.3** Reduzir tamanho do binário (meta: <60MB)
- [ ] **7.4** Testes de estabilidade com WSDLs grandes (1000+ operações)
- [ ] **7.5** Refinar animações e transições de UI (60fps)
- [ ] **7.6** Criar instaladores para Windows, macOS e Linux
- [ ] **Entregável:** Aplicação finalizada, performática e pronta para distribuição

---

## **Resumo de Marcos e Métricas de Sucesso**

| Marco | Critério de Aceitação |
|-------|----------------------|
| **Fase 1** | UI abre em <2s, temas funcionam |
| **Fase 2** | Editor com highlight XML, 10+ abas simultâneas |
| **Fase 3** | Parser suporta WSDL 1.1/1.2, gera envelopes válidos |
| **Fase 4** | Requisições SOAP enviam e recebem com sucesso |
| **Fase 5** | Variáveis `{{chave}}` substituídas corretamente |
| **Fase 6** | Dados persistem após reiniciar app |
| **Fase 7** | RAM <150MB, binário <60MB, inicialização <1.5s |

---

## **Stack Tecnológico Recomendado**

| Componente | Tecnologia |
|------------|-----------|
| **Framework** | Flutter (Dart) |
| **Editor de Código** | Monaco Editor (via `flutter_monaco`) |
| **Parser XML** | Pacote `xml` (Dart) |
| **HTTP Client** | Pacote `http` (Dart) |
| **Persistência** | JSON local + `shared_preferences` |
| **Layout** | `multi_split_view`, `Row`/`Column` aninhados |

---

## **Estrutura de Diretórios do Projeto**

```
soap-lite/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── theme_provider.dart
│   │   └── routes.dart
│   ├── core/
│   │   ├── widgets/
│   │   │   ├── split_view.dart
│   │   │   └── status_bar.dart
│   │   └── utils/
│   │       └── constants.dart
│   ├── features/
│   │   ├── shell/
│   │   │   ├── shell_screen.dart
│   │   │   ├── navigation_rail.dart
│   │   │   └── sidebar.dart
│   │   ├── editor/
│   │   │   ├── editor_screen.dart
│   │   │   ├── tab_manager.dart
│   │   │   └── monaco_editor.dart
│   │   ├── wsdl/
│   │   │   ├── wsdl_parser.dart
│   │   │   ├── wsdl_tree.dart
│   │   │   └── soap_envelope.dart
│   │   ├── http_client/
│   │   │   ├── soap_client.dart
│   │   │   └── response_panel.dart
│   │   └── environment/
│   │       ├── environment_manager.dart
│   │       └── variable_interpolator.dart
│   └── services/
│       ├── storage_service.dart
│       └── collection_service.dart
├── assets/
│   └── themes/
├── test/
├── pubspec.yaml
├── README.md
└── CHANGELOG.md
```

---

*Documento criado em: 10 de março de 2026*
