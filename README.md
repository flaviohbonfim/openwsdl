# SOAP-Lite

Cliente SOAP desktop cross-platform leve, rápido e moderno, focado em performance e ergonomia visual.

## 🎯 Objetivo

Criar uma alternativa moderna ao SoapUI, combinando:
- **Performance**: < 150MB RAM em repouso, inicialização < 1.5s
- **UX Produtiva**: Interface estilo VS Code com organização funcional do Postman
- **Cross-Platform**: Windows, macOS e Linux

## 🚀 Status do Projeto

**Fase 1: Fundação e Shell Visual** - Em planejamento

## 📋 Roadmap

| Fase | Período | Status |
|------|---------|--------|
| 1. Fundação e Shell Visual | Semana 1-2 | 📋 Pendente |
| 2. Editor de Código e Gestão de Abas | Semana 3-4 | ⏳ Aguardando |
| 3. Motor de Parsing WSDL/XSD | Semana 5-7 | ⏳ Aguardando |
| 4. Cliente HTTP e Ciclo de Resposta | Semana 8-9 | ⏳ Aguardando |
| 5. Variáveis de Ambiente | Semana 10-11 | ⏳ Aguardando |
| 6. Persistência e Coleções | Semana 12-13 | ⏳ Aguardando |
| 7. Otimização e Polimento | Semana 14-15 | ⏳ Aguardando |

## 🛠️ Stack Tecnológico

| Componente | Tecnologia |
|------------|-----------|
| **Framework** | Flutter (Dart) |
| **Editor de Código** | Monaco Editor (`flutter_monaco`) |
| **Parser XML** | Pacote `xml` |
| **HTTP Client** | Pacote `http` |
| **Persistência** | JSON local + `shared_preferences` |

## 📦 Estrutura do Projeto

```
soap-lite/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   ├── core/
│   ├── features/
│   └── services/
├── test/
├── pubspec.yaml
├── README.md
└── CHANGELOG.md
```

## 📄 Licença

MIT

---

*Documento criado em: 10 de março de 2026*
