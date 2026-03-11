<div align="center">
  <img src="https://i.ibb.co/H1DbPgj/logo-openwsdl.png" alt="OpenWsdl Logo" width="40">

# OpenWsdl

Cliente SOAP desktop cross-platform leve, rápido e moderno, focado em performance e ergonomia visual.

</div>

## 🎯 Objetivo

Criar uma alternativa moderna ao SoapUI, combinando:

- **Performance**: < 150MB RAM em repouso, inicialização < 1.5s
- **UX Produtiva**: Interface estilo VS Code com organização funcional do Postman
- **Cross-Platform**: Windows, macOS e Linux

## 🚀 Status do Projeto

**Versão 1.0.0 disponível** - O projeto continua em evolução constante e correções de bugs.

## 📋 Roadmap

| Fase                                 | Complexidade | Status       |
| ------------------------------------ | ------------ | ------------ |
| 1. Fundação e Shell Visual           | Média        | ✅ Concluído |
| 2. Editor de Código e Gestão de Abas | Alta         | ✅ Concluído |
| 3. Motor de Parsing WSDL/XSD         | Muito Alta   | ✅ Concluído |
| 4. Cliente HTTP e Ciclo de Resposta  | Média        | ✅ Concluído |
| 5. Variáveis de Ambiente             | Média        | ✅ Concluído |
| 6. Persistência e Coleções           | Alta         | ✅ Concluído |
| 7. Otimização e Polimento            | Média        | ✅ Concluído |

## 🛠️ Stack Tecnológico

| Componente           | Tecnologia                        |
| -------------------- | --------------------------------- |
| **Framework**        | Flutter (Dart)                    |
| **Editor de Código** | Monaco Editor (`flutter_monaco`)  |
| **Parser XML**       | Pacote `xml`                      |
| **HTTP Client**      | Pacote `http`                     |
| **Persistência**     | JSON local + `shared_preferences` |

## 🏃 Como Rodar

### Pré-requisitos

- Flutter SDK 3.6+
- Visual Studio 2022 (Windows) com workload de C++
- Git

### Passos

1. Clone o repositório:

```bash
git clone <url-do-repositorio>
cd openwsdl
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Execute para Windows:

```bash
flutter run -d windows
```

4. Ou execute para outras plataformas:

```bash
flutter run -d macos    # macOS
flutter run -d linux    # Linux
```

## 📦 Estrutura do Projeto

```
OpenWsdl/
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

[MIT](LICENSE)
